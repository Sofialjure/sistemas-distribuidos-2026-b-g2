# Simulated Incident — MinIO Latency

**Journey:** Generate Consultation Document

**Incident window:** 40 minutes.

**Scenario:** MinIO takes 3 seconds to respond for 25% of requests.

## Span Tree for an Affected Request

- Root Span: `POST /api/v1/documents` — `api-gateway` (**3500 ms**)
  - Child Span: `document-generation-api POST /api/v1/documents`
    - Child Span: `document-generation-db INSERT status=PENDING` — PostgreSQL (**50 ms**)
    - Child Span: `Upload PDF` — MinIO (**3000 ms**)

The remaining time in the root span includes validation, publish/consume, and processing within `document-generation-api`.

## Logs from an Affected Trace

All four lines share the same `trace_id` and show the MinIO delay through upload completion.

```json
{"timestamp":"2026-10-19T09:10:00.000Z","level":"WARN","service":"api-gateway","version":"1.0.0","environment":"prod","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"00f067aa0ba902b7","correlation_id":"corr-incident-001","event":"document.request.received","message":"Solicitud de documento iniciada","duration_ms":0,"document_id":"doc-incident-001","consultation_id":"con-incident-001","patient_id":"pat-incident-001","status":"GENERATING"}
{"timestamp":"2026-10-19T09:10:00.050Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"prod","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"b9c7c989f97918e1","correlation_id":"corr-incident-001","event":"document.record.created","message":"Registro PENDING guardado en PostgreSQL","duration_ms":50,"document_id":"doc-incident-001","consultation_id":"con-incident-001","patient_id":"pat-incident-001","status":"PENDING"}
{"timestamp":"2026-10-19T09:10:00.100Z","level":"WARN","service":"document-generation-api","version":"1.0.0","environment":"prod","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"e457b5a2e4d86bd1","correlation_id":"corr-incident-001","event":"document.storage.slow","message":"MinIO upload excedió el umbral esperado de latencia","duration_ms":3000,"document_id":"doc-incident-001","consultation_id":"con-incident-001","patient_id":"pat-incident-001","status":"GENERATING"}
{"timestamp":"2026-10-19T09:10:03.500Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"prod","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"e457b5a2e4d86bd2","correlation_id":"corr-incident-001","event":"document.storage.uploaded","message":"PDF guardado en MinIO después de una respuesta lenta","duration_ms":3000,"document_id":"doc-incident-001","consultation_id":"con-incident-001","patient_id":"pat-incident-001","status":"AVAILABLE"}
```

## SLI and Impact

The Availability SLI observed in the simulation fell to **98%**, below the 99.5% target. This consumes more Error Budget than allowed by the objective. Availability counts successful responses versus errors; a slow response that eventually completes successfully affects the latency SLI, but not the Availability SLI. Therefore, 98% is treated as the aggregate SLI observed for the period, not as a result derived solely from the 25% of slow uploads.

At 1,000 documents per day, the expected volume over 40 minutes is:

```text
1,000 / 1,440 × 40 ≈ 28 peticiones
28 × 25% ≈ 7 peticiones lentas
```

The slow fraction violates the latency objective of less than 2 seconds. Over a 30-day window, 98% Availability corresponds to a burn rate of `(1 - 0.98) / (1 - 0.995) = 4` and 600 errors out of 30,000 requests, compared with a budget of 150. This is 450 failed-request equivalents over budget. The time equivalent of 98% Availability is 864 minutes of total outage in 30 days, compared with the allowed 216 minutes.

## Alert

`DocumentGenerationFastBurn` fires at minute 10. The alert uses the error rate over a 1-hour window, a burn rate threshold of 14.4, and a 5-minute confirmation period. The 30-day observation of 98% and the short-window burn rate are different windows; the fast condition is triggered by the hourly error spike, not by the monthly average alone.

## Timeline

| Time | Event |
|---|---|
| 09:00 | MinIO begins responding slowly for 25% of PDF uploads. |
| 09:10 | `DocumentGenerationFastBurn` fires after the threshold is exceeded and the confirmation period elapses. |
| 09:12 | On-call confirms the latency increase and groups traces by `trace_id`. |
| 09:18 | RabbitMQ consumption is paused to contain pressure on MinIO. |
| 09:25 | The MinIO I/O bottleneck is identified; the storage team is engaged. |
| 09:35 | MinIO latency returns to normal; the queue and document statuses are checked. |
| 09:40 | Consumption resumes gradually; the 40-minute simulated incident window ends. |

## Root Cause and Contributing Factors

- **Root cause:** an I/O bottleneck in MinIO increased upload latency to 3 seconds for a portion of requests.
- **Contributing factors:** no circuit breaker on the storage path; insufficient MinIO capacity to absorb the spike; generation and upload coupled to worker processing; the latency alert did not fire before the burn rate alert.

## Blameless Postmortem: Action Items

### User Story 1 — Isolate MinIO Failures and Latency

As the `document-generation-api` team, we want a circuit breaker for MinIO so that a slow dependency does not block document generation.

**Acceptance criteria:**

- When MinIO latency or error rate exceeds configured thresholds, the circuit breaker opens and limits new uploads.
- Protected requests terminate with an observable status, and workers are not left blocked indefinitely.
- Circuit breaker state, rejected requests, and state transitions are logged with `trace_id` and have metrics and alerts.

### User Story 2 — Increase Storage Capacity

As the platform team, we want to add MinIO replicas and distribute I/O to support the expected PDF generation load.

**Acceptance criteria:**

- The replica topology and capacity are documented and validated with a representative load test.
- The test keeps upload p95 below 2 seconds at the target traffic of 1,000 documents per day.
- Losing one replica does not lose confirmed PDFs or leave documents in `GENERATING` indefinitely.

### User Story 3 — Alert on Latency and Queue Growth Before Budget Exhaustion

As the on-call engineer, I want alerts on upload latency and RabbitMQ growth so I can act before the burn rate reaches a critical level.

**Acceptance criteria:**

- MinIO latency and the size/age of pending messages are measured without high-cardinality labels.
- A test with 3-second MinIO latency on 25% of uploads triggers an actionable alert linked to the runbook.
- The runbook explains how to pause/resume consumers and verify that documents reach `AVAILABLE`.
