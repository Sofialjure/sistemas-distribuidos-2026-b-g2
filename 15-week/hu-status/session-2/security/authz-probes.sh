#!/usr/bin/env bash
# Operability checklist - security: authentication and authorization enforced in each of my
# services (not only at the gateway). Probes through the gateway and, for the routes the gateway
# does not publish, from inside the platform network with a python:3.12-alpine container.
#   NETWORK  docker network of the platform (default tsw2)
#   NOTIFICATIONS_CLIENT_SECRET  secret of the "notifications" service client (never committed)
set -u
cd "$(dirname "$0")" && . ../../session-1/e2e/lib.sh
NET="${NETWORK:-tsw2}"
PM_SERVICE="${PM_SERVICE:-http://professional-management-api}:8080"
DG_SERVICE="${DG_SERVICE:-http://document-generation-api}:8080"
DG_MANAGEMENT="${DG_MANAGEMENT:-http://document-generation-api}:9081"
code() { curl -s -m 10 -o /dev/null -w '%{http_code}' "$@"; }
inside() {  # inside <method> <url> <token|-> [body]: status code seen from inside the network
  MSYS_NO_PATHCONV=1 docker run --rm --network "$NET" python:3.12-alpine python -c '
import sys, urllib.request, urllib.error
m, u, t = sys.argv[1], sys.argv[2], sys.argv[3]
b = sys.argv[4].encode() if len(sys.argv) > 4 else None
h = {"Content-Type": "application/json", "Idempotency-Key": "probe-key-0001"}
if t != "-": h["Authorization"] = "Bearer " + t
try: print(urllib.request.urlopen(urllib.request.Request(u, data=b, headers=h, method=m), timeout=10).status)
except urllib.error.HTTPError as e: print(e.code)' "$@"
}

ADMIN=$(login "$ADMIN_EMAIL" "$ADMIN_PASSWORD")
PATIENT_MAIL=$(q "SELECT email FROM public.users WHERE email LIKE 'e2e-pat-%' LIMIT 1")
PAT=$(login "$PATIENT_MAIL" Pat-E2E-2026)
PROF_MAIL=$(q "SELECT email FROM public.users WHERE email LIKE 'e2e-prof-%' LIMIT 1")
PT=$(login "$PROF_MAIL" Prof-E2E-2026)
FORGED="$(echo "$ADMIN" | cut -d. -f1,2).c2lnbmF0dXJlLWZyb20tYW5vdGhlci1rZXk"
NONE="$(printf '{"alg":"none","typ":"JWT"}' | base64 | tr -d '=' | tr '+/' '-_').$(echo "$ADMIN" | cut -d. -f2)."
PROF_ID=$(q "SELECT id FROM professional_management.professional LIMIT 1")
DOC=$(q "SELECT document_id FROM document_generation.consultation_document WHERE status='AVAILABLE' LIMIT 1")
GEN='{"summaryId":"'$(uuid)'","patientId":"'$(uuid)'"}'
REG='{"fullName":"Probe","email":"probe@example.test","identityDocument":"1000000001","password":"Probe-2026-ok","licenseNumber":"RM-PROBE","yearsExperience":1}'
INT='{"accountId":"'$(uuid)'","licenseNumber":"RM-PROBE-INT","yearsExperience":1}'

echo "## Professional Management (through the gateway)"
check "list without a token -> 401" 401 "$(code "$G/api/v1/professionals")"
check "list with a forged signature -> 401" 401 "$(code "$G/api/v1/professionals" -H "Authorization: Bearer $FORGED")"
check "list with alg none -> 401" 401 "$(code "$G/api/v1/professionals" -H "Authorization: Bearer $NONE")"
check "register as PATIENT with a valid body -> 403" 403 "$(code -X POST "$G/api/v1/professionals/admin/register" -H "Authorization: Bearer $PAT" -H "$CT" -H "Idempotency-Key: probe-$RANDOM-key" -d "$REG")"
check "register as PROFESSIONAL with a valid body -> 403" 403 "$(code -X POST "$G/api/v1/professionals/admin/register" -H "Authorization: Bearer $PT" -H "$CT" -H "Idempotency-Key: probe-$RANDOM-key" -d "$REG")"
check "register as PATIENT with an empty body -> 403 (same pattern as W13)" 403 "$(code -X POST "$G/api/v1/professionals/admin/register" -H "Authorization: Bearer $PAT" -H "$CT" -H "Idempotency-Key: probe-$RANDOM-key" -d '{}')"
check "status change as PATIENT -> 403" 403 "$(code -X PATCH "$G/api/v1/professionals/$PROF_ID/status" -H "Authorization: Bearer $PAT" -H "$CT" -d '{"status":"INACTIVE"}')"
check "/me as PATIENT -> 403" 403 "$(code "$G/api/v1/professionals/me" -H "Authorization: Bearer $PAT")"
check "internal saga route is not published by the gateway -> 404" 404 "$(code -X POST "$G/internal/professionals" -H "Authorization: Bearer $ADMIN")"
check "internal saga route with an ADMIN token and a valid body, inside the network -> 403" 403 "$(inside POST "$PM_SERVICE/internal/professionals" "$ADMIN" "$INT")"
check "internal saga route with an ADMIN token and an empty body -> 403 (same pattern)" 403 "$(inside POST "$PM_SERVICE/internal/professionals" "$ADMIN" '{}')"

echo "## Document Generation"
check "documents without a token -> 401" 401 "$(code "$G/api/v1/documents")"
check "documents with a forged signature -> 401" 401 "$(code "$G/api/v1/documents" -H "Authorization: Bearer $FORGED")"
check "documents as PROFESSIONAL -> 403" 403 "$(code "$G/api/v1/documents" -H "Authorization: Bearer $PT")"
check "documents as ADMIN -> 403 (patients only, DEC-004)" 403 "$(code "$G/api/v1/documents" -H "Authorization: Bearer $ADMIN")"
check "another patient's download -> 403" 403 "$(code "$G/api/v1/documents/$DOC/download" -H "Authorization: Bearer $PAT")"
check "generate as PATIENT with a valid body -> 403" 403 "$(inside POST "$DG_SERVICE/api/documents/generate" "$PAT" "$GEN")"
check "generate as PATIENT with an empty body -> 403 (W13 finding: validation before authorization)" 403 "$(inside POST "$DG_SERVICE/api/documents/generate" "$PAT" '{}')"
if [ -n "${NOTIFICATIONS_CLIENT_SECRET:-}" ]; then
  SVC=$(MSYS_NO_PATHCONV=1 docker run --rm --network "$NET" python:3.12-alpine python -c '
import json, sys, urllib.request
r = urllib.request.Request("http://identity-api:8081/internal/service-token", data=json.dumps({"clientId": "notifications", "clientSecret": sys.argv[1]}).encode(), headers={"Content-Type": "application/json"})
print(json.load(urllib.request.urlopen(r, timeout=10))["accessToken"])' "$NOTIFICATIONS_CLIENT_SECRET")
  check "generate with a SERVICE token of another client (notifications) -> 403" 403 "$(inside POST "$DG_SERVICE/api/documents/generate" "$SVC" "$GEN")"
fi
check "pause switch on the management port without a token -> reachable (open story #151)" 200 "$(inside GET "$DG_MANAGEMENT/actuator/generation" -)"

summary
