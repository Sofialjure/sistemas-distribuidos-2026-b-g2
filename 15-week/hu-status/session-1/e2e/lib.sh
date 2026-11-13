#!/usr/bin/env bash
# Shared helpers of the end-to-end money-path tests. Everything goes through the API Gateway,
# except the read-only SQL checks of the asynchronous steps.
#   GATEWAY       base URL of the gateway (default http://127.0.0.1:38000, the isolated run)
#   PG_CONTAINER  PostgreSQL container of the platform (default s2-telemed-ia-postgres)
#   ADMIN_EMAIL / ADMIN_PASSWORD  the bootstrap administrator of identity (never committed)
G="${GATEWAY:-http://127.0.0.1:38000}"
PG="${PG_CONTAINER:-s2-telemed-ia-postgres}"
CT='Content-Type: application/json'
PASS=0; FAIL=0

j() { python -I -c "import sys,json;d=json.load(sys.stdin);print(eval(sys.argv[1]))" "$1" 2>/dev/null; }
q() { docker exec "$PG" psql -U postgres -d telemed_ia -tAc "$1"; }
uuid() { python -I -c "import uuid;print(uuid.uuid4())"; }
login() { curl -s -m 10 -X POST "$G/api/v1/auth/login" -H "$CT" -d "{\"email\":\"$1\",\"password\":\"$2\"}" | j 'd["accessToken"]'; }

# check <name> <expected> <actual>
check() {
  if [ "$2" = "$3" ]; then PASS=$((PASS + 1)); echo "PASS  $1"
  else FAIL=$((FAIL + 1)); echo "FAIL  $1 (expected '$2', got '$3')"; fi
}

# wait_for <seconds> <command...>: retries the command every second until it prints something
wait_for() {
  local limit=$1; shift; local out=""
  for _ in $(seq 1 "$limit"); do out=$("$@"); [ -n "$out" ] && break; sleep 1; done
  echo "$out"
}

summary() { echo "--- $PASS passed, $FAIL failed"; [ "$FAIL" -eq 0 ]; }
