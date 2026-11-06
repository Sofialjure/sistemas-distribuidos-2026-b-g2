#!/usr/bin/env bash
# Smoke test of a deployed service: it answers, rejects anonymous calls with the error
# envelope, accepts a valid token, and exposes health and metrics on its management port.
# Usage: smoke-test.sh <service-url> <management-url> <protected-path> <metric-prefix> [token]
set -uo pipefail
BASE="$1"; MGMT="$2"; PATH_PROTECTED="$3"; METRIC="$4"; TOKEN="${5:-}"
PASS=0; FAIL=0
check() { # check <description> <expected> <actual>
  if [ "$2" = "$3" ]; then echo "PASS  $1 ($3)"; PASS=$((PASS+1)); else echo "FAIL  $1 (expected $2, got $3)"; FAIL=$((FAIL+1)); fi
}
for i in $(seq 1 60); do curl -fs -o /dev/null "$BASE/health" && break; sleep 2; done
check "GET /health answers 200"            200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/health")"
check "GET /health reports UP"             UP  "$(curl -s "$BASE/health" | grep -o '"UP"' | tr -d '"' | head -1)"
check "anonymous $PATH_PROTECTED is 401"   401 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE$PATH_PROTECTED")"
check "401 carries the error envelope"     yes "$(curl -s "$BASE$PATH_PROTECTED" | grep -q '"traceId"' && echo yes || echo no)"
check "X-Correlation-Id is echoed"         smoke-1 "$(curl -s -D - -o /dev/null -H 'X-Correlation-Id: smoke-1' "$BASE$PATH_PROTECTED" | tr -d '\r' | awk -F': ' 'tolower($1)=="x-correlation-id"{print $2}')"
if [ -n "$TOKEN" ]; then
  check "authorized $PATH_PROTECTED is 200" 200 "$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "$BASE$PATH_PROTECTED")"
fi
check "management health is 200"           200 "$(curl -s -o /dev/null -w '%{http_code}' "$MGMT/actuator/health")"
check "metrics expose $METRIC"             yes "$(curl -s "$MGMT/actuator/prometheus" | grep -q "^$METRIC" && echo yes || echo no)"
echo "smoke: $PASS passed, $FAIL failed"
[ "$FAIL" = 0 ]
