<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.
     Your weekly grade is read AUTOMATICALLY from this file:
       14-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 14

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->
- FULL_NAME: María Sofía Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Close Professional Management and Document Generation: record the week 11 observability decisions, merge the week 13 threat model, start the whole platform from scratch with `develop` of every repository to verify both services end to end (including the worker), and bring the shared documentation in line with the running platform.
<!-- CONFIG-END -->

## 1. User stories worked this week
| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| HU-05 | User and Healthcare Professional Management (professional profiles, FR-011) | done | Observability decisions [docs #162](https://github.com/code-corhuila/telemed-ia-docs/pull/162); implemented state and ER diagram [docs #163](https://github.com/code-corhuila/telemed-ia-docs/pull/163), [docs #164](https://github.com/code-corhuila/telemed-ia-docs/pull/164); requirements verified end to end [docs #167](https://github.com/code-corhuila/telemed-ia-docs/pull/167) |
| HU-16 | Download Consultation Summary as PDF | done | Observability decisions [docs #161](https://github.com/code-corhuila/telemed-ia-docs/pull/161); threat model [docs #144](https://github.com/code-corhuila/telemed-ia-docs/pull/144); ER, state and sequence diagrams [docs #164](https://github.com/code-corhuila/telemed-ia-docs/pull/164); contract copies synced [document-generation-api #57](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/57) |

## 2. My individual contribution
- Individual work:
  - **Week 11 observability decisions recorded** (docs #161, #162, approved by Juliana): DEC-010 to DEC-014 of the Document Service and DEC-011 to DEC-014 of the Professional Service, each with its context, decision, consequences and the PRs that implemented it (traces over OTLP, ECS logs with domain events and a level per outcome, metrics with one bounded label on a management port, SLOs with burn-rate alerts kept in infra, and the pause switch).
  - **Week 13 threat model merged** (docs #144): STRIDE of the boundary `telemed-ia-worker` → `document-generation-api`, with the review of both teammates answered.
  - **Whole platform verified from scratch** on 2026-11-06: the 30 `telemed-ia-*` repositories at `develop`, in isolated containers with new volumes.
    - Professional Management: 10 of 10 checks through the gateway, and registration, status change and field errors from the shell.
    - Document Generation: attention → post-summary → RabbitMQ → worker → `POST /api/documents/generate` → PDF in RustFS → `ConsultationPdfGenerated` → in-app notification → download from the shell; another patient gets `403`.
    - Worker with my services: a repeated event returns the same document (`200`); with the API down the message goes to the dead-letter queue after 3 attempts; with no queue bound the event stays in my outbox and is published 6 s after the queue returns; after a broker restart my relay and the worker reconnect.
    - Every gap found in a teammate's repository was sent to its owner with the steps and the log line that reproduce it.
  - **Test suites re-run against real engines**: 338 tests in `document-generation-api` and 181 in `professional-management-api`, 0 failures, 0 skipped.
  - **Shared documentation aligned with the running platform** (one commit per change, approved by Juliana):
    - my services' implemented state in the ownership matrix, dependency map, catalog, backlog and ADR-016 (#163);
    - ER diagrams of both services, the document state diagram and the PDF sequence (#164);
    - how to start the whole platform and the environments, replacing the course template (#165);
    - the platform catalogs and the C4 container, which still described a modular monolith (#166);
    - the requirements verified end to end in the traceability matrix (#167);
    - the real navigation map of the shell and the risk register (#168).
  - **End of last week**: contract copies synced with docs (document-generation-api #57), Prometheus job of the PostgreSQL exporter fixed (infra-postgres #31), the `-db` README in English (document-generation-db #13), and their promotions to `qa` (#58, #14).
- Team work this week:
  - **Juliana (@JulianaFerro1428):**
    - week 11 observability of identity and notifications: JSON logs with the trace context, metrics on the management port, spans to the collector, fast `503` when the database does not answer (identity-and-access-api #135 to #140, notifications-api #25 to #30, identity-and-access-db #60), loaded by the platform Prometheus (infra-postgres #32 to #34), and their docs (#155, #157 to #160);
    - the agent outbox relay to `agent.events` (intelligent-agent-api #45, #47, #48);
    - the locked-login message in the identity portal (identity-and-access-portal #24) and the PR templates;
    - she reviewed and approved docs #161, #162 and #165 to #168.
  - **José Miguel (@BondrewdXD):**
    - after the platform run, the consultation migration restored and its change moved to `V015` (medical-consultation-db #9), the outbox flow of consultations (medical-consultation-api #23), the consultation portal paths (medical-consultation-portal #6), the `start_period` of RabbitMQ and a dead-letter replay in the worker (worker #12, #13), the `422` for a reused `Idempotency-Key` in appointments (appointment-scheduling-api #24) and the shell proxy (front #44);
    - the review answers of his STRIDE (docs #156).

## 3. Blockers and risks
- GitHub Actions cannot run because of the organization's billing limit; every check was run locally and recorded in each PR.
- The promotion from `qa` to `main` needs the professor's approval (norm); it has not started.
- The teammates' fixes merged on 2026-11-06 arrived after the platform run, so the known startup issues in `10-devops/local-setup.md` and the risk register still list them until the platform is run again.

## 4. Plan for next week
- Run the platform again with the teammates' fixes and update the known startup issues and the risk register.
- Promote `qa` to `main` when the professor's review is available, with the same `cherry-pick -x` trace.

## 5. Compliance self-check
- [x] Conventional Commits - `type(scope): summary`
- [x] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [x] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links
- Observability decisions: https://github.com/code-corhuila/telemed-ia-docs/pull/161 and https://github.com/code-corhuila/telemed-ia-docs/pull/162
- Threat model: https://github.com/code-corhuila/telemed-ia-docs/pull/144
- Documentation aligned with the running platform: https://github.com/code-corhuila/telemed-ia-docs/pull/163, https://github.com/code-corhuila/telemed-ia-docs/pull/164, https://github.com/code-corhuila/telemed-ia-docs/pull/165, https://github.com/code-corhuila/telemed-ia-docs/pull/166, https://github.com/code-corhuila/telemed-ia-docs/pull/167 and https://github.com/code-corhuila/telemed-ia-docs/pull/168
- How to run the whole platform: https://github.com/code-corhuila/telemed-ia-docs/blob/main/10-devops/local-setup.md
- End of last week: https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/57, https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/31, https://github.com/code-corhuila/telemed-ia-document-generation-db/pull/13 and the promotions https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/58, https://github.com/code-corhuila/telemed-ia-document-generation-db/pull/14
- Team work: agent outbox relay https://github.com/code-corhuila/telemed-ia-intelligent-agent-api/pull/47, identity observability https://github.com/code-corhuila/telemed-ia-identity-and-access-api/pull/140, notifications observability https://github.com/code-corhuila/telemed-ia-notifications-api/pull/29, consultation migration fix https://github.com/code-corhuila/telemed-ia-medical-consultation-db/pull/9, worker dead-letter replay https://github.com/code-corhuila/telemed-ia-worker/pull/13
