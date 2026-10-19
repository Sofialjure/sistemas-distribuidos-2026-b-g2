# Métricas: document-generation-api

## Golden Signals

| Golden Signal | Métrica Prometheus | Tipo | Consulta PromQL |
|---|---|---|---|
| Latencia | `document_generation_request_duration_seconds` | Histograma | `histogram_quantile(0.95, sum by (le) (rate(document_generation_request_duration_seconds_bucket[5m])))` |
| Errores | `document_generation_requests_total` con `status="error"` | Contador | `sum(rate(document_generation_requests_total{status="error"}[5m]))` |
| Tráfico | `document_generation_requests_total` | Contador | `sum(rate(document_generation_requests_total[5m]))` |
| Saturación | `document_generation_worker_queue_size` | Gauge | `max(document_generation_worker_queue_size)` |

La métrica de saturación alternativa es el uso del pool de conexiones a PostgreSQL, si se instrumenta como gauge.

## Cardinalidad de labels

Mantén acotado el conjunto de valores de cada label. No uses `patient_id`, `consultation_id` ni `document_id` como labels porque cada identificador crearía series nuevas. Usa labels controladas como `status`, `route` y `method`.

## Buckets del histograma

Configura los límites de `document_generation_request_duration_seconds` en segundos: `0.1`, `0.5`, `1`, `2` y `5`. Prometheus agrega el bucket infinito `+Inf` automáticamente.

