# Contrato de logs: Generate Consultation Document

Cada evento se registra como un objeto JSON en una sola línea. Los campos obligatorios deben estar presentes en todos los servicios.

| Campo | Obligatorio | Descripción |
|---|---|---|
| `timestamp` | Sí | Fecha y hora UTC en formato ISO 8601. |
| `level` | Sí | `ERROR`, `WARN`, `INFO` o `DEBUG`. |
| `service` | Sí | Nombre del servicio emisor o componente worker. |
| `version` | Sí | Versión desplegada del servicio. |
| `environment` | Sí | Entorno de ejecución, por ejemplo `dev`, `qa` o `prod`. |
| `trace_id` | Sí | Identificador compartido por los spans de una traza. |
| `span_id` | Sí | Identificador del span que registra el evento. |
| `correlation_id` | Sí | Identificador propagado entre servicios y mensajes. |
| `event` | Sí | Nombre estable del evento para búsquedas y alertas. |
| `message` | Sí | Resumen breve, sin datos personales ni secretos. |
| `duration_ms` | Sí | Duración de la operación en milisegundos; `0` cuando no aplica. |
| `document_id` | Dominio | Identificador interno del documento generado. |
| `consultation_id` | Dominio | Identificador interno de la consulta. |
| `patient_id` | Dominio | Identificador interno del paciente; no registrar datos personales. |
| `status` | Dominio | Estado del documento: `PENDING`, `GENERATING`, `AVAILABLE` o `ERROR`. |

## Never log

- Datos personales del paciente: nombres, documentos, correos, teléfonos, direcciones o datos clínicos.
- Tokens, contraseñas, claves, cookies, credenciales o headers de autorización.
- PDF, contenido de la consulta, cuerpos completos de solicitudes o mensajes que puedan incluir datos personales.

## Ejemplos del flujo

Las cinco líneas `INFO` de éxito usan `trace_id` `trace-ok-111`. Las dos líneas `ERROR` son una ejecución separada y usan `trace_id` `trace-err-999`.

```json
{"timestamp":"2026-10-19T14:00:00.000Z","level":"INFO","service":"api-gateway","version":"1.0.0","environment":"dev","trace_id":"trace-ok-111","span_id":"00f067aa0ba902b7","correlation_id":"corr-document-ok-001","event":"document.request.received","message":"Solicitud de generación de documento recibida","duration_ms":0,"document_id":"doc-1042","consultation_id":"con-208","patient_id":"pat-17","status":"PENDING"}
{"timestamp":"2026-10-19T14:00:00.012Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-ok-111","span_id":"b9c7c989f97918e1","correlation_id":"corr-document-ok-001","event":"document.record.created","message":"Registro creado en estado pendiente","duration_ms":8,"document_id":"doc-1042","consultation_id":"con-208","patient_id":"pat-17","status":"PENDING"}
{"timestamp":"2026-10-19T14:00:00.030Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-ok-111","span_id":"e457b5a2e4d86bd1","correlation_id":"corr-document-ok-001","event":"document.summary.published","message":"Evento PostConsultationSummaryGenerated publicado","duration_ms":5,"document_id":"doc-1042","consultation_id":"con-208","patient_id":"pat-17","status":"PENDING"}
{"timestamp":"2026-10-19T14:00:00.045Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-ok-111","span_id":"e457b5a2e4d86bd2","correlation_id":"corr-document-ok-001","event":"document.generation.started","message":"Worker inició la generación del PDF","duration_ms":2,"document_id":"doc-1042","consultation_id":"con-208","patient_id":"pat-17","status":"GENERATING"}
{"timestamp":"2026-10-19T14:00:00.120Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-ok-111","span_id":"e457b5a2e4d86bd3","correlation_id":"corr-document-ok-001","event":"document.storage.uploaded","message":"PDF guardado en MinIO","duration_ms":75,"document_id":"doc-1042","consultation_id":"con-208","patient_id":"pat-17","status":"AVAILABLE"}
{"timestamp":"2026-10-19T14:01:00.000Z","level":"ERROR","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-err-999","span_id":"f457b5a2e4d86bd1","correlation_id":"corr-document-error-001","event":"document.storage.timeout","message":"Timeout al guardar el PDF en MinIO","duration_ms":5000,"document_id":"doc-2042","consultation_id":"con-308","patient_id":"pat-27","status":"ERROR"}
{"timestamp":"2026-10-19T14:01:05.140Z","level":"ERROR","service":"document-generation-api","version":"1.0.0","environment":"dev","trace_id":"trace-err-999","span_id":"f457b5a2e4d86bd2","correlation_id":"corr-document-error-001","event":"document.status.invalid","message":"No se pudo actualizar el documento por estado inválido","duration_ms":3,"document_id":"doc-2042","consultation_id":"con-308","patient_id":"pat-27","status":"ERROR"}
```
