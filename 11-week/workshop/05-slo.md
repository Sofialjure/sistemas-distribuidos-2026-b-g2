# SLOs and Error Budget — Generate Consultation Document

**Primary service:** `document-generation-api`

**Evaluation window:** 30 days

**Dependencies:** `api-gateway`, PostgreSQL (`document-generation-db`), RabbitMQ, and MinIO.

## Objectives and SLIs

| SLO | 30-day objective | SLI and PromQL |
|---|---:|---|
| Availability | 99.5% of requests complete without errors | `1 - (sum(increase(document_generation_requests_total{status="error"}[30d])) / sum(increase(document_generation_requests_total[30d])))` |
| Latency | 95% of requests take less than 2 seconds | `sum(increase(document_generation_request_duration_seconds_bucket{le="2"}[30d])) / sum(increase(document_generation_request_duration_seconds_count[30d]))` |
| Durability | 99.9% of PDFs are successfully stored in MinIO | `sum(increase(document_generation_pdf_uploads_total{status="success"}[30d])) / sum(increase(document_generation_pdf_uploads_total[30d]))` |

The request counter must include both `success` and `error` results. For durability, a PDF counts as successful when MinIO confirms it and it is persisted with status `AVAILABLE`.

## Traffic and Budget

At an estimated traffic level of **1,000 documents per day**, the expected volume over 30 days is:

```text
1,000 documentos/día × 30 días = 30,000 documentos/mes
```

For 99.5% Availability, the error budget is 0.5%:

```text
30,000 peticiones × 0.005 = 150 peticiones fallidas al mes
30 días × 24 horas × 60 minutos × 0.005 = 216 minutos de caída total equivalente
```

The 150 requests are the request-based budget; 216 minutes are the equivalent if the service experienced a total outage. These units are not interchangeable when only a portion of traffic fails.

## Error Budget Policy

- **50% consumed:** pause new feature work and prioritize reducing errors.
- **75% consumed:** freeze functional changes; allow only fixes and reliability work.
- **100% consumed:** the entire team prioritizes resilience until budget is recovered in the agreed window.
