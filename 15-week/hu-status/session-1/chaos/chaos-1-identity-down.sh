#!/usr/bin/env bash
# Chaos 1 - kill identity-and-access-api while the professional services are in use.
# Hypothesis: tokens already issued keep working (every service verifies RS256 locally); the
# professional list still answers 200 without the account names (DEC-008 fallback); creating an
# account fails fast with 503 and leaves nothing half done; the onboarding saga ends without a
# profile; documents are not affected; everything returns when identity is back.
set -u
cd "$(dirname "$0")" && . ../e2e/lib.sh
IDENTITY="${IDENTITY_CONTAINER:-s2-telemed-ia-identity-and-access-api-identity-api-1}"
N=$(date +%s)

ADMIN=$(login "$ADMIN_EMAIL" "$ADMIN_PASSWORD"); A="Authorization: Bearer $ADMIN"
PATIENT_MAIL=$(q "SELECT email FROM public.users WHERE email LIKE 'e2e-pat-%' LIMIT 1")
PAT=$(login "$PATIENT_MAIL" Pat-E2E-2026)
check "steady state: the list carries account names" yes "$(curl -s -m 10 "$G/api/v1/professionals?limit=5" -H "$A" | j '"yes" if all("fullName" in x for x in d["data"]) else "no"')"

echo "--- $(date +%T) docker stop $IDENTITY"
docker stop "$IDENTITY" >/dev/null

LIST=$(curl -s -m 10 -w '\n%{http_code}' "$G/api/v1/professionals?limit=5" -H "$A")
check "the list still answers 200" 200 "$(echo "$LIST" | tail -1)"
check "the list degrades to profiles without names" no "$(echo "$LIST" | head -1 | j '"yes" if any("fullName" in x for x in d["data"]) else "no"')"
T0=$(date +%s%N); for _ in $(seq 1 20); do curl -s -m 10 -o /dev/null "$G/api/v1/professionals?limit=5" -H "$A"; done
echo "      20 list reads with identity down: average $(( ($(date +%s%N) - T0) / 20000000 )) ms each"

BODY="{\"fullName\":\"Sin Identidad $N\",\"email\":\"chaos-$N@example.test\",\"identityDocument\":\"3$N\",\"password\":\"Prof-E2E-2026\",\"licenseNumber\":\"RM-NOID-$N\",\"yearsExperience\":2}"
T0=$(date +%s%N)
REG=$(curl -s -m 30 -w '\n%{http_code}' -X POST "$G/api/v1/professionals/admin/register" -H "$A" -H "$CT" -H "Idempotency-Key: chaos-reg-$N" -d "$BODY")
echo "      registration answered in $(( ($(date +%s%N) - T0) / 1000000 )) ms"
check "registration fails fast with 503" "503 SERVICE_UNAVAILABLE" "$(echo "$REG" | tail -1) $(echo "$REG" | head -1 | j 'd["error"]')"
check "no profile was stored for it" 0 "$(q "SELECT count(*) FROM professional_management.professional WHERE license_number='RM-NOID-$N'")"
SAGA=$(curl -s -m 50 -X POST "$G/api/v1/sagas/professional-onboarding" -H "$A" -H "$CT" -H "Idempotency-Key: chaos-saga-noid-$N" -d "${BODY/RM-NOID/RM-NOID-SAGA}")
check "the saga stops at create-account and leaves no profile" "create-account None" "$(echo "$SAGA" | j 'd["failedStep"]') $(echo "$SAGA" | j 'd["professionalId"]')"
echo "      saga status: $(echo "$SAGA" | j 'd["status"]')"
check "documents are not affected" 200 "$(curl -s -m 10 -o /dev/null -w '%{http_code}' "$G/api/v1/documents?limit=5" -H "Authorization: Bearer $PAT")"
check "a new sign-in is not possible (the blast radius)" yes "$(c=$(curl -s -m 10 -o /dev/null -w '%{http_code}' -X POST "$G/api/v1/auth/login" -H "$CT" -d '{"email":"x@example.test","password":"x"}'); [ "$c" -ge 500 ] && echo yes || echo "no ($c)")"

echo "--- $(date +%T) docker start $IDENTITY"
docker start "$IDENTITY" >/dev/null
T0=$(date +%s)
NAMES=$(wait_for 120 sh -c "curl -s -m 5 '$G/api/v1/professionals?limit=5' -H '$A' | python -I -c \"import sys,json;d=json.load(sys.stdin);print('yes' if all('fullName' in x for x in d['data']) else '')\" 2>/dev/null")
echo "      names back $(( $(date +%s) - T0 )) s after the restart"
check "recovery: the list carries names again" yes "$NAMES"
check "recovery: the same registration now succeeds" 201 "$(curl -s -m 30 -o /dev/null -w '%{http_code}' -X POST "$G/api/v1/professionals/admin/register" -H "$A" -H "$CT" -H "Idempotency-Key: chaos-reg-$N" -d "$BODY")"

summary
