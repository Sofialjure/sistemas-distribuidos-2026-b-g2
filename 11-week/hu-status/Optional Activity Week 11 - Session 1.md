# OPTIONAL ACTIVITY — Week 11 · Session 1

## Observability — logs, metrics and distributed tracing

> **Task of the week:** instrument your services: structured logs with a propagated
> `trace_id`, basic metrics (rate, errors, latency), and one distributed trace across a
> multi-service request.

The week 11 workshop of this fork (`11-week/workshop/`) practised the pattern on a small
Node.js service. This activity shows the same three pillars **in the real TeleMed IA
services I own**, running together on a production-like platform (the 28 repositories of
the project in containers, real identity tokens, PostgreSQL, RabbitMQ, Prometheus, Jaeger
and Grafana). Every log line, number and trace below was taken from that platform on
2026-10-27.

---

## 1. Monitoring vs observability, applied

| Question | Monitoring answers it? | How the services answer it |
|---|---|---|
| Is the professionals API up? | Yes (known question) | `GET /health`, and `GET /actuator/health` on the management port, which also checks PostgreSQL |
| Why was *this* list request slow? | No | The trace of that request shows which hop took the time (section 4) |
| Did registrations fail because of us or because identity was down? | No | The `outcome` label of `professional_registrations_total` and the domain event in the log (`unavailable` vs `failed`) |
| Which document generations are stuck, and since when? | No | `document.generation.*` events with `document_id`, `attempt` and `duration_ms` |

---

## 2. Pillar 1: structured logs with a propagated trace id

Both services write **one JSON object per line** (Elastic Common Schema), never free text.
Each line carries the `traceId` and `spanId` of the request, the `correlationId` that came in
`X-Correlation-Id` (or a new one), and named fields instead of sentences.

Real line, written by `professional-management-api` when an administrator activated a
profile (request sent with `X-Correlation-Id: w11-demo-ACTIVE`):

```json
{"@timestamp":"2026-10-28T02:26:25.903639723Z",
 "log":{"level":"INFO","logger":"co.edu.corhuila.telemedia.professionalmanagement.app.ObservedStatusChange"},
 "service":{"name":"telemed-ia-professional-management-api","version":"0.1.0-SNAPSHOT"},
 "message":"professional status changed",
 "traceId":"1a685cb4570624b3b2cd9e5bd2c0e48b","spanId":"e843d428b8708e97",
 "correlationId":"w11-demo-ACTIVE",
 "event":"professional.status.changed",
 "professional_id":"c2eeaebc-d793-4c8f-a02f-d01edaca0bef","status":"ACTIVE"}
```

### Log contract (what every domain event line must have)

| Field | Example | Why |
|---|---|---|
| `event` | `professional.registration.created`, `document.generation.failed` | Search and count by business event, not by message text |
| `traceId`, `spanId` | `1a685cb4…` | Jump from the log line to the trace |
| `correlationId` | `w11-demo-ACTIVE` | Follow the request across services; Document Generation also stores it in its outbox row and sends it as the AMQP `correlation_id` |
| entity ids | `professional_id`, `document_id` | Find every line of one entity |
| outcome fields | `status`, `attempt`, `duration_ms`, `reason` | Explain what happened without reading code |
| **never** | e-mail, names, password, token, clinical text | Logs are read by operators; health data stays out |

Events emitted by the two services:

- `professional.registration.created | replayed | rejected | unavailable | failed`
- `professional.status.changed | rejected | failed`
- `document.generation.started | available | retry_scheduled | failed | skipped | interrupted | deferred`

---

## 3. Pillar 2: metrics — the golden signals

Metrics are exposed by Micrometer on an **internal management port (9081)**, never published or
routed by the gateway, and scraped by Prometheus. No identifier is used as a label (bounded
cardinality).

| Golden signal | Professional Management | Document Generation |
|---|---|---|
| **Latency** | `http_server_requests_seconds` histogram, p95 of reads | `document_generation_attempts_seconds` histogram (buckets 0.1–5 s); freshness `document_generation_time_to_available_seconds` |
| **Traffic** | `rate(http_server_requests_seconds_count[5m])` | same, plus attempts per second |
| **Errors** | share of 5xx; `professional_registrations_total{outcome}` and `professional_status_changes_total{outcome}` | attempts by outcome (`available`, `retry`, `failed`) |
| **Saturation** | `hikaricp_connections_active` vs `hikaricp_connections_max` (10), request threads | `document_generation_in_flight`, pool connections |

Values read from Prometheus on the platform (through Grafana) after the end-to-end runs:

| Query | Result |
|---|---|
| `sum by (outcome) (professional_registrations_total)` | created 16, replayed 16, rejected 32, unavailable 654 |
| 5xx rate of `/api/professionals*` over 1h | 0 |
| `max(hikaricp_connections_max{application="professional-management-api"})` | 10 (active 0 at rest) |

The 654 `unavailable` registrations are the incident drill of Session 2 (identity stopped on
purpose). The metric separates "identity did not answer" from "our bug" (`failed`), which is
exactly the question an operator asks first.

---

## 4. Pillar 3: one distributed trace

Every service continues the W3C `traceparent` header it receives, and the outgoing HTTP clients
send it on (`MicrometerHttpClient`). Spans go over OTLP to the OpenTelemetry Collector, are
stored in Jaeger and are viewed in Grafana.

Real trace `63335a1f17f17e5f49ba7d4ced16a50c`, an administrator listing professionals (the list
shows the account names, which are read from Identity & Access):

```
trace 63335a1f17f17e5f49ba7d4ced16a50c                         start      duration
http get /api/professionals   (professional-management-api)     0.0 ms    508.5 ms
├─ HTTP POST  identity /internal/service-token                  339.9 ms   106.1 ms
└─ HTTP GET   identity /internal/accounts?ids=…                 450.0 ms    21.0 ms
```

What the trace tells without guessing: the request took 508 ms, and 106 ms of it was obtaining a
service token from identity. Because the token is cached for 10 minutes, this cost is paid once
per token, not on every list; the next requests only pay the 21 ms names call.

In Document Generation the trace also covers the background work: each generation attempt
is a **child span** of the `POST /api/documents/generate` request that queued it, and the
calls it makes to identity and Medical Consultation are child spans of the attempt. The
request's `correlationId` is stored in the `outbox_event` row and travels with
`ConsultationPdfGenerated` as the AMQP `correlation_id`.

---

## 5. Common mistakes avoided

| Mistake | How the services avoid it |
|---|---|
| Unstructured `print` logs | ECS JSON on every line; `System.out` is not used |
| No correlation/trace id | `traceparent` continued, `X-Correlation-Id` echoed and logged, ids on outbox events |
| Alerting on causes (CPU) | Alerts are on SLO burn rate (Session 2), CPU has no alert |
| Dashboards nobody reads | One dashboard per service, each panel tied to an SLO or a golden signal |

---

## 6. Evidence

| What | Where |
|---|---|
| Metrics and traces, Professional Management | [professional-management-api #48](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/48) |
| Domain events and outcome counters | [professional-management-api #50](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/50) |
| Metrics, Document Generation | [document-generation-api #26](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/26) |
| Trace across services | [document-generation-api #27](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/27), Jaeger and Grafana [infra-postgres #23](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/23) |
| Domain events, Document Generation | [document-generation-api #28](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/28) |
| Prometheus scrapes both services | [infra-postgres #22](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/22), [#27](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/27), [#31](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/31) |

---

## 7. Self-check

| # | Question | Answer |
|---|---|---|
| 1 | The three pillars of observability are… | Logs, metrics and traces |
| 2 | A distributed trace… | Follows one request across services as timed spans |
| 3 | A correlation/trace ID must be… | Generated at the edge and propagated to every service |
| 4 | Logs should be… | Structured (JSON) with `trace_id` and fields |
| 5 | The golden signals are… | Latency, traffic, errors, saturation |
| 6 | To find a slow cross-service request you use… | A trace (spans show which hop is slow) |
