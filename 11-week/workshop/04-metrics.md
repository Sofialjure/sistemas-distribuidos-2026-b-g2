# Métricas: document-generation-api

## Golden Signals

| Golden Signal | Prometheus Metric | Type | PromQL Query |
|---|---|---|---|
| Latency | `document_generation_request_duration_seconds` | Histogram | `histogram_quantile(0.95, sum by (le) (rate(document_generation_request_duration_seconds_bucket[5m])))` |
| Errors | `document_generation_requests_total` with `status="error"` | Counter | `sum(rate(document_generation_requests_total{status="error"}[5m]))` |
| Traffic | `document_generation_requests_total` | Counter | `sum(rate(document_generation_requests_total[5m]))` |
| Saturation | `document_generation_worker_queue_size` | Gauge | `max(document_generation_worker_queue_size)` |

An alternative saturation metric is PostgreSQL connection pool usage, if instrumented as a gauge.

## Label Cardinality

Keep the set of values for each label bounded. Do not use `patient_id`, `consultation_id`, or `document_id` as labels because each identifier would create a new time series. Use controlled labels such as `status`, `route`, and `method`.

## Histogram Buckets

Configure the `document_generation_request_duration_seconds` boundaries in seconds: `0.1`, `0.5`, `1`, `2`, and `5`. Prometheus automatically adds the `+Inf` bucket.

