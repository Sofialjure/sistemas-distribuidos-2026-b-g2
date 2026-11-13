#!/usr/bin/env bash
# Chaos 2 - kill document-generation-api in the middle of the consultation -> PDF journey.
# Hypothesis: the professional can still record the attention (the PDF is asynchronous); the
# event is not lost: the worker retries 3 times, parks it in its dead-letter queue and replays it
# later (worker #13, every 5 minutes); when the API is back exactly one PDF is generated.
set -u
cd "$(dirname "$0")" && . ../e2e/lib.sh && . ./clinical.sh
API="${DOCUMENT_API_CONTAINER:-s2-telemed-ia-document-generation-api-document-generation-api-1}"
DLQ=post-consultation-summary-queue.dlq

prepare_consultation
check "consultation in progress" yes "$([ -n "$CID" ] && echo yes)"

echo "--- $(date +%T) docker stop $API"
docker stop "$API" >/dev/null
check "the attention is recorded with the PDF service down" 201 "$(record_attention)"
SID=$(wait_for 20 summary_of "$CID")
check "the post-summary is created anyway" yes "$([ -n "$SID" ] && echo yes)"
T0=$(date +%s)
DEPTH=$(wait_for 90 sh -c "d=\$(docker exec ${RABBIT_CONTAINER:-s2-telemed-ia-worker-rabbitmq-1} rabbitmqctl -q list_queues name messages 2>/dev/null | awk '\$1==\"$DLQ\" {print \$2}'); [ \"\${d:-0}\" -ge 1 ] && echo \$d")
echo "      parked in $DLQ after $(( $(date +%s) - T0 )) s (3 attempts by the worker)"
check "the event is parked in the dead-letter queue, not lost" yes "$([ -n "$DEPTH" ] && echo yes)"
check "the patient's documents answer an error, not a hang" yes "$(c=$(curl -s -m 10 -o /dev/null -w '%{http_code}' "$G/api/v1/documents?limit=5" -H "Authorization: Bearer $PAT"); [ "$c" = 502 ] || [ "$c" = 503 ] || [ "$c" = 504 ] && echo yes || echo "no ($c)")"

echo "--- $(date +%T) docker start $API"
docker start "$API" >/dev/null
T0=$(date +%s)
DOC=$(wait_for 420 sh -c "docker exec $PG psql -U postgres -d telemed_ia -tAc \"SELECT document_id FROM document_generation.consultation_document WHERE summary_id='$SID' AND status='AVAILABLE'\"")
echo "      PDF AVAILABLE $(( $(date +%s) - T0 )) s after the restart (dead-letter replay)"
check "recovery: the PDF is generated" yes "$([ -n "$DOC" ] && echo yes)"
check "recovery: exactly one document for the summary" 1 "$(q "SELECT count(*) FROM document_generation.consultation_document WHERE summary_id='$SID'")"
check "recovery: the dead-letter queue is empty again" 0 "$(queue_depth $DLQ)"
check "recovery: the patient downloads it" 200 "$(curl -s -m 10 -o /dev/null -w '%{http_code}' "$G/api/v1/documents/$DOC/download" -H "Authorization: Bearer $PAT")"

summary
