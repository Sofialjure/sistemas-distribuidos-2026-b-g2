# Runbook — DocumentGenerationFastBurn

**Flujo:** Generate Consultation Document  
**Servicios y dependencias:** `api-gateway`, `document-generation-api`, PostgreSQL, RabbitMQ y MinIO.  
**Severidad:** Critical.

## Síntomas

- Aumenta la latencia al generar o recuperar el PDF.
- Crecen los errores de publicación/consumo o los mensajes pendientes en RabbitMQ.
- Se dispara `DocumentGenerationFastBurn` y aumenta `document_generation_requests_total{status="error"}`.

## Confirmación

1. Verifica la tasa de errores y compárala con el total de solicitudes:

   ```promql
   sum(rate(document_generation_requests_total{status="error"}[5m]))
   /
   sum(rate(document_generation_requests_total[5m]))
   ```

2. Revisa la latencia p95 del endpoint:

   ```promql
   histogram_quantile(0.95, sum by (le) (rate(document_generation_request_duration_seconds_bucket[5m])))
   ```

3. Consulta el tamaño de la cola y confirma si los workers están drenando mensajes:

   ```promql
   document_generation_worker_queue_size
   ```

4. Busca logs por `trace_id` de una solicitud fallida para seguir `api-gateway`, `document-generation-api`, PostgreSQL, RabbitMQ y MinIO. No busques por datos personales.

## Mitigaciones — ordenadas por riesgo

1. **Activar el feature flag para pausar el consumo de RabbitMQ.** Reduce nuevas operaciones sobre dependencias degradadas y conserva los mensajes en la cola. Vigila el crecimiento de backlog y comunica el retraso de generación.
2. **Escalar los workers de `document-generation-api` gradualmente.** Añade pocas réplicas y observa latencia y errores de MinIO, conexiones PostgreSQL y drenaje de RabbitMQ. Detén el escalado si aumenta la presión sobre una dependencia.
3. **Restablecer la conexión con MinIO.** Solo después de confirmar conexiones bloqueadas o inválidas; renueva el pool/conexión y valida operaciones de escritura y lectura. Esta acción puede interrumpir cargas en curso.

## Escalamiento

- Avisa al responsable de `document-generation` y al equipo de plataforma/almacenamiento cuando el burn rate siga sobre el umbral tras la primera mitigación.
- Escala al responsable de datos si PostgreSQL presenta latencia, saturación de conexiones o fallos de actualización de estado.
- Si el presupuesto alcanza 75% o 100%, aplica el code freeze o la prioridad de resiliencia definidos en la política de Error Budget.

## Verificación de recuperación

- Confirma que el burn rate queda por debajo del umbral y la tasa de errores vuelve a su nivel normal durante al menos 30 minutos.
- Comprueba que p95 vuelve a estar por debajo de 2 segundos, la cola disminuye y los documentos terminan en estado `AVAILABLE`.
- Verifica en MinIO que los PDFs nuevos se guardan y pueden recuperarse; revisa que no queden mensajes fallidos sin reintento o documentos atascados.
- Desactiva el feature flag de pausa de forma gradual y vigila las mismas señales.
