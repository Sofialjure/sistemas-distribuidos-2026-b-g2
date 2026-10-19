# Log Contract: Generate Consultation Document

Each event is logged as a single-line JSON object. The required fields must be present in every service.

| Field | Required | Description |
|---|---|---|
| `timestamp` | Yes | UTC date and time in ISO 8601 format. |
| `level` | Yes | `ERROR`, `WARN`, `INFO`, or `DEBUG`. |
| `service` | Yes | Name of the emitting service or worker component. |
| `version` | Yes | Deployed service version. |
| `environment` | Yes | Runtime environment, such as `dev`, `qa`, or `prod`. |
| `trace_id` | Yes | Identifier shared by the spans in a trace. |
| `span_id` | Yes | Identifier of the span that records the event. |
| `correlation_id` | Yes | Identifier propagated between services and messages. |
| `event` | Yes | Stable event name for searches and alerts. |
| `message` | Yes | Brief summary without personal data or secrets. |
| `duration_ms` | Yes | Operation duration in milliseconds; `0` when not applicable. |
| `document_id` | Domain | Internal identifier of the generated document. |
| `consultation_id` | Domain | Internal identifier of the consultation. |
| `patient_id` | Domain | Internal patient identifier; do not log personal data. |
| `status` | Domain | Document status: `PENDING`, `GENERATING`, `AVAILABLE`, or `ERROR`. |

## Never log

- Patient personal data: names, identity documents, email addresses, phone numbers, addresses, or clinical data.
- Tokens, passwords, keys, cookies, credentials, or authorization headers.
- PDFs, consultation content, or complete request or message bodies that may contain personal data.

## Flow Examples

The five successful `INFO` lines use `trace_id` `trace-ok-111`. The two `ERROR` lines are a separate execution and use `trace_id` `trace-err-999`.

```json
{"timestamp":"2026-10-19T14:00:00.000Z","level":"INFO","service":"api-gateway","version":"1.0.0","environment":"dev","trace_id":"trace-ok-111","span_id":"00f067aa0ba902b7","correlation_id":"corr-document-ok-001","event":"document.request.received","message":"Solicitud de generación de documento recibida","duration_ms":0,"document_id":"doc-1042","consultation_id":"con-208","patient_id":"pat-17","status":"PENDING"}
{"timestamp":"2026-10-19T14:00:00.012Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-ok-111","span_id":"b9c7c989f97918e1","correlation_id":"corr-document-ok-001","event":"document.record.created","message":"Registro creado en estado pendiente","duration_ms":8,"document_id":"doc-1042","consultation_id":"con-208","patient_id":"pat-17","status":"PENDING"}
{"timestamp":"2026-10-19T14:00:00.030Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-ok-111","span_id":"e457b5a2e4d86bd1","correlation_id":"corr-document-ok-001","event":"document.summary.published","message":"Evento PostConsultationSummaryGenerated publicado","duration_ms":5,"document_id":"doc-1042","consultation_id":"con-208","patient_id":"pat-17","status":"PENDING"}
{"timestamp":"2026-10-19T14:00:00.045Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-ok-111","span_id":"e457b5a2e4d86bd2","correlation_id":"corr-document-ok-001","event":"document.generation.started","message":"Worker inició la generación del PDF","duration_ms":2,"document_id":"doc-1042","consultation_id":"con-208","patient_id":"pat-17","status":"GENERATING"}
{"timestamp":"2026-10-19T14:00:00.120Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-ok-111","span_id":"e457b5a2e4d86bd3","correlation_id":"corr-document-ok-001","event":"document.storage.uploaded","message":"PDF guardado en MinIO","duration_ms":75,"document_id":"doc-1042","consultation_id":"con-208","patient_id":"pat-17","status":"AVAILABLE"}
{"timestamp":"2026-10-19T14:01:00.000Z","level":"ERROR","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-err-999","span_id":"f457b5a2e4d86bd1","correlation_id":"corr-document-error-001","event":"document.storage.timeout","message":"Timeout al guardar el PDF en MinIO","duration_ms":5000,"document_id":"doc-2042","consultation_id":"con-308","patient_id":"pat-27","status":"ERROR"}
{"timestamp":"2026-10-19T14:01:05.140Z","level":"ERROR","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-err-999","span_id":"f457b5a2e4d86bd2","correlation_id":"corr-document-error-001","event":"document.status.invalid","message":"No se pudo actualizar el documento por estado inválido","duration_ms":3,"document_id":"doc-2042","consultation_id":"con-308","patient_id":"pat-27","status":"ERROR"}
```
