<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.
     Your weekly grade is read AUTOMATICALLY from this file:
       12-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 12

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->
- FULL_NAME: María Sofía Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Finish the Professional Management domain end to end (database, API, portal, shell and gateway) and close the HU-16 journey with real data: the portal reads the real API, and a post-consultation summary reaches a stored PDF through RabbitMQ, the worker and the transactional outbox.
<!-- CONFIG-END -->

## 1. User stories worked this week
| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| HU-05 | User and Healthcare Professional Management (professional profiles, FR-011) | done | Database [professional-management-db #31](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/31), [#32](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/32); API [professional-management-api #11](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/11) to [#24](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/24); portal [professional-management-portal #1](https://github.com/code-corhuila/telemed-ia-professional-management-portal/pull/1) to [#8](https://github.com/code-corhuila/telemed-ia-professional-management-portal/pull/8); shell [front #38](https://github.com/code-corhuila/telemed-ia-front/pull/38); gateway [api-gateway #16](https://github.com/code-corhuila/telemed-ia-api-gateway/pull/16) |
| HU-16 | Download Consultation Summary as PDF | done | Contract checks [document-generation-api #30](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/30); real data in the portal [document-generation-portal #14](https://github.com/code-corhuila/telemed-ia-document-generation-portal/pull/14); gateway [api-gateway #15](https://github.com/code-corhuila/telemed-ia-api-gateway/pull/15); generation requested by the worker [document-generation-api #31](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/31); outbox publication [#32](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/32), [#33](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/33) |

## 2. My individual contribution
- Individual work, in the six repositories of my two domains (all PRs merged into `develop`, TDD visible in each history: a failing `test(...)` commit first):
  - **Professional Management database** (db #31, #32):
    - every professional is a general practitioner: the specialty catalog was removed and `professional_type` became NOT NULL with one allowed value (DEC-005);
    - UUID identifiers with expand/contract changesets, a concurrent index in its own changeset and a guarded, reversible rollback (DEC-006);
    - the 34 changesets were applied, rolled back and applied again in a disposable PostgreSQL.
  - **Professional Management API**, rebuilt on Java 21 and Spring Boot 3.5 with the hexagonal layout of Anexo C (api #11 to #24):
    - shared error envelope with `traceId`, `X-Correlation-Id`, ECS logs, `/health` (#12);
    - RS256 token validation in the service itself, authorization in the use case (#13);
    - schema `professional_management`, UUIDs, persistence tests against a real PostgreSQL instead of H2 (#14, #15);
    - paginated list `{data, meta}` (#16) and Anexo C contract checks against the OpenAPI file (#17);
    - `POST /admin/register`, once per `Idempotency-Key`: the account is created in the identity service with a service token, then the profile is stored (#19, #20, #23);
    - `PATCH /{id}/status` to activate or deactivate a profile (#21);
    - the account's name and e-mail in the list and the detail, read from identity in one call per page; the list still answers when identity is down (#24);
    - compose service and `deploy/Dockerfile` (#18, #22).
  - **Professional Management portal**, Angular 21 with Native Federation, from an empty repository (portal #1 to #8):
    - it uses the shell's `HttpClient`, never its own;
    - cards with the four view states (loading, error with retry, empty, data), "Load more", and the newest request wins;
    - registration form with field errors linked by `aria-describedby` and one `Idempotency-Key` per intent;
    - activate/deactivate button, and the account name on each card.
  - **Shell and gateway:** the `professional` remote shown to administrators only (front #38), and the routes `/api/v1/documents` and `/api/v1/professionals` with smoke checks (api-gateway #15, #16).
  - **Document Generation:**
    - Anexo C contract checks: 26 checks, with every response validated against the OpenAPI contract (api #30);
    - the portal reads the real API and the synthetic data was removed (portal #14);
    - the worker may request a generation with its service token (api #31, DEC-007);
    - transactional outbox published to RabbitMQ by a relay inside the API: `FOR UPDATE SKIP LOCKED`, persistent messages with publisher confirms, the ADR-011 envelope, queue `consultation_pdf_generated` with its dead-letter queue (api #32, #33, DEC-008).
  - **Documentation** (docs #106, #108 to #114, #116, #117):
    - decisions DEC-005 to DEC-008 of both services, with the contracts kept in step with the code;
    - ADR-023 (language of both services);
    - the RabbitMQ naming, delivery and retry conventions written in `communication-patterns.md`, as the worker and Medical Consultation implement them.
- Team work this week:
  - **Asynchronous HU-16 journey with José Miguel (@BondrewdXD)**, who built the worker and the Medical Consultation outbox (worker #1 to #5, medical-consultation-api #14 to #19, ADR-011 accepted in docs #115):
    - I ran the complete flow four times in disposable containers (Medical Consultation, RabbitMQ, worker, identity and Document Generation) and reported each reproducible failure with its log line:
      - the RabbitMQ URL was not read;
      - an empty `summaryId` in the event;
      - the wrong route to my API;
      - messages lost without a dead-letter queue;
      - a hardcoded secret;
      - the queue declared with different arguments by each side (406);
      - a NULL that stopped the outbox poller;
      - no HTTP timeout.
    - Each one was fixed, and the last run went from the attention to a stored PDF without any patch.
  - **Professional accounts with Juliana (@JulianaFerro1428)**, who built them in the identity service (identity-and-access-api #121 to #126, #128):
    - I specified the contract my API needed: service token, `Idempotency-Key`, answers 201/200/409/422/400, and the names of a page of professionals;
    - I tested it end to end: the bootstrap admin registers a professional, and the professional signs in with the temporary password.
  - **Reviews:** Juliana reviewed and approved my gateway routes (api-gateway #15, #16), the profile status (docs #110, professional-management-api #21, professional-management-portal #7) and the shell remote (front #38).

## 3. Blockers and risks
- GitHub Actions cannot run because of the organization's billing limit. Every check was run locally and recorded in each PR (for example 336 tests in document-generation-api and 152 in professional-management-api, with real PostgreSQL, RustFS and RabbitMQ).
- `qa` and `main` still hold older versions of the six repositories; the next promotions go through the review of `main`.
- No service consumes `ConsultationPdfGenerated` yet (ADR-011 lists a future consumer); the messages wait in their durable queue.
- The platform compose of `telemed-ia-infra-postgres` includes only the `-db` repositories; how it starts the APIs is a team decision still open.

## 4. Plan for next week
- Promote the HU-05 and HU-16 work from `develop` to `qa` and `main` with `cherry-pick -x`, and keep the board's Environment field in step with each merge.
- Update the documentation that lags behind the code: retry policy and manual regeneration in `events.md`, the service READMEs, and the status of ADR-013, ADR-021 and ADR-024.
- Add the professional-management service client variables to the environment examples of `telemed-ia-infra-postgres`.
- Run the journey from the shell through the gateway with a real sign-in, for both portals.

## 5. Compliance self-check
- [x] Conventional Commits - `type(scope): summary`
- [x] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [x] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links
- Professional Management database: https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/31 and https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/32
- Professional Management API: https://github.com/code-corhuila/telemed-ia-professional-management-api/pulls?q=is%3Apr+is%3Amerged
  - registration through the identity service: https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/23
  - account names in the list: https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/24
  - contract checks: https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/17
- Professional Management portal: https://github.com/code-corhuila/telemed-ia-professional-management-portal/pulls?q=is%3Apr+is%3Amerged
- Shell remote: https://github.com/code-corhuila/telemed-ia-front/pull/38
- Gateway routes: https://github.com/code-corhuila/telemed-ia-api-gateway/pull/15 and https://github.com/code-corhuila/telemed-ia-api-gateway/pull/16
- Document Generation contract checks: https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/30
- Document Generation portal with the real API: https://github.com/code-corhuila/telemed-ia-document-generation-portal/pull/14
- Generation requested by the worker: https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/31
- Outbox published to RabbitMQ: https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/32 and https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/33
- Decisions and contracts: https://github.com/code-corhuila/telemed-ia-docs/pull/106, https://github.com/code-corhuila/telemed-ia-docs/pull/109, https://github.com/code-corhuila/telemed-ia-docs/pull/110, https://github.com/code-corhuila/telemed-ia-docs/pull/113, https://github.com/code-corhuila/telemed-ia-docs/pull/114, https://github.com/code-corhuila/telemed-ia-docs/pull/116, https://github.com/code-corhuila/telemed-ia-docs/pull/117
- Team work: worker https://github.com/code-corhuila/telemed-ia-worker/pulls?q=is%3Apr+is%3Amerged, Medical Consultation outbox https://github.com/code-corhuila/telemed-ia-medical-consultation-api/pull/19, identity accounts https://github.com/code-corhuila/telemed-ia-identity-and-access-api/pull/122 and https://github.com/code-corhuila/telemed-ia-identity-and-access-api/pull/128
