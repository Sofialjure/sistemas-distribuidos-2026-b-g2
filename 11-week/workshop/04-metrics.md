# Métricas: appointment-scheduling-api

## Golden Signals

| Golden Signal | Métrica Prometheus | Tipo | Uso |
|---|---|---|---|
| Latencia | `appointment_request_duration_seconds` | Histograma | Duración de las solicitudes de agenda en segundos. |
| Tráfico | `appointment_requests_total` | Contador | Solicitudes recibidas, segmentadas por ruta y método cuando se necesite. |
| Errores | `appointment_errors_total` | Contador | Solicitudes que terminan con error, segmentadas por tipo controlado y ruta. |
| Saturación | `appointment_inflight_requests` | Gauge | Solicitudes concurrentes actualmente en procesamiento. |

## Consultas PromQL

Latencia p95 en una ventana de cinco minutos:

```promql
histogram_quantile(0.95, sum by (le) (rate(appointment_request_duration_seconds_bucket[5m])))
```

Tasa de errores sobre solicitudes en una ventana de cinco minutos:

```promql
sum(rate(appointment_errors_total[5m])) / sum(rate(appointment_requests_total[5m]))
```

## Cardinalidad de labels

Mantén bajo y acotado el número de valores posibles por label. Se prohíbe `patient_id` como label porque genera una serie temporal por paciente y hace crecer la cardinalidad sin límite práctico. Usa labels controladas como `status`, `route` y `method`; evita también IDs de citas, profesionales y mensajes.

## Buckets del histograma

Configura los límites del histograma en segundos: `0.1`, `0.5`, `1`, `2` y `5`. Prometheus agrega el bucket infinito `+Inf` automáticamente.
