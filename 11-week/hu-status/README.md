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
| OBS-DG-01 | Golden signals of PDF generation | doing | [document-generation-api #26](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/26) |
| OBS-DG-04 | SLO burn-rate alerts with owner and runbook | doing | [infra-postgres #22](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/22) |
| OBS-DG-05 | Runbook for the likely incidents | doing | [docs #102](https://github.com/code-corhuila/telemed-ia-docs/pull/102) |
| OBS-DG-02 | One trace across services | todo | Specified in [docs #102](https://github.com/code-corhuila/telemed-ia-docs/pull/102) |
| OBS-DG-03 | Domain events in the logs | todo | Specified in [docs #102](https://github.com/code-corhuila/telemed-ia-docs/pull/102) |
| OBS-DG-06 | Pause switch for PDF generation | todo | Specified in [docs #102](https://github.com/code-corhuila/telemed-ia-docs/pull/102) |

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
- HU-16 backend, all merged:
  - PDF generation core, status store with outbox, PDFBox renderer;
  - Medical Consultation client and background generation with retries;
  - service token from the identity service.
  - Verified end to end with the real identity, medical consultation, PostgreSQL and RustFS services.

## 3. Blockers and risks
- Medical Consultation still has open issues, reported with evidence to its owner:
  - a patient can record an attention;
  - a duplicate attention answers 500 instead of 409;
  - internal errors expose SQL;
  - its Dockerfile uses Go 1.23 while `go.mod` needs Go 1.25.
- The infrastructure has no Alertmanager, so alerts are visible in Prometheus but not routed.
- The OpenTelemetry collector only exports traces to `debug`, so traces cannot be viewed yet (needed for OBS-DG-02).
- GitHub Actions cannot run because of the organization's billing limit. Every check was run locally and recorded in each PR.

## 4. Plan for next week
- OBS-DG-02: `traceparent` in and out, `traceId`/`spanId` on every log line, OTLP export to the collector.
- OBS-DG-03: domain events in the logs (`event`, `document_id`, `status`, `duration_ms`).
- OBS-DG-06: a pause switch for PDF generation.
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
- Workshop: [01-journey](../workshop/01-journey.md), [02-log-contract](../workshop/02-log-contract.md), [03-instrumentation](../workshop/03-instrumentation), [04-metrics](../workshop/04-metrics.md), [05-slo](../workshop/05-slo.md), [06-alerts.yml](../workshop/06-alerts.yml), [07-runbook](../workshop/07-runbook.md), [08-incident](../workshop/08-incident.md)
- Metrics in the API: https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/26
- SLO alerts in the infrastructure: https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/22
- SLOs, observability stories and runbook: https://github.com/code-corhuila/telemed-ia-docs/pull/102
- HU-16 backend: https://github.com/code-corhuila/telemed-ia-document-generation-api/pulls?q=is%3Apr+is%3Amerged
