#!/bin/bash
# Blue-green rollout and rollback under continuous traffic.
# Usage: rollout.sh <admin token file> <output dir>
TOKEN=$(cat "$1"); OUT=$2; LB=http://127.0.0.1:28090; W=$(dirname "$0")
: > "$OUT/requests.log"
traffic() {  # one authenticated read every 50 ms: status, served-by, time
  while [ ! -f "$OUT/stop" ]; do
    curl -s -o /dev/null -D - -m 5 -H "Authorization: Bearer $TOKEN" "$LB/api/professionals?page=1&limit=5" -w 'TIME %{http_code} %{time_total}\n' \
      | awk -v t="$(date +%s.%N)" '/^X-Served-By/{c=$2" "$3} /^TIME/{printf "%s %s %s %s\n", t, $2, c, $3}' | tr -d '\r' >> "$OUT/requests.log"
    sleep 0.05
  done
}
switch() {  # health gate, then atomic swap of the active upstream and a graceful reload
  local color=$1 start=$(date +%s.%N)
  [ "$(docker inspect -f '{{.State.Health.Status}}' pm-$color)" = healthy ] || { echo "ABORT: pm-$color is not healthy"; return 1; }
  cp "$W/lb/$color.inc" "$W/lb/active.inc" && docker exec pm-lb nginx -t -q && docker exec pm-lb nginx -s reload
  until curl -s -D - -o /dev/null "$LB/health" | grep -q "X-Served-By: $color"; do sleep 0.05; done
  echo "$(date +%T) switched to $color in $(awk -v a="$start" -v b="$(date +%s.%N)" "BEGIN{printf \"%.2f\", b-a}") s"
}
rm -f "$OUT/stop"; traffic & sleep 15
switch green; sleep 20
echo "$(date +%T) rollback rehearsal"; switch blue; sleep 15
touch "$OUT/stop"; wait
echo "requests: $(wc -l < "$OUT/requests.log")"
awk '{print $2}' "$OUT/requests.log" | sort | uniq -c | sed 's/^/  status /'
awk '{print $3" "$4}' "$OUT/requests.log" | sort | uniq -c | sed 's/^/  served by /'
awk '$2!=200' "$OUT/requests.log" | head -5
