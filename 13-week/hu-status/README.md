<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.
     Your weekly grade is read AUTOMATICALLY from this file:
       13-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 13

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->
- FULL_NAME: María Sofía Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Harden the Professional Management and Document Generation services against the annexes (limits, layout, privacy, error contract), take the week 11 observability practice to Professional Management (logs, metrics, traces, SLOs, alerts and a drill), align the events with the team's common RabbitMQ contract, verify the whole platform end to end, and promote everything from `develop` to `qa`.
<!-- CONFIG-END -->

## 1. User stories worked this week
| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| HU-05 | User and Healthcare Professional Management (professional profiles, FR-011) | done | E-mail only for administrators [professional-management-api #39](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/39); newest first [professional-management-db #35](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/35), [api #42](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/42); three modules [api #44](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/44), [#45](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/45); observability [api #48](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/48), [#50](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/50), [infra-postgres #30](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/30), [docs #125](https://github.com/code-corhuila/telemed-ia-docs/pull/125); promotion to `qa` [api #51](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/51) |
| HU-16 | Download Consultation Summary as PDF | done | Common event contract [document-generation-api #35](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/35), [docs #119](https://github.com/code-corhuila/telemed-ia-docs/pull/119); consumers of `ConsultationPdfGenerated` [docs #121](https://github.com/code-corhuila/telemed-ia-docs/pull/121); error contract in the portal [document-generation-portal #16](https://github.com/code-corhuila/telemed-ia-document-generation-portal/pull/16); promotion to `qa` [api #56](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/56), [portal #19](https://github.com/code-corhuila/telemed-ia-document-generation-portal/pull/19) |

## 2. My individual contribution
- Individual work, in my six repositories plus the shared docs and infrastructure (all PRs merged into `develop`, each one reviewed and approved by Juliana, TDD visible in each history: a failing `test(...)` commit first):
  - **Common event contract** (document-generation-api #35, docs #119, #121):
    - `ConsultationPdfGenerated` is published to the topic exchange `documents.events` with routing key `consultation-pdf-generated`, following the contract the team agreed (each consumer owns its queue and dead-letter queue; the producer creates none);
    - `mandatory` publishing: when no queue takes the message, it stays in the outbox and is retried, so it is never lost;
    - the payload carries the `appointmentId` of the consultation, which notifications needs;
    - the catalog names notification-service and patient-service as consumers;
    - 338 tests, 0 skipped.
  - **Review against Anexos A, C, H and I**, one PR per gap:
    - the account e-mail is returned to administrators only (DEC-009), after a finding by Juliana (docs #120, api #39);
    - the list goes from the newest profile to the oldest: `created_at` with backfill, and a concurrent index in its own reversible changeset (DEC-010; docs #122, db #35, api #42);
    - server, pool and statement limits are declared in the configuration (api #41);
    - both portals read failures through the shell's error contract and show their own message when an answer falls outside it (professional-management-portal #14, document-generation-portal #16);
    - every variable the services read is listed in their `.env.example` (document-generation-api #53, #55, professional-management-api #49);
    - the infrastructure examples name the service clients, the token key and the broker credentials, checked by a script (infra-postgres #26, #28).
  - **Professional Management API in the Anexo C layout** (api #44, #45):
    - packages under `co.edu.corhuila.telemedia.professionalmanagement`, with a framework-free test on the core;
    - three Maven modules (`-core`, `-adapters`, `-app`), with the enforcer rejecting any framework dependency in the core;
    - 166 tests, 0 skipped; the Docker image was rebuilt and checked.
  - **Week 11 observability practice applied to Professional Management** (in my repositories, not in the workshop folder):
    - metrics on a management port, and one trace that continues into identity (api #48), scraped by Prometheus (infra-postgres #27);
    - domain events in the log without personal data (`professional.registration.created|replayed|rejected|unavailable|failed`, `professional.status.changed|rejected|failed`), and counters by outcome (api #50; 181 tests);
    - two SLOs (99.5% availability, 95% of the reads within 500 ms), burn-rate alerts with owner and runbook, `promtool` tests and a Grafana dashboard (infra-postgres #30);
    - `observability.md` with the SLOs, the error budget policy, the alerts and the stories OBS-PM-01 to 05, plus one runbook section per alert (docs #124, #125);
    - drill: identity was stopped for 2.5 minutes while professionals were being registered:
      - 642 answers were 503, and the list kept answering;
      - the 1h burn rate reached 168;
      - the critical alert fired after 5 minutes, and Alertmanager routed it to `page`.
  - **Documentation in step with the code** (docs #118): `events.md`, both service READMEs, and ADR-013, ADR-021 and ADR-024 marked Accepted.
  - **Promotion `develop` → `qa`** of the six repositories:
    - 52 promotion PRs (branches `qa-hu-05-...` and `qa-hu-16-...`), each at most 400 lines;
    - every commit carried over with `git cherry-pick -x`;
    - each one merged with rebase after Juliana's approval;
    - at the end, `qa` holds exactly the same tree as `develop` in the six repositories.
- Team work this week:
  - **Whole-platform verification:** I ran isolated copies of the 28 repositories of the project together (databases, APIs, worker, gateway, shell and portals) and walked every journey. These worked end to end:
    - professionals through the gateway and the shell;
    - the PDF journey: post-consultation summary → RabbitMQ → worker → PDF stored in RustFS → `ConsultationPdfGenerated` → in-app notification for the patient;
    - the e-mail of a confirmed appointment;
    - the download from the shell;
    - the agent portal.
  - For each gap found in a teammate's repository, I wrote down for its owner the request and the log line that reproduce it.
  - **Juliana (@JulianaFerro1428):**
    - notifications inbox (notifications-api #7 to #14, notifications-db #7, #8, notifications-portal #1 to #9, shell front #41 to #43, gateway api-gateway #17); it consumes my `ConsultationPdfGenerated`, and we agreed the common event contract together;
    - appointment e-mails and reminders (HU-17, HU-18: notifications-api #15 to #24, identity-and-access-api #133), and the identity outbox relay (identity-and-access-api #132);
    - observability, circuit breaker and pause switch of the intelligent agent (HU-06: intelligent-agent-api #31 to #40, intelligent-agent-db #22, intelligent-agent-portal #45), and infra-mongo #15;
    - she reviewed and approved all my PRs and the 52 promotions.
  - **José Miguel (@BondrewdXD):**
    - transactional outbox in appointments (appointment-scheduling-api #17 to #19, appointment-scheduling-db #6);
    - appointment reminders (HU-18: appointment-scheduling-api #20 to #22, appointment-scheduling-portal #19, worker #7 to #10);
    - the worker consumes `consultation.events`, and Medical Consultation follows the common contract with `mandatory` publishing (worker #6, medical-consultation-api #20, #21);
    - UUID identifiers and observability in Patient Management (patient-management-db #20, patient-management-api #27 to #29, patient-management-portal #8, #9, docs #123);
    - the appointments upstream in the gateway (api-gateway #18), and the PostgreSQL exporter (infra-postgres #29).

### Week 13 - Session 1 - Optional Activity

Authentication, authorization and zero trust in the two services I own, verified with **20 live probes** run from a container inside the platform network (so the calls that skip the gateway behave like a compromised neighbour):

- the gateway rejects requests without a token, and **each service** rejects a forged, expired, `alg none` or edited token by itself;
- authorization runs in the use case: a patient cannot register professionals, a professional cannot change a profile status, a patient cannot read another patient's PDF, and a service outside the allow-list cannot request PDFs;
- the e-mail of a professional reaches administrators only; malformed input answers `400` with the error envelope and no internals;
- **19 of 20 passed**. The one that failed is a real finding: `POST /api/documents/generate` validates the body before authorizing, so a patient gets `400` with the field list instead of `403`.

See: [Week 13 - Session 1 - Optional Activity](Optional%20Activity%20Week%2013%20-%20Session%201.md)

### Week 13 - Session 2 - Optional Activity

Threat model and security backlog for Professional Management and Document Generation:

- data flow with five trust boundaries and 15 STRIDE threats, each with its mitigation and its gap;
- security gates run for real: **gitleaks** over the full history of my six repositories (1,783 commits, 0 findings, with a positive control) and **trivy** over the API image (no HIGH/CRITICAL in the OS packages; 33 in Java libraries of the Spring Boot 3.5.6 set, most fixed by the latest 3.5.x patch);
- a prioritized backlog of nine stories (SEC-01 to SEC-09) with testable acceptance criteria, and the CI gates that will fail the build once Actions can run.

See: [Week 13 - Session 2 - Optional Activity](Optional%20Activity%20Week%2013%20-%20Session%202.md)

### Week 13 - Guided workshop (threat modeling), in class

Boundary: `telemed-ia-worker` → `document-generation-api` (`POST /api/documents/generate` with a `SERVICE` token). Book: Tanenbaum & van Steen, *Sistemas distribuidos: principios y paradigmas*, 2.ª ed., 2008 (CORHUILA library, 005.4476 T15D ej. 1), chapter 9.

- CP0: boundary claimed in [docs #141](https://github.com/code-corhuila/telemed-ia-docs/issues/141); workshop folder started ([3aa23c0](https://github.com/Sofialjure/sistemas-distribuidos-2026-b-g2/commit/3aa23c0)).
- CP1: data flow of the whole platform with six trust boundaries, assets of the document domain and entry points of my boundary ([8a2cac3](https://github.com/Sofialjure/sistemas-distribuidos-2026-b-g2/commit/8a2cac3)).
- CP2: STRIDE with six threats, risk ranking, residual risk and references, in [docs #144](https://github.com/code-corhuila/telemed-ia-docs/pull/144) (two pushes). Highest risk: a forged or stolen `sub: worker` token (S, 6).
- CP3: three security stories on the team board: [#149](https://github.com/code-corhuila/telemed-ia-docs/issues/149) (S, P0), [#150](https://github.com/code-corhuila/telemed-ia-docs/issues/150) (D, P1), [#151](https://github.com/code-corhuila/telemed-ia-docs/issues/151) (E, P1) ([88d247a](https://github.com/Sofialjure/sistemas-distribuidos-2026-b-g2/commit/88d247a)).
- CP4: `security.yml` (gitleaks, OWASP dependency-check, negative authorization tests) and a negative test for #149: a `SERVICE` token of another client gets `403` ([04-security-ci](../workshop/04-security-ci/HOW-TO-RUN.md)).
- CP5: review comment on the STRIDE of @JulianaFerro1428 ([docs #148](https://github.com/code-corhuila/telemed-ia-docs/pull/148)): the per-account lock opens a lockout threat, and `/refresh` is missing.

See: [workshop folder](../workshop/README.md)

## 3. Blockers and risks
- GitHub Actions cannot run because of the organization's billing limit. Every check was run locally and recorded in each PR (for example, 338 tests in document-generation-api and 181 in professional-management-api, with real PostgreSQL, RustFS and RabbitMQ).
- The promotion from `qa` to `main` needs the professor's approval (norm); it has not started.

## 4. Plan for next week
- Promote `qa` to `main` when the professor's review is available, with the same `cherry-pick -x` trace.
- Keep `qa` equal to `develop` after each new merge in my repositories.

## 5. Compliance self-check
- [x] Conventional Commits - `type(scope): summary`
- [x] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [x] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links
- Optional activities: [Session 1](Optional%20Activity%20Week%2013%20-%20Session%201.md), [Session 2](Optional%20Activity%20Week%2013%20-%20Session%202.md)
- Scripts used in the optional activities: [scripts](scripts/README.md)
- Common event contract: https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/35 and https://github.com/code-corhuila/telemed-ia-docs/pull/119
- E-mail only for administrators: https://github.com/code-corhuila/telemed-ia-docs/pull/120 and https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/39
- Newest first: https://github.com/code-corhuila/telemed-ia-docs/pull/122, https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/35 and https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/42
- Explicit limits: https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/41
- Shell error contract in the portals: https://github.com/code-corhuila/telemed-ia-professional-management-portal/pull/14 and https://github.com/code-corhuila/telemed-ia-document-generation-portal/pull/16
- Environment examples: https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/55, https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/49, https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/26 and https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/28
- Anexo C layout and modules: https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/44 and https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/45
- Observability of Professional Management: https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/48, https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/50, https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/27, https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/30, https://github.com/code-corhuila/telemed-ia-docs/pull/124 and https://github.com/code-corhuila/telemed-ia-docs/pull/125
- Documentation aligned with the code: https://github.com/code-corhuila/telemed-ia-docs/pull/118 and https://github.com/code-corhuila/telemed-ia-docs/pull/121
- Promotions to `qa`: https://github.com/code-corhuila/telemed-ia-professional-management-api/pulls?q=is%3Apr+is%3Amerged+base%3Aqa, https://github.com/code-corhuila/telemed-ia-document-generation-api/pulls?q=is%3Apr+is%3Amerged+base%3Aqa, https://github.com/code-corhuila/telemed-ia-professional-management-portal/pulls?q=is%3Apr+is%3Amerged+base%3Aqa, https://github.com/code-corhuila/telemed-ia-document-generation-portal/pulls?q=is%3Apr+is%3Amerged+base%3Aqa and https://github.com/code-corhuila/telemed-ia-professional-management-db/pulls?q=is%3Apr+is%3Amerged+base%3Aqa
- Team work: notifications inbox https://github.com/code-corhuila/telemed-ia-notifications-api/pull/14, notifications portal https://github.com/code-corhuila/telemed-ia-notifications-portal/pulls?q=is%3Apr+is%3Amerged, agent observability https://github.com/code-corhuila/telemed-ia-intelligent-agent-api/pull/40, appointment reminders https://github.com/code-corhuila/telemed-ia-worker/pull/10, Medical Consultation common contract https://github.com/code-corhuila/telemed-ia-medical-consultation-api/pull/20, patient UUIDs https://github.com/code-corhuila/telemed-ia-patient-management-api/pull/28
