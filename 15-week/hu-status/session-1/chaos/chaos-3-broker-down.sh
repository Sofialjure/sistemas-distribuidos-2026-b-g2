#!/usr/bin/env bash
# Chaos 3 - stop RabbitMQ while a consultation is recorded.
# Hypothesis: the synchronous part keeps working; every event waits in the outbox of its
# producer (transactional outbox, norm 5.3.11) instead of being lost; when the broker returns the
# relays reconnect, the worker requests the PDF and my ConsultationPdfGenerated is published.
set -u
cd "$(dirname "$0")" && . ../e2e/lib.sh && . ./clinical.sh
RABBIT="${RABBIT_CONTAINER:-s2-telemed-ia-worker-rabbitmq-1}"

prepare_consultation
echo "--- $(date +%T) docker stop $RABBIT"
docker stop "$RABBIT" >/dev/null
check "the attention is recorded with the broker down" 201 "$(record_attention)"
SID=$(wait_for 20 summary_of "$CID")
sleep 10
check "the summary event waits in the consultation outbox" PENDING "$(q "SELECT status FROM medical_consultation.outbox_event WHERE event_type='PostConsultationSummaryGenerated' AND payload->'payload'->>'summaryId'='$SID'")"
check "no document yet" "" "$(document_of "$SID")"

echo "--- $(date +%T) docker start $RABBIT"
docker start "$RABBIT" >/dev/null
T0=$(date +%s)
DOC=$(wait_for 300 sh -c "docker exec $PG psql -U postgres -d telemed_ia -tAc \"SELECT document_id FROM document_generation.consultation_document WHERE summary_id='$SID' AND status='AVAILABLE'\"")
echo "      PDF AVAILABLE $(( $(date +%s) - T0 )) s after the broker restart"
check "recovery: the summary event is published" PUBLISHED "$(q "SELECT status FROM medical_consultation.outbox_event WHERE event_type='PostConsultationSummaryGenerated' AND payload->'payload'->>'summaryId'='$SID'")"
check "recovery: the PDF is generated once" 1 "$(q "SELECT count(*) FROM document_generation.consultation_document WHERE summary_id='$SID' AND status='AVAILABLE'")"
PUB=$(wait_for 60 q "SELECT 't' FROM document_generation.outbox_event WHERE aggregate_id='$DOC' AND published_at IS NOT NULL")
check "recovery: my relay reconnected and published ConsultationPdfGenerated" t "$PUB"
check "recovery: notifications received it" DOCUMENT_READY "$(wait_for 30 q "SELECT type FROM notifications.notification WHERE recipient_user_id='$PID' AND type='DOCUMENT_READY'")"

summary
