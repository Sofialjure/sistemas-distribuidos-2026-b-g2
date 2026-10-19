# Contrato de logs: Schedule Appointment

Cada evento se registra como un objeto JSON en una sola línea. Los campos marcados como obligatorios deben estar presentes en todos los servicios.

| Campo | Obligatorio | Descripción |
|---|---|---|
| `timestamp` | Sí | Fecha y hora UTC en formato ISO 8601. |
| `level` | Sí | `ERROR`, `WARN`, `INFO` o `DEBUG`. |
| `service` | Sí | Nombre real del servicio emisor. |
| `version` | Sí | Versión desplegada del servicio. |
| `environment` | Sí | Entorno de ejecución, por ejemplo `dev`, `qa` o `prod`. |
| `trace_id` | Sí | Identificador compartido por los spans de una traza. |
| `span_id` | Sí | Identificador del span que registra el evento. |
| `correlation_id` | Sí | Identificador de correlación propagado entre servicios y mensajes. |
| `event` | Sí | Nombre estable del evento para búsquedas y alertas. |
| `message` | Sí | Resumen breve, sin datos personales ni secretos. |
| `duration_ms` | Sí | Duración de la operación en milisegundos; `0` cuando no aplica. |
| `appointment_id` | Dominio | Identificador interno de la cita. |
| `patient_id` | Dominio | Identificador interno del paciente; nunca incluir datos personales. |
| `professional_id` | Dominio | Identificador interno del profesional. |
| `status` | Dominio | Estado de la cita o resultado de la operación. |

## Never log

- Datos personales del paciente o profesional: nombres, documentos, correos, teléfonos, direcciones o datos clínicos.
- Tokens, contraseñas, claves, cookies, credenciales o headers de autorización.
- Cuerpos completos de solicitudes o mensajes que puedan incluir los datos anteriores.

## Niveles

- `ERROR`: una operación falla y requiere atención, como un timeout de dependencia o una regla de negocio que impide completar la solicitud.
- `WARN`: condición inesperada o recuperable que no detiene el flujo, como un reintento o una dependencia degradada.
- `INFO`: hitos relevantes del flujo, como solicitud recibida, cita creada o notificación publicada.
- `DEBUG`: detalles técnicos para diagnóstico temporal; deshabilitar o reducir en producción.

## Ejemplos

```json
{"timestamp":"2026-10-19T14:00:00.000Z","level":"INFO","service":"api-gateway","version":"1.0.0","environment":"dev","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"00f067aa0ba902b7","correlation_id":"corr-appointment-001","event":"http.request.received","message":"Solicitud de creación de cita recibida","duration_ms":0,"appointment_id":"apt-1042","patient_id":"pat-208","professional_id":"pro-77","status":"received"}
{"timestamp":"2026-10-19T14:00:00.012Z","level":"INFO","service":"appointment-scheduling-api","version":"1.0.0","environment":"dev","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"b9c7c989f97918e1","correlation_id":"corr-appointment-001","event":"appointment.validation.started","message":"Validación de solicitud iniciada","duration_ms":2,"appointment_id":"apt-1042","patient_id":"pat-208","professional_id":"pro-77","status":"validating"}
{"timestamp":"2026-10-19T14:00:00.038Z","level":"INFO","service":"professional-management-api","version":"1.0.0","environment":"dev","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"00f067aa0ba902b7","correlation_id":"corr-appointment-001","event":"professional.availability.checked","message":"Disponibilidad del profesional consultada","duration_ms":24,"appointment_id":"apt-1042","patient_id":"pat-208","professional_id":"pro-77","status":"available"}
{"timestamp":"2026-10-19T14:00:00.045Z","level":"ERROR","service":"appointment-scheduling-api","version":"1.0.0","environment":"dev","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"b9c7c989f97918e1","correlation_id":"corr-appointment-001","event":"professional.availability.timeout","message":"Timeout al consultar disponibilidad del profesional","duration_ms":5000,"appointment_id":"apt-1042","patient_id":"pat-208","professional_id":"pro-77","status":"dependency_timeout"}
{"timestamp":"2026-10-19T14:00:00.120Z","level":"ERROR","service":"appointment-scheduling-api","version":"1.0.0","environment":"dev","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"b9c7c989f97918e1","correlation_id":"corr-appointment-001","event":"appointment.business_rule.rejected","message":"La solicitud incumple una regla de negocio","duration_ms":8,"appointment_id":"apt-1042","patient_id":"pat-208","professional_id":"pro-77","status":"rejected"}
{"timestamp":"2026-10-19T14:00:00.150Z","level":"INFO","service":"appointment-scheduling-api","version":"1.0.0","environment":"dev","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"b9c7c989f97918e1","correlation_id":"corr-appointment-001","event":"appointment.created","message":"Cita creada correctamente","duration_ms":138,"appointment_id":"apt-1042","patient_id":"pat-208","professional_id":"pro-77","status":"scheduled"}
{"timestamp":"2026-10-19T14:00:00.160Z","level":"INFO","service":"notification-service","version":"1.0.0","environment":"dev","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"e457b5a2e4d86bd1","correlation_id":"corr-appointment-001","event":"notification.appointment_scheduled.queued","message":"Notificación de cita aceptada para procesamiento","duration_ms":4,"appointment_id":"apt-1042","patient_id":"pat-208","professional_id":"pro-77","status":"queued"}
```
