#!/bin/sh
# Week 13 security probes. Runs inside a throwaway curl container attached to the platform
# network, so the calls that bypass the gateway behave like a compromised neighbour would.
# Tokens and ids arrive as environment variables (probe.env, written by mint-tokens.sh);
# GW, PM and DOC can override the service addresses on the platform network.
GW=${GW:-http://telemed-ia-api-gateway:80}
PM=${PM:-http://professional-management-api:8080}
DOC=${DOC:-http://document-generation-api:8080}
pass=0; fail=0
check() {  # check <expected status> <description> <curl args...>
  want=$1; what=$2; shift 2
  got=$(curl -s -o /tmp/body -w '%{http_code}' -m 10 "$@")
  if [ "$got" = "$want" ]; then pass=$((pass+1)); r=PASS; else fail=$((fail+1)); r=FAIL; fi
  printf '%s %s (expected %s, got %s)\n' "$r" "$what" "$want" "$got"
}
body_has() { grep -q "$1" /tmp/body && echo "  body has $1" || echo "  body has no $1"; }

echo "## Edge: the gateway"
check 401 "gateway, no token, list professionals" $GW/api/v1/professionals
check 200 "gateway, admin token, list professionals" -H "Authorization: Bearer $ADMIN" $GW/api/v1/professionals

echo "## Zero trust: calls that bypass the gateway"
check 401 "service, no token" $PM/api/professionals
check 401 "service, token signed with another key" -H "Authorization: Bearer $FORGED" $PM/api/professionals
check 401 "service, expired token" -H "Authorization: Bearer $EXPIRED" $PM/api/professionals
check 401 "service, alg none token" -H "Authorization: Bearer $NONE" $PM/api/professionals
check 401 "service, patient token with role edited to ADMIN" -H "Authorization: Bearer $TAMPERED" $PM/api/professionals
check 401 "document service, no token" $DOC/api/documents

echo "## Authorization in each service"
check 403 "patient registers a professional" -X POST -H "Authorization: Bearer $PATIENT_A" -H 'Content-Type: application/json' -H 'Idempotency-Key: w13-probe-0001' -d '{"fullName":"X","email":"x@x.co","identityDocument":"1","password":"Secret-12345","licenseNumber":"W13-1","yearsExperience":1}' $PM/api/professionals/admin/register
check 403 "professional changes a profile status" -X PATCH -H "Authorization: Bearer $PROFESSIONAL" -H 'Content-Type: application/json' -d '{"status":"INACTIVE"}' $PM/api/professionals/$PROF_ID/status
check 200 "patient reads the list" -H "Authorization: Bearer $PATIENT_A" "$PM/api/professionals?page=1&limit=50"
body_has '"email"'
check 200 "admin reads the list" -H "Authorization: Bearer $ADMIN" "$PM/api/professionals?page=1&limit=50"
body_has '"email"'
check 200 "owner reads her document" -H "Authorization: Bearer $PATIENT_A" $DOC/api/documents/$DOC_ID
check 403 "another patient reads that document (IDOR, 403 per contract)" -H "Authorization: Bearer $PATIENT_B" $DOC/api/documents/$DOC_ID
check 403 "another patient downloads that document (IDOR, 403 per contract)" -H "Authorization: Bearer $PATIENT_B" $DOC/api/documents/$DOC_ID/download
check 403 "service token of a client not in the allow-list asks for a PDF" -X POST -H "Authorization: Bearer $ROGUE_SERVICE" -H 'Content-Type: application/json' -H 'Idempotency-Key: w13-probe-0002' -d '{"summaryId":"00000000-0000-0000-0000-000000000001","patientId":"00000000-0000-0000-0000-000000000002"}' $DOC/api/documents/generate

check 403 "patient asks for a PDF with an empty body (authorize before validating)" -X POST -H "Authorization: Bearer $PATIENT_A" -H 'Content-Type: application/json' -d '{}' $DOC/api/documents/generate

echo "## Input validation and error hygiene"
check 400 "id that is not a UUID" -H "Authorization: Bearer $ADMIN" "$PM/api/professionals/1%20OR%201=1"
body_has 'traceId'
grep -qiE 'exception|stack|org\.|java\.|select ' /tmp/body && echo "  body LEAKS internals" || echo "  body leaks no internals"
check 400 "page size above the limit" -H "Authorization: Bearer $ADMIN" "$PM/api/professionals?page=1&limit=1000"
check 400 "registration without Idempotency-Key" -X POST -H "Authorization: Bearer $ADMIN" -H 'Content-Type: application/json' -d '{}' $PM/api/professionals/admin/register

echo "passed $pass, failed $fail"
