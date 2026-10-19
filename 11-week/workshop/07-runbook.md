# Runbook — DocumentGenerationFastBurn

**Journey:** Generate Consultation Document

**Services and dependencies:** `api-gateway`, `document-generation-api`, PostgreSQL, RabbitMQ, and MinIO.

**Severity:** Critical.

## Symptoms

- PDF generation or retrieval latency increases.
- Publish/consume errors or pending messages in RabbitMQ increase.
- `DocumentGenerationFastBurn` fires and `document_generation_requests_total{status="error"}` increases.

## Confirmation

1. Check the error rate and compare it with the total request rate:

   ```promql
   sum(rate(document_generation_requests_total{status="error"}[5m]))
   /
   sum(rate(document_generation_requests_total[5m]))
   ```

2. Check the endpoint's p95 latency:

   ```promql
   histogram_quantile(0.95, sum by (le) (rate(document_generation_request_duration_seconds_bucket[5m])))
   ```

3. Check the queue size and confirm whether workers are draining messages:

   ```promql
   document_generation_worker_queue_size
   ```

4. Search the logs by `trace_id` for a failed request to follow it through `api-gateway`, `document-generation-api`, PostgreSQL, RabbitMQ, and MinIO. Do not search using personal data.

## Mitigations — Ordered by Risk

1. **Enable the feature flag to pause RabbitMQ consumption.** This reduces new operations against degraded dependencies and keeps messages in the queue. Monitor backlog growth and communicate the generation delay.
2. **Gradually scale `document-generation-api` workers.** Add a small number of replicas and observe MinIO latency and errors, PostgreSQL connections, and RabbitMQ draining. Stop scaling if pressure on a dependency increases.
3. **Restore the MinIO connection.** Only do this after confirming connections are blocked or invalid; renew the pool/connection and validate write and read operations. This action may interrupt in-progress uploads.

## Escalation

- Notify the `document-generation` owner and the platform/storage team if the burn rate remains above the threshold after the first mitigation.
- Escalate to the data owner if PostgreSQL shows latency, connection saturation, or status update failures.
- If budget consumption reaches 75% or 100%, apply the code freeze or resilience priority defined in the Error Budget policy.

## Recovery Verification

- Confirm that the burn rate is below the threshold and the error rate has returned to normal for at least 30 minutes.
- Verify that p95 is below 2 seconds again, the queue is shrinking, and documents reach `AVAILABLE` status.
- Verify that new PDFs are stored in and retrievable from MinIO; check that no failed messages remain without retries and no documents are stuck.
- Gradually disable the pause feature flag and monitor the same signals.
