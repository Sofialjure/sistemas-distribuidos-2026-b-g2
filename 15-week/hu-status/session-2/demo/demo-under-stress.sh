#!/usr/bin/env bash
# Demo under stress (session 2): the four steps of the demo, at the same time.
#   1. full user journey  -> money path 1 (onboarding) while the load runs
#   2. observability      -> golden signals read from both services at the end
#   3. small load test    -> 100 rps on each list for 90 s (inside the platform network)
#   4. inject a failure   -> chaos 2 (document API killed mid-journey) while the load runs
# The professional list must stay inside its SLO the whole time; the document list fails only
# while its service is down and recovers by itself; the PDF of the journey is not lost.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; S1="$HERE/../../session-1"
NET="${NETWORK:-tsw2}"; OUT="$HERE/../results"; mkdir -p "$OUT"
. "$S1/e2e/lib.sh"
ADMIN=$(login "$ADMIN_EMAIL" "$ADMIN_PASSWORD")
PAT=$(login "$(q "SELECT email FROM public.users WHERE email LIKE 'e2e-pat-%' LIMIT 1")" Pat-E2E-2026)
LOAD=$(cygpath -w "$S1/load" 2>/dev/null || echo "$S1/load")

run_load() {  # run_load <name> <url> <token>
  MSYS_NO_PATHCONV=1 docker run --rm --network "$NET" -v "$LOAD:/load" -e NAME="$1" -e TARGET="$2" -e TOKEN="$3" \
    -e STEPS=100 -e STEP_SECONDS=90 python:3.12-alpine python /load/load.py > "$OUT/demo-load-$1.md" 2>&1
}

echo "=== $(date +%T) step 3: load starts (100 rps on each list, 90 s)"
run_load professional-list "http://professional-management-api:8080/api/professionals?limit=20" "$ADMIN" &
run_load document-list "http://document-generation-api:8080/api/documents?limit=20" "$PAT" &
sleep 10
echo "=== $(date +%T) step 1: money path 1 under load"
bash "$S1/e2e/money-path-1-onboarding.sh" | tail -1
echo "=== $(date +%T) step 4: chaos 2 under load (document API killed mid-journey)"
bash "$S1/chaos/chaos-2-document-api-down.sh"
wait
echo "=== $(date +%T) load results"
cat "$OUT/demo-load-professional-list.md" "$OUT/demo-load-document-list.md"
rm -f "$S1"/load/results-*.json
