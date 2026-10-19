# Incidente simulado — Lentitud de MinIO

**Flujo:** Generate Consultation Document  
**Ventana del incidente:** 40 minutos.  
**Escenario:** MinIO tarda 3 segundos en responder en el 25% de las peticiones.

## Span Tree de una petición afectada

- Root Span: `POST /api/v1/documents` — `api-gateway` (**3500 ms**)
  - Child Span: `document-generation-api POST /api/v1/documents`
    - Child Span: `document-generation-db INSERT status=PENDING` — PostgreSQL (**50 ms**)
    - Child Span: `Upload PDF` — MinIO (**3000 ms**)

El tiempo restante del span raíz incluye validación, publicación/consumo y procesamiento dentro de `document-generation-api`.

## Logs de una traza afectada

Las cuatro líneas comparten `trace_id` y muestran la demora en MinIO hasta completar la carga.

```json
{"timestamp":"2026-10-19T09:10:00.000Z","level":"WARN","service":"api-gateway","version":"1.0.0","environment":"prod","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"00f067aa0ba902b7","correlation_id":"corr-incident-001","event":"document.request.received","message":"Solicitud de documento iniciada","duration_ms":0,"document_id":"doc-incident-001","consultation_id":"con-incident-001","patient_id":"pat-incident-001","status":"GENERATING"}
{"timestamp":"2026-10-19T09:10:00.050Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"prod","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"b9c7c989f97918e1","correlation_id":"corr-incident-001","event":"document.record.created","message":"Registro PENDING guardado en PostgreSQL","duration_ms":50,"document_id":"doc-incident-001","consultation_id":"con-incident-001","patient_id":"pat-incident-001","status":"PENDING"}
{"timestamp":"2026-10-19T09:10:00.100Z","level":"WARN","service":"document-generation-api","version":"1.0.0","environment":"prod","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"e457b5a2e4d86bd1","correlation_id":"corr-incident-001","event":"document.storage.slow","message":"MinIO upload excedió el umbral esperado de latencia","duration_ms":3000,"document_id":"doc-incident-001","consultation_id":"con-incident-001","patient_id":"pat-incident-001","status":"GENERATING"}
{"timestamp":"2026-10-19T09:10:03.500Z","level":"INFO","service":"document-generation-api","version":"1.0.0","environment":"prod","trace_id":"4bf92f3577b34da6a3ce929d0e0e4736","span_id":"e457b5a2e4d86bd2","correlation_id":"corr-incident-001","event":"document.storage.uploaded","message":"PDF guardado en MinIO después de una respuesta lenta","duration_ms":3000,"document_id":"doc-incident-001","consultation_id":"con-incident-001","patient_id":"pat-incident-001","status":"AVAILABLE"}
```

## SLI e impacto

El SLI de disponibilidad observado en la simulación bajó a **98%** frente al objetivo de 99.5%. Esto consume más Error Budget que el objetivo permite. Availability cuenta respuestas exitosas frente a errores; una respuesta lenta que finalmente termina correctamente afecta el SLI de latencia, pero no el de disponibilidad. Por eso, el 98% se trata como el SLI agregado observado del periodo, no como un resultado derivado solo del 25% de cargas lentas.

Con 1,000 documentos por día, el volumen esperado en 40 minutos es:

```text
1,000 / 1,440 × 40 ≈ 28 peticiones
28 × 25% ≈ 7 peticiones lentas
```

La fracción lenta incumple el objetivo de latencia de menos de 2 segundos. En una ventana de 30 días, availability de 98% equivale a un burn rate de `(1 - 0.98) / (1 - 0.995) = 4` y 600 errores sobre 30,000 peticiones, frente a un presupuesto de 150. El exceso frente al presupuesto es 450 peticiones fallidas equivalentes. El equivalente temporal de 98% de disponibilidad es 864 minutos de caída total en 30 días, comparado con 216 minutos permitidos.

## Alerta

Se dispara `DocumentGenerationFastBurn` en el minuto 10. La alerta usa la tasa de errores de una ventana de 1 hora, umbral de burn rate 14.4 y confirmación de 5 minutos. La observación del 98% a 30 días y el burn rate de una ventana corta son ventanas distintas; la condición rápida se activa por el pico de errores de la hora, no por el promedio mensual aislado.

## Línea de tiempo

| Tiempo | Evento |
|---|---|
| 09:00 | Comienza la respuesta lenta de MinIO en 25% de las cargas de PDF. |
| 09:10 | `DocumentGenerationFastBurn` se dispara tras superar el umbral y cumplir la confirmación. |
| 09:12 | On-call confirma el aumento de latencia y agrupa trazas por `trace_id`. |
| 09:18 | Se pausa el consumo de RabbitMQ para contener la presión sobre MinIO. |
| 09:25 | Se identifica el cuello de botella de I/O en MinIO; se escala al equipo de almacenamiento. |
| 09:35 | MinIO recupera latencia normal; se valida la cola y el estado de documentos. |
| 09:40 | Se reanuda gradualmente el consumo; termina la ventana simulada de 40 minutos. |

## Causa raíz y factores contribuyentes

- **Causa raíz:** cuello de botella de I/O en MinIO que elevó a 3 segundos la latencia de carga para parte de las peticiones.
- **Factores contribuyentes:** falta de un circuit breaker en la ruta de almacenamiento; capacidad de MinIO insuficiente para absorber el pico; generación y carga acopladas al procesamiento del worker; alerta de latencia no disparó antes que la alerta de burn rate.

## Postmortem sin culpables: acciones

### User Story 1 — Aislar fallos y lentitud de MinIO

Como equipo de `document-generation-api`, queremos un circuit breaker para MinIO para evitar que una dependencia lenta bloquee la generación de documentos.

**Criterios de aceptación:**

- Cuando la latencia o tasa de errores de MinIO supera umbrales configurados, el circuit breaker pasa a estado abierto y limita nuevas cargas.
- Las solicitudes protegidas terminan con estado observable y no quedan workers bloqueados indefinidamente.
- El estado del circuit breaker, los rechazos y las transiciones se registran con `trace_id` y tienen métricas y alertas.

### User Story 2 — Aumentar capacidad de almacenamiento

Como equipo de plataforma, queremos agregar réplicas de MinIO y distribuir I/O para sostener la carga esperada de generación de PDFs.

**Criterios de aceptación:**

- La topología y capacidad de réplicas se documentan y se validan con una prueba de carga representativa.
- La prueba mantiene el p95 de carga por debajo de 2 segundos para el tráfico objetivo de 1,000 documentos por día.
- La pérdida de una réplica no causa pérdida de PDFs confirmados ni deja documentos indefinidamente en `GENERATING`.

### User Story 3 — Alertar sobre latencia y cola antes del agotamiento

Como on-call, quiero alertas sobre latencia de carga y crecimiento de RabbitMQ para actuar antes de que el burn rate llegue a nivel crítico.

**Criterios de aceptación:**

- Se mide la latencia de MinIO y el tamaño/edad de mensajes pendientes sin labels de alta cardinalidad.
- Una prueba con latencia de MinIO de 3 segundos en 25% de las cargas activa una alerta accionable y enlazada al runbook.
- El runbook indica cómo pausar/reanudar consumidores y cómo verificar que los documentos terminan en `AVAILABLE`.
