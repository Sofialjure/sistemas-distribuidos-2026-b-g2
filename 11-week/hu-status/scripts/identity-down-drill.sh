#!/bin/bash
# Drill: stop identity for 150 s while an administrator keeps registering professionals,
# then read the 1h burn rate and the alerts Prometheus is firing.
# Usage: ADMIN_EMAIL=... ADMIN_PASSWORD=... identity-down-drill.sh [gateway url] [prometheus container]
GW=${1:-http://127.0.0.1:8000}
PROM=${2:-telemed-ia-prometheus}
: "${ADMIN_EMAIL:?set ADMIN_EMAIL}" "${ADMIN_PASSWORD:?set ADMIN_PASSWORD}"
ID=$(docker ps --filter name=identity-api --format '{{.Names}}' | head -1)
ADMIN=$(curl -s -m 10 -X POST "$GW/api/v1/auth/login" -H 'Content-Type: application/json' \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}" \
  | python -I -c 'import sys, json; print(json.load(sys.stdin)["accessToken"])')

docker stop "$ID" >/dev/null
end=$(( $(date +%s) + 150 )); n=0
while [ "$(date +%s)" -lt "$end" ]; do
  N=$(date +%s%N | cut -c1-13)
  curl -s -m 15 -o /dev/null -X POST "$GW/api/v1/professionals/admin/register" \
    -H "Authorization: Bearer $ADMIN" -H 'Content-Type: application/json' -H "Idempotency-Key: drill-$N" \
    -d "{\"fullName\":\"Drill $N\",\"email\":\"d$N@drill.test\",\"identityDocument\":\"5$N\",\"password\":\"Drill-Pass-2026\",\"licenseNumber\":\"DR-$N\",\"yearsExperience\":3}"
  n=$((n+1))
done
docker start "$ID" >/dev/null
echo "registrations attempted while identity was down: $n"

Q='((sum(rate(http_server_requests_seconds_count{application="professional-management-api",uri=~"/api/professionals.*",status=~"5.."}[1h])) or vector(0)) / sum(rate(http_server_requests_seconds_count{application="professional-management-api",uri=~"/api/professionals.*"}[1h]))) / (1 - 0.995)'
docker exec "$PROM" wget -qO- "http://localhost:9090/api/v1/query?query=$(python -I -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$Q")" \
  | python -I -c 'import sys, json; r = json.load(sys.stdin)["data"]["result"]; print("burn rate 1h =", r[0]["value"][1] if r else "none")'
docker exec "$PROM" wget -qO- http://localhost:9090/api/v1/alerts \
  | python -I -c 'import sys, json; [print("alert", a["labels"]["alertname"], a["state"]) for a in json.load(sys.stdin)["data"]["alerts"]]'
