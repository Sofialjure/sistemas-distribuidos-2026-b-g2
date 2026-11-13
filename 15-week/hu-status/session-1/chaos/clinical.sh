#!/usr/bin/env bash
# Prepares one consultation in progress (professional, patient, appointment, consultation) so a
# chaos experiment can record the attention while a dependency is down. Sourced after ../e2e/lib.sh.
# Sets: PT (professional token), PAT (patient token), PID (patient), CID (consultation), APT.
prepare_consultation() {
  local n; n=$(date +%s%N | cut -c1-13)
  local admin; admin=$(login "$ADMIN_EMAIL" "$ADMIN_PASSWORD")
  local pemail="chaos-prof-$n@example.test" mail="chaos-pat-$n@example.test"
  local acc; acc=$(curl -s -m 50 -X POST "$G/api/v1/sagas/professional-onboarding" -H "Authorization: Bearer $admin" -H "$CT" \
    -H "Idempotency-Key: chaos-saga-$n" -d "{\"fullName\":\"Chaos Prof $n\",\"email\":\"$pemail\",\"identityDocument\":\"5$n\",\"password\":\"Prof-E2E-2026\",\"licenseNumber\":\"RM-CH-$n\",\"yearsExperience\":3}" | j 'd["accountId"]')
  for d in 1 2 3 4 5; do q "INSERT INTO appointment_scheduling.professional_availability (professional_id, day_of_week, start_time, end_time) VALUES ('$acc',$d,'08:00','12:00')" >/dev/null; done
  PT=$(login "$pemail" Prof-E2E-2026)
  curl -s -m 15 -o /dev/null -X POST "$G/api/v1/auth/register" -H "$CT" -H "Idempotency-Key: chaos-pat-$n" \
    -d "{\"fullName\":\"Chaos Paciente $n\",\"email\":\"$mail\",\"identityDocument\":\"4$n\",\"password\":\"Pat-E2E-2026\",\"phone\":\"3001234567\",\"birthDate\":\"1995-04-12\"}"
  PAT=$(login "$mail" Pat-E2E-2026)
  PID=$(q "SELECT id FROM public.users WHERE email='$mail'")
  local start; start=$(python -I -c "import datetime as d;t=d.date.today()+d.timedelta(days=1)
while t.weekday()>4: t+=d.timedelta(days=1)
print(f'{t}T15:00:00Z')")
  APT=$(curl -s -m 15 -X POST "$G/api/v1/appointments" -H "Authorization: Bearer $PAT" -H "$CT" -H "Idempotency-Key: chaos-apt-$n" \
    -d "{\"patientId\":\"$PID\",\"professionalId\":\"$acc\",\"start\":\"$start\"}" | j '(d.get("data") or d)["id"]')
  CID=$(curl -s -m 15 -X POST "$G/api/v1/consultations" -H "Authorization: Bearer $PT" -H "$CT" -H "Idempotency-Key: chaos-cons-$n" \
    -d "{\"appointmentId\":\"$APT\"}" | j 'd["data"]["id"]')
}

record_attention() {
  curl -s -m 15 -o /dev/null -w '%{http_code}' -X POST "$G/api/v1/consultations/$CID/attention" -H "Authorization: Bearer $PT" -H "$CT" \
    -H "Idempotency-Key: chaos-att-$CID" \
    -d '{"diagnosis":"Gripe","recommendations":"Reposo","medications":[],"observations":"Sin complicaciones","followUp":{"required":false}}'
}

summary_of() { q "SELECT id FROM medical_consultation.post_summaries WHERE consultation_id='$1'"; }
document_of() { q "SELECT document_id||' '||status FROM document_generation.consultation_document WHERE summary_id='$1'"; }
queue_depth() { docker exec "${RABBIT_CONTAINER:-s2-telemed-ia-worker-rabbitmq-1}" rabbitmqctl -q list_queues name messages 2>/dev/null | awk -v q="$1" '$1==q {print $2}'; }
