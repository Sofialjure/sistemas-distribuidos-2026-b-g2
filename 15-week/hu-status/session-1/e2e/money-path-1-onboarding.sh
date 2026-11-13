#!/usr/bin/env bash
# Money path 1 - a professional can start working.
# ADMIN -> gateway -> workflow saga (identity creates the account inactive, professional-management
# creates the profile, identity activates the account) -> the professional signs in and reads
# its profile -> the administrator lists it with its name -> status change.
set -u
cd "$(dirname "$0")" && . ./lib.sh
N=$(date +%s)

ADMIN=$(login "$ADMIN_EMAIL" "$ADMIN_PASSWORD")
check "administrator signs in" yes "$([ -n "$ADMIN" ] && echo yes)"
A="Authorization: Bearer $ADMIN"

EMAIL="e2e-prof-$N@example.test"
BODY="{\"fullName\":\"Laura E2E $N\",\"email\":\"$EMAIL\",\"identityDocument\":\"7$N\",\"password\":\"Prof-E2E-2026\",\"licenseNumber\":\"RM-E2E-$N\",\"yearsExperience\":4}"
saga() { curl -s -m 50 -o /tmp/saga.json -w '%{http_code}' -X POST "$G/api/v1/sagas/professional-onboarding" -H "$A" -H "$CT" -H "Idempotency-Key: e2e-saga-$N" -H "X-Correlation-Id: e2e-$N" -d "$1"; }

check "saga answers 201" 201 "$(saga "$BODY")"
check "saga ends COMPLETED" COMPLETED "$(j 'd["status"]' < /tmp/saga.json)"
check "all three steps done" "create-account,create-profile,activate-account" "$(j '",".join(d["completedSteps"])' < /tmp/saga.json)"
PROFILE=$(j 'd["professionalId"]' < /tmp/saga.json)
check "same key and body is a replay (200)" 200 "$(saga "$BODY")"
check "same key with another body is 422" 422 "$(saga "${BODY/yearsExperience\":4/yearsExperience\":5}")"

PT=$(login "$EMAIL" Prof-E2E-2026)
check "the new professional signs in" yes "$([ -n "$PT" ] && echo yes)"
ME=$(curl -s -m 10 "$G/api/v1/professionals/me" -H "Authorization: Bearer $PT")
check "/me returns the new profile" "$PROFILE" "$(echo "$ME" | j 'd["id"]')"

LIST=$(curl -s -m 10 "$G/api/v1/professionals?limit=5" -H "$A")
check "newest first, with the account name" "Laura E2E $N" "$(echo "$LIST" | j 'd["data"][0]["fullName"]')"
check "the administrator sees the e-mail" "$EMAIL" "$(echo "$LIST" | j 'd["data"][0]["email"]')"
check "a professional does not see e-mails" None "$(curl -s -m 10 "$G/api/v1/professionals?limit=1" -H "Authorization: Bearer $PT" | j 'd["data"][0].get("email")')"

status() { curl -s -m 10 -o /dev/null -w '%{http_code}' -X PATCH "$G/api/v1/professionals/$PROFILE/status" -H "$1" -H "$CT" -d "{\"status\":\"$2\"}"; }
check "a professional cannot change a status (403)" 403 "$(status "Authorization: Bearer $PT" INACTIVE)"
check "the administrator deactivates the profile" 200 "$(status "$A" INACTIVE)"
check "and activates it again" 200 "$(status "$A" ACTIVE)"
check "every step shares the correlation id in the workflow log" yes "$(docker logs "${WORKFLOW_CONTAINER:-s2-telemed-ia-workflow-workflow-api-1}" 2>&1 | grep -q "e2e-$N" && echo yes)"

summary
