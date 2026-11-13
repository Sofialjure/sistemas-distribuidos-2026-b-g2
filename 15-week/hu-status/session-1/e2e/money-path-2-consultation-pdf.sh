#!/usr/bin/env bash
# Money path 2 - a patient gets the PDF of the consultation.
# patient books -> professional starts the consultation and records the attention ->
# consultation writes PostConsultationSummaryGenerated in its outbox -> RabbitMQ -> worker ->
# POST /api/documents/generate -> PDF in RustFS -> ConsultationPdfGenerated in my outbox ->
# RabbitMQ -> notifications (inbox) -> the patient lists and downloads the PDF.
# The professional's weekly availability is inserted with SQL: the platform has no endpoint for it.
set -u
cd "$(dirname "$0")" && . ./lib.sh
N=$(date +%s)
STORAGE_PUBLISHED="${STORAGE_PUBLISHED:-http://127.0.0.1:39000}"   # where localhost:9000 is reachable from here

ADMIN=$(login "$ADMIN_EMAIL" "$ADMIN_PASSWORD"); A="Authorization: Bearer $ADMIN"
PEMAIL="e2e-doc-$N@example.test"
curl -s -m 50 -o /tmp/saga2.json -X POST "$G/api/v1/sagas/professional-onboarding" -H "$A" -H "$CT" -H "Idempotency-Key: e2e-saga2-$N" \
  -d "{\"fullName\":\"Andres E2E $N\",\"email\":\"$PEMAIL\",\"identityDocument\":\"6$N\",\"password\":\"Prof-E2E-2026\",\"licenseNumber\":\"RM-E2E2-$N\",\"yearsExperience\":9}"
PACC=$(j 'd["accountId"]' < /tmp/saga2.json)
check "professional onboarded" COMPLETED "$(j 'd["status"]' < /tmp/saga2.json)"
PT=$(login "$PEMAIL" Prof-E2E-2026)
for d in 1 2 3 4 5; do q "INSERT INTO appointment_scheduling.professional_availability (professional_id, day_of_week, start_time, end_time) VALUES ('$PACC',$d,'08:00','12:00')" >/dev/null; done

MAIL="e2e-pat-$N@example.test"
check "patient registers" 201 "$(curl -s -m 15 -o /dev/null -w '%{http_code}' -X POST "$G/api/v1/auth/register" -H "$CT" -H "Idempotency-Key: e2e-pat-$N" \
  -d "{\"fullName\":\"Paciente E2E $N\",\"email\":\"$MAIL\",\"identityDocument\":\"9$N\",\"password\":\"Pat-E2E-2026\",\"phone\":\"3001234567\",\"birthDate\":\"1995-04-12\"}")"
PAT=$(login "$MAIL" Pat-E2E-2026)
PID=$(q "SELECT id FROM public.users WHERE email='$MAIL'")

START=$(python -I -c "import datetime as d;t=d.date.today()+d.timedelta(days=1)
while t.weekday()>4: t+=d.timedelta(days=1)
print(f'{t}T14:00:00Z')")
APT=$(curl -s -m 15 -X POST "$G/api/v1/appointments" -H "Authorization: Bearer $PAT" -H "$CT" -H "Idempotency-Key: e2e-apt-$N" \
  -d "{\"patientId\":\"$PID\",\"professionalId\":\"$PACC\",\"start\":\"$START\"}" | j '(d.get("data") or d)["id"]')
check "appointment booked and CONFIRMED" CONFIRMED "$(q "SELECT status FROM appointment_scheduling.appointments WHERE id='$APT'")"

CID=$(curl -s -m 15 -X POST "$G/api/v1/consultations" -H "Authorization: Bearer $PT" -H "$CT" -H "Idempotency-Key: e2e-cons-$N" \
  -d "{\"appointmentId\":\"$APT\"}" | j 'd["data"]["id"]')
check "professional starts the consultation" yes "$([ -n "$CID" ] && echo yes)"
ATT='{"diagnosis":"Faringitis aguda","recommendations":"Reposo e hidratacion","medications":[{"name":"Acetaminofen","dosage":"500 mg","frequency":"cada 8 horas","duration":"5 dias"}],"observations":"Sin fiebre al examen","followUp":{"required":true,"inDays":7}}'
check "attention recorded" 201 "$(curl -s -m 15 -o /dev/null -w '%{http_code}' -X POST "$G/api/v1/consultations/$CID/attention" -H "Authorization: Bearer $PT" -H "$CT" -H "Idempotency-Key: e2e-att-$N" -d "$ATT")"

SID=$(wait_for 20 q "SELECT id FROM medical_consultation.post_summaries WHERE consultation_id='$CID'")
check "post-summary created automatically" yes "$([ -n "$SID" ] && echo yes)"
check "summary event published by consultation" PUBLISHED "$(wait_for 30 q "SELECT status FROM medical_consultation.outbox_event WHERE event_type='PostConsultationSummaryGenerated' AND payload->'payload'->>'summaryId'='$SID' AND status='PUBLISHED'")"
DOC=$(wait_for 60 q "SELECT document_id FROM document_generation.consultation_document WHERE summary_id='$SID' AND status='AVAILABLE'")
check "worker requested the PDF and it is AVAILABLE" yes "$([ -n "$DOC" ] && echo yes)"
check "ConsultationPdfGenerated published from my outbox" t "$(wait_for 30 q "SELECT published_at IS NOT NULL FROM document_generation.outbox_event WHERE aggregate_id='$DOC' AND published_at IS NOT NULL")"
check "notifications put it in the patient's inbox" DOCUMENT_READY "$(wait_for 30 q "SELECT type FROM notifications.notification WHERE recipient_user_id='$PID' AND type='DOCUMENT_READY'")"
check "the appointment becomes COMPLETED" COMPLETED "$(wait_for 30 q "SELECT status FROM appointment_scheduling.appointments WHERE id='$APT' AND status='COMPLETED'")"

check "the patient lists the document" AVAILABLE "$(curl -s -m 10 "$G/api/v1/documents?limit=5" -H "Authorization: Bearer $PAT" | j '[x["status"] for x in d["data"] if x["id"]=="'"$DOC"'"][0]')"
URL=$(curl -s -m 10 "$G/api/v1/documents/$DOC/download" -H "Authorization: Bearer $PAT" | j 'd["downloadUrl"]')
HOST=$(echo "$URL" | cut -d/ -f3)
CODE=$(curl -s -m 15 -H "Host: $HOST" -o /tmp/e2e.pdf -w '%{http_code}' "$STORAGE_PUBLISHED${URL#http://$HOST}")
check "the signed URL returns the PDF" "200 %PDF-" "$CODE $(head -c 5 /tmp/e2e.pdf)"
curl -s -m 15 -o /dev/null -X POST "$G/api/v1/auth/register" -H "$CT" -H "Idempotency-Key: e2e-pat2-$N"   -d "{\"fullName\":\"Otro Paciente $N\",\"email\":\"other-$MAIL\",\"identityDocument\":\"8$N\",\"password\":\"Pat-E2E-2026\",\"phone\":\"3001234568\",\"birthDate\":\"1990-01-01\"}"
check "another patient gets 403 on the document (DEC-004)" 403 "$(curl -s -m 10 -o /dev/null -w '%{http_code}' "$G/api/v1/documents/$DOC" -H "Authorization: Bearer $(login "other-$MAIL" Pat-E2E-2026)")"
check "the professional cannot list patient documents" 403 "$(curl -s -m 10 -o /dev/null -w '%{http_code}' "$G/api/v1/documents?limit=1" -H "Authorization: Bearer $PT")"

summary
