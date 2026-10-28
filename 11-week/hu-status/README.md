<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.
     Your weekly grade is read AUTOMATICALLY from this file:
       11-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 11

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->
- FULL_NAME: María Sofía Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Make the Generate Consultation Document journey observable in TeleMed IA: golden-signal metrics, SLOs with an error budget, symptom-based burn-rate alerts with owner and runbook, and observability stories with testable acceptance criteria, on top of the PDF generation finished this week.
<!-- CONFIG-END -->

## 1. User stories worked this week
| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| HU-16 | Download Consultation Summary as PDF | doing | Backend done and merged: [API #20](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/20), [#21](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/21), [#22](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/22), [#23](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/23), [#24](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/24), [#25](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/25). The portal still uses synthetic data. |
| OBS-DG-01 | Golden signals of PDF generation | done | [document-generation-api #26](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/26), dashboard [infra-postgres #25](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/25) |
| OBS-DG-02 | One trace across services | done | [document-generation-api #27](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/27), traces in Jaeger and Grafana [infra-postgres #23](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/23) |
| OBS-DG-03 | Domain events in the logs | done | [document-generation-api #28](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/28) |
| OBS-DG-04 | SLO burn-rate alerts with owner and runbook | done | [infra-postgres #22](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/22), routed by Alertmanager [infra-postgres #24](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/24) |
| OBS-DG-05 | Runbook for the likely incidents | done | [docs #102](https://github.com/code-corhuila/telemed-ia-docs/pull/102), [#103](https://github.com/code-corhuila/telemed-ia-docs/pull/103), [#104](https://github.com/code-corhuila/telemed-ia-docs/pull/104), [#105](https://github.com/code-corhuila/telemed-ia-docs/pull/105) |
| OBS-DG-06 | Pause switch for PDF generation | done | [document-generation-api #29](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/29) |

## 2. My individual contribution
- Week 11 workshop (D1 and D2), in [11-week/workshop](../workshop):
  - critical journey and trace (CP1), log contract (CP2);
  - Node.js trace propagation with an automated test (CP3);
  - golden signals (CP4), SLOs and error budget (CP6);
  - burn-rate alerts (CP7), runbook (CP8);
  - simulated MinIO latency incident with a blameless postmortem (CP9).
- Workshop commits:
  - CP0 `da7261f`, CP1 `11419f5`, CP2 `9b55eea`;
  - CP3 `77fa828` and `9c32425`, CP4 `6d162dc`, CP5 `5391ce6`;
  - CP6 `a442619`, CP7 `b0d45d7`, CP8 `a5a223b`, CP9 `e6f315f`.
- The workshop applied to the real project, adapted to how the system actually works:
  - Java/Spring instead of Node.js;
  - background generation inside the API instead of a RabbitMQ worker;
  - RustFS instead of MinIO;
  - a shared PostgreSQL instance.
- Metrics (OBS-DG-01, API #26), with Micrometer on an internal management port:
  - attempts by outcome, with latency buckets 0.1–5 s;
  - freshness, from the request until the PDF is available;
  - documents in flight;
  - HTTP metrics;
  - no identifiers as labels.
- SLOs over 30 days (docs #102):
  - availability: 99.5% of documents end AVAILABLE;
  - latency: 95% of attempts under 2 s;
  - freshness: 95% of PDFs within 60 s;
  - error budget of 150 documents per month, with a 50/75/100% policy.
- Alerts (OBS-DG-04, infra #22):
  - fast burn (14.4 over 1h) and slow burn (6 over 6h), plus freshness;
  - each one with severity, owner and runbook;
  - unit-tested with `promtool test rules`, and verified live in Prometheus.
- Runbook (OBS-DG-05, docs #102): confirmation queries, mitigations, escalation and recovery for each alert.
- Distributed trace (OBS-DG-02, API #27, infra #23):
  - W3C `traceparent` continued from the request and sent to identity and Medical Consultation;
  - each background attempt is a child span of its request;
  - `traceId` and `spanId` on every log line;
  - spans exported over OTLP to the collector, stored in Jaeger and viewed in Grafana.
- Domain events in the logs (OBS-DG-03, API #28): `document.generation.started`, `available`, `retry_scheduled`, `failed`, with `document_id`, `status`, `duration_ms` and `attempt`.
- Pause switch (OBS-DG-06, API #29): pauses PDF generation without stopping the service, so no retry is spent while a dependency is down; gauge `document_generation_paused`.
- Alertmanager (infra #24): groups the alerts, routes them by severity and suppresses the slow burn while the fast burn fires; alerts are viewed in Grafana.
- Grafana dashboard (infra #25): SLOs, error budget, burn rate and golden signals, provisioned from a versioned file and checked against a real Prometheus.
- HU-16 backend, all merged:
  - PDF generation core, status store with outbox, PDFBox renderer;
  - Medical Consultation client and background generation with retries;
  - service token from the identity service.
  - Verified end to end with the real identity, medical consultation, PostgreSQL and RustFS services.

### Week 11 - Session 1 - Optional Activity

Observability (logs, metrics and distributed tracing) shown in the real services I own, on the platform running all the TeleMed IA services in containers:

- one JSON log line per event with `traceId`, `spanId` and `correlationId`, and a log contract with the domain events of both services (no personal or clinical data);
- the golden signals mapped to real metrics on the internal management port, with values read from Prometheus;
- a real trace from Jaeger: a list of professionals of 508 ms, of which 106 ms were the service-token call to identity and 21 ms the names call.

See: [Week 11 - Session 1 - Optional Activity](Optional%20Activity%20Week%2011%20-%20Session%201.md)

### Week 11 - Session 2 - Optional Activity

SLOs, error budget, alerting and runbook for Professional Management and Document Generation:

- SLOs over 30 days: availability 99.5% and read latency (95% within 500 ms) for professionals; availability, latency and freshness for documents;
- error budget (750 requests or 216 minutes a month for professionals; 150 documents for PDFs) and a 50/75/100% policy;
- multi-window burn-rate alerts with severity, owner and runbook, unit-tested with `promtool`, routed by Alertmanager;
- a runbook for the likely incident (identity down) and the observability stories with Given/When/Then criteria;
- a drill: identity stopped for 2.5 minutes, the 1h burn rate reached 168 and the page fired after 5 minutes.

See: [Week 11 - Session 2 - Optional Activity](Optional%20Activity%20Week%2011%20-%20Session%202.md)

### Group contribution

- **Juliana (@JulianaFerro1428):**
  - service tokens for service-to-service calls (identity-and-access-api #117), which my Document Generation API uses to read Medical Consultation;
  - identity publishes only its management port and answers `400` to a malformed body (#118, #119), two issues I reported with evidence;
  - the intelligent agent end to end: persistence in agent-db, outbox in the same transaction, HTTP endpoints, appointment check with the patient's token, idempotent start (intelligent-agent-api #12 to #27), and its portal on the real API (intelligent-agent-portal #39 to #43);
  - the week 11 structured logs and metrics of the agent (intelligent-agent-api #28, #29) and its gateway route (api-gateway #13).
- **José Miguel (@BondrewdXD):**
  - Medical Consultation identifiers moved to UUID (medical-consultation-api #8, medical-consultation-db #5), which unblocked my PDF generation;
  - roles and the `followUp` contract (#9), and three QA rounds (#10, #12, #13) on the issues I found in the end-to-end runs;
  - Prometheus metrics for Medical Consultation (#11, infra-postgres #21) and the grants that let its migrations run on the shared instance (infra-postgres #19);
  - appointment slot conflicts in database, API, portal and docs (appointment-scheduling-db #5, appointment-scheduling-api #16, appointment-scheduling-portal #18, docs #100);
  - ADR-022 on service-to-service authentication (docs #101).
- **My part in the team work:** I ran the cross-service journey (identity → Medical Consultation → Document Generation → RustFS) after each of their changes and reported every reproducible failure with its request and log line.

## 3. Blockers and risks
- Medical Consultation fixed most of the issues reported with evidence. Still open, reported to its owner:
  - a duplicate attention or post summary answers 500 instead of 409;
  - internal errors and the `X-Correlation-Id` are not written to its log;
  - no new tests for roles, conflicts or the transaction.
- Jaeger keeps traces in memory, so they are lost when it restarts; enough for development.
- GitHub Actions cannot run because of the organization's billing limit. Every check was run locally and recorded in each PR.

## 4. Plan for next week
- Contract tests of Anexo C (numeral 5.3.12) for `telemed-ia-document-generation-api`.
- Connect the Document Generation portal to the real API through the shared `apiClient`.
- Run the end-to-end check again once Medical Consultation fixes its open issues.

## 5. Compliance self-check
- [x] Conventional Commits - `type(scope): summary`
- [x] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [x] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links
- Optional activities: [Session 1](Optional%20Activity%20Week%2011%20-%20Session%201.md), [Session 2](Optional%20Activity%20Week%2011%20-%20Session%202.md)
- Scripts used in the optional activities: [scripts](scripts/README.md)
- Workshop: [01-journey](../workshop/01-journey.md), [02-log-contract](../workshop/02-log-contract.md), [03-instrumentation](../workshop/03-instrumentation), [04-metrics](../workshop/04-metrics.md), [05-slo](../workshop/05-slo.md), [06-alerts.yml](../workshop/06-alerts.yml), [07-runbook](../workshop/07-runbook.md), [08-incident](../workshop/08-incident.md)
- Metrics in the API: https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/26
- SLO alerts in the infrastructure: https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/22
- SLOs, observability stories and runbook: https://github.com/code-corhuila/telemed-ia-docs/pull/102
- Distributed trace: https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/27 and https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/23
- Domain events in the logs: https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/28
- Pause switch: https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/29
- Alertmanager: https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/24
- Grafana dashboard: https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/25
- HU-16 backend: https://github.com/code-corhuila/telemed-ia-document-generation-api/pulls?q=is%3Apr+is%3Amerged
