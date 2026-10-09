<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.
     Your weekly grade is read AUTOMATICALLY from this file:
       11-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 10

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->

- FULL_NAME: Maria Sofia Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Complete the technical work for MVP 2, advance the core domains and their supporting components, finalize the Document Generation portal and Front integration, validate the distributed-systems release requirements studied in Week 10, improve project documentation and BPMN consistency, and prepare the integrated system for the develop → qa → main promotion and v2.0.0 release process.

<!-- CONFIG-END -->

## 1. User stories worked this week

| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| HU-05 | User and Healthcare Professional Management | doing | Professional Management DB implementation, validation, documentation, tests, constraints, indexes, foreign keys, seeds, and CI work. |
| HU-16 | Download Consultation Summary as PDF | doing | Document Generation portal implementation, shell integration, Docker deployment, testing, and release preparation. |
| HU-07 | Check General Practitioner Availability | doing | Team progress in Appointment Scheduling; tracked in the shared board. |
| HU-08 | Schedule Appointment | doing | Team progress in Appointment Scheduling; tracked in the shared board. |
| HU-09 | Manage My Appointments | doing | Team progress in Appointment Scheduling; tracked in the shared board. |
| HU-10 | View Professional Appointment | doing | Team progress in Appointment Scheduling; tracked in the shared board. |

HU-05 and HU-16 represent the two main domains assigned to me during this stage. HU-07, HU-08, HU-09 and HU-10 are included as team-level progress and are not presented as individual implementation work.

During Week 10, the team continued preparing the four core domains of the distributed system:

- Intelligent Agent
- Appointment Scheduling
- Medical Consultation
- Document Generation

The core work was complemented by the shared Front shell, infrastructure, documentation, BPMN, and release preparation.

## 2. My individual contribution

### 2.1 Professional Management — HU-05

I continued advancing the Professional Management domain, especially the database implementation and validation.

My individual work included:

- Advancing the Professional Management database according to HU-05.
- Aligning the database schema with the project requirements and Annex A.
- Working on schema changes and rollback behavior.
- Adding and validating indexes.
- Adding and validating foreign keys and constraints.
- Improving seed ownership and idempotency behavior.
- Adding and validating tests for the database changesets.
- Updating the README and data dictionary.
- Documenting HU-005 traceability.
- Addressing review findings from previous pull requests.
- Improving CI and environment configuration.
- Making migration changes retry-safe.
- Verifying the database changeset count and CI validation.

Relevant individual commits included:

- `feat(professional-db): add ddl-alter-012 and ddl-alter-013 for annex A schema conformance`
- `feat(professional-db): add ddl-indexes-002 to recreate indexes concurrently`
- `test(professional-db): align schema and rollback tests with singular table names and 21 changesets`
- `docs(professional-db): update readme and data dictionary for singular names and new changesets`
- `fix(professional-db): apply PR #18 review findings 1, 2, and 4`
- `fix(professional-db): use CREATE INDEX CONCURRENTLY in rollback for symmetry`
- `docs(professional-db): add data dictionary and HU-005 traceability`
- `test(professional-db): cover 27 changesets and validated FKs`
- `docs(professional-db): update readme and data dictionary for 27 changesets`
- `fix(professional-db): address PR #21 review findings`
- `chore(professional-db): verify changeset count and validate in CI and empty the env placeholders`
- `chore(professional-db): address PR #22 review findings`
- `fix(professional-db): make ddl-alter-013 retry-safe with DROP CONSTRAINT IF EXISTS`

These changes were developed and reviewed through the corresponding HU-005 database branches and pull requests.

### 2.2 Document Generation — HU-16

My main individual contribution during Week 10 was completing the first delivery of the Document Generation portal for Corte 2.

The portal was already bootstrapped before this week. During this week I completed and stabilized the implementation and prepared it for integration and deployment.

The work included:

- Completing the Document Generation portal using Angular 21 and Native Federation.
- Implementing the document model using a discriminated union.
- Supporting the four document states:
  - PENDING
  - GENERATING
  - AVAILABLE
  - ERROR
- Implementing loading, error, empty and data view states.
- Implementing download behavior for AVAILABLE documents.
- Implementing retry behavior for ERROR documents.
- Using Idempotency-Key for retry operations.
- Maintaining the hexagonal `DocumentDataSource` port.
- Using synthetic data intentionally for the current Cut 2 delivery.
- Adding automated tests.
- Fixing the Native Federation shell integration problem caused by the `DOCUMENT_DATA_SOURCE` provider.
- Adding a real regression test for the `NG0201` problem.
- Integrating the portal into the shared Front shell.
- Adding the Document Generation remote to the federation manifest.
- Adding the `/documents` route.
- Adding the Documents option to the sidebar.
- Adding fallback behavior when the remote is unavailable.
- Dockerizing the portal.
- Adding the Dockerfile, nginx configuration, compose file and deployment documentation.
- Adding health checks.
- Restricting CORS to the expected shell origins.
- Blocking framing through `X-Frame-Options`.
- Configuring `Vary: Origin`.
- Preventing caching of `remoteEntry.json` and federation chunks.
- Validating the portal through Docker stop/start behavior.
- Validating that the shell continues working when the remote is unavailable.
- Keeping the portal aligned with the course Anexo H requirements.

The portal reached 17 automated tests, including model, mock, route, regression and component tests.

### 2.3 Front integration

Because the Document Generation portal is a remote that must be consumed by the shared Front shell, I also contributed directly to the team Front repository.

My contribution included:

- Registering the Document Generation remote in the federation manifest.
- Creating the document remote configuration.
- Adding the `/documents` route to the shell.
- Adding the Documents option to the sidebar.
- Adding a fallback test for an unavailable remote.
- Integrating the portal according to the existing Native Federation structure.

This work was delivered through the Front integration PR and merged into the shared development branch.

### 2.4 Docker and deployment validation

I also prepared the Document Generation portal for the professor's deployment demonstration.

The deployment work included:

- Multi-stage Docker build.
- Nginx static serving.
- Docker Compose configuration.
- Healthcheck configuration.
- CORS configuration.
- SPA fallback.
- Docker build-context optimization with `.dockerignore`.
- Validation of `remoteEntry.json`.
- Validation of the portal health status.
- Validation of shell-to-remote communication.
- Validation of the failure scenario where the portal container is stopped.
- Validation that the shell displays the remote-unavailable fallback.
- Validation that the portal returns after the container is started again.

The final validation demonstrated:

- CORS allowed for the shell origin.
- CORS blocked for an unauthorized origin.
- `X-Frame-Options: SAMEORIGIN`.
- `Vary: Origin`.
- Healthy Docker container.
- `remoteEntry.json` responding successfully.
- `/documents` loading through the shell.
- Fallback when the portal is stopped.
- Portal recovery after restart.

### 2.5 BPMN correction and architectural alignment

As part of the team work, I also contributed to the correction of the core BPMN after the professor's feedback.

The professor identified several architectural and modeling problems, including:

- The medical consultation had no starting trigger.
- The 27 tasks were incorrectly modeled as user tasks.
- The four core microservices were represented in a single pool.
- `ConsultationCompleted` had duplicated entries.
- Failure, retry and timer paths were incomplete.
- Repository/service names did not match the real repositories.
- Several actors and cases were missing.

I worked with the team to correct these points.

The corrected BPMN now represents the core distributed architecture with the four core microservices:

- Intelligent Agent
- Appointment Scheduling
- Medical Consultation
- Document Generation

The corrected model uses the appropriate message/event-oriented communication, separates the participating contexts, includes failure/retry considerations, and aligns the names with the real repositories.

The BPMN correction was a team activity, with my individual contribution focused on applying and validating the corrections resulting from the professor's feedback.

### 2.6 Documentation and ADR work

I also contributed to the shared documentation repository.

My individual documentation commits included:

- `docs(adr): address ADR-015 review recommendations`
- `docs(adr): address ADR-015 second-round review recommendations`
- `docs(adr): address ADR-015 third-round review recommendations`
- `docs(diagrams): unify readmes, translate new content and restore references section`
- `docs(diagrams): fix index status and register change-log in governance rules`

I also participated in the documentation organization around the diagrams and the core BPMN.

### 2.7 Week 10 sessions and technical learning

During the Week 10 sessions I studied and applied the concepts required for MVP 2.

#### Session 1 — Persistence in distributed systems

I studied:

- Database per service.
- Polyglot persistence.
- Saga pattern.
- Saga orchestration and choreography.
- Compensation transactions.
- Outbox pattern.
- Dual-write problem.
- CQRS.
- Eventual consistency.
- At-least-once delivery.
- Idempotent consumers.
- Failure handling.

I applied these concepts in the Week 10 optional activity using Appointment Scheduling and Medical Consultation as the project domain references.

The educational implementation demonstrates:

- Separate databases per service.
- `AppointmentCreated`.
- Transactional outbox.
- Retry of failed publication.
- Saga happy path.
- Consumer failure.
- `AppointmentCancelled` compensation.
- Persistent idempotency through processed event identifiers.
- Duplicate event delivery.
- Final consistency checks.

The activity is explicitly documented as an educational simulation and does not claim that the production microservices are already connected through the simulated broker.

#### Session 2 — Release: shipping MVP 2

I studied the MVP 2 release process, including:

- Promotion through `develop → qa → main`.
- `cherry-pick -x` between permanent environments.
- `v2.0.0` release tagging.
- Release Definition of Done.
- Unit, integration and contract tests.
- Whole-system Docker startup.
- End-to-end cross-service flow.
- Failure and compensation validation.
- Outbox reliability.
- Idempotent consumers.
- Environment-specific configuration.
- Secret management.
- CHANGELOG and ADR validation.
- Integrated-system demonstration.
- Retrospective.
- Corte 3 preparation.

The team used these concepts while preparing the actual MVP 2 release.

### 2.8 Team contribution

Although HU-05 and HU-16 were my main individual domains, the work was coordinated as a team.

The four core domains were distributed among the team:

- Intelligent Agent — Juliana
- Appointment Scheduling — Miguel
- Medical Consultation — Miguel
- Document Generation — Sofía

The team also worked on the shared Front shell, infrastructure, documentation, BPMN, integration and release preparation.

During the week, the team continued progressing HU-07, HU-08, HU-09 and HU-10 in Appointment Scheduling.

I am therefore distinguishing between my individual implementation evidence and the team's shared progress to avoid attributing other members' commits to my individual contribution.

### 2.9 Week 10 working sessions

During the Monday session, the team advanced the technical implementation and the preparation of the MVP 2 release.

The work focused on:

- Completing the remaining implementation work.
- Integrating the portals.
- Preparing the Front shell.
- Validating Docker deployment.
- Correcting BPMN and documentation.
- Reviewing release requirements.
- Preparing the evidence required for the upcoming release.

During the Thursday session, the professor explained the expected MVP 2 delivery, release process and presentation/sustentation requirements.

The session clarified that MVP 2 must demonstrate not only the happy path but also failure and consistency behavior, and that the release process must be traceable through the environment promotion flow and final version tag.

## 3. Blockers and risks

- The final `v2.0.0` release tag is part of the MVP 2 closure and must be created only after the corresponding main release is approved and merged.
- The final release evidence depends on the completion of the integrated-system validation.
- The team must demonstrate a real failure/compensation or duplicate-event scenario during the final MVP 2 demonstration.
- Production Document Generation API integration is not part of the current Cut 2 portal delivery; the portal intentionally uses synthetic data at this stage.
- The Document Generation API remains planned for a later stage.
- The portal must continue respecting the course constraints regarding no direct database access, token handling through the shell, and environment-based configuration.
- The `qa` branch naming constraint required the use of a temporary `qa-portal-promotion` branch because Git does not allow both `qa` and `qa/...` references to coexist in the same repository.
- The final release must preserve the complete `develop → qa → main` traceability through `cherry-pick -x`.
- The team must ensure that every member completes the required HU-status evidence before the release submission.

## 4. Plan for next week

- Complete the remaining MVP 2 release validation.
- Finalize the integrated-system evidence.
- Complete the failure/compensation demonstration.
- Verify the release checklist.
- Complete the promotion from `develop` through `qa` to `main`.
- Create and verify the `v2.0.0` tag on `main`.
- Complete the final HU-status evidence for every team member.
- Prepare the Moodle submission for the release.
- Prepare the MVP 2 presentation/sustentation.
- Present the integrated system and demonstrate the failure scenario.
- Close Corte 2 and transition the backlog to Corte 3.
- Carry the remaining Document Generation and Professional Management work into Corte 3 where applicable.

## 5. Compliance self-check

- [x] Conventional Commits - `type(scope): summary`
- [x] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [x] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

Additional Week 10 release checks:

- [x] Database-per-service principle addressed in the Session 1 educational activity.
- [x] Saga with compensation demonstrated.
- [x] Outbox pattern demonstrated.
- [x] Idempotent consumer demonstrated.
- [x] Failure and retry paths demonstrated in the educational activity.
- [x] Document Generation portal tested with automated tests.
- [x] Native Federation shell integration tested.
- [x] Docker deployment validated.
- [x] Portal unavailable fallback validated.
- [x] BPMN corrected according to the professor's architectural feedback.
- [x] ADR-015 documentation updated.
- [x] Release process documented and prepared.
- [ ] Final `v2.0.0` tag verified on `main`.
- [ ] Final integrated-system release demonstration completed.
- [ ] Final Moodle release submission completed.

## 6. Evidence links

### HU-05 — Professional Management

- Professional Management DB repository: https://github.com/code-corhuila/telemed-ia-professional-management-db
- HU-05 Professional Management API issue: https://github.com/code-corhuila/telemed-ia-professional-management-api/issues/10

Individual Professional Management DB evidence includes the changes for:

- Annex A schema conformance.
- Concurrent index recreation.
- Schema and rollback tests.
- Data dictionary.
- HU-005 traceability.
- FK and index conformance.
- Seed ownership and idempotency.
- 27 changeset validation.
- CI/environment validation.
- Review corrections.
- Retry-safe migration behavior.

### HU-16 — Document Generation

- HU-16 issue: https://github.com/code-corhuila/telemed-ia-document-generation-api/issues/1
- Document Generation Portal repository: https://github.com/code-corhuila/telemed-ia-document-generation-portal

Portal evidence:

- PR #1 — Angular/Nativ​e Federation bootstrap.
- PR #2 — document model and mock data source.
- PR #3 — documents page with four view states.
- PR #4 — download and retry with Idempotency-Key.
- PR #5 — visual alignment with the shell.
- PR #8 — route-level data source provider and NG0201 regression test.
- PR #10 — Docker deployment and deployment documentation.

### Front integration

- Front repository: https://github.com/code-corhuila/telemed-ia-front
- PR #13 — Document Generation remote integration.

My Front contribution included:

- federation manifest registration;
- document remote configuration;
- `/documents` route;
- Documents sidebar entry;
- remote-unavailable fallback test.

### Documentation / ADR

- Documentation repository: https://github.com/code-corhuila/telemed-ia-docs
- ADR-015 — Document Storage with MinIO.
- Documentation and diagrams organization.
- Core BPMN documentation.

Individual documentation commits included:

- `docs(adr): record ADR-015 document storage with MinIO`
- `docs(adr): address ADR-015 review recommendations`
- `docs(adr): address ADR-015 second-round review recommendations`
- `docs(adr): address ADR-015 third-round review recommendations`
- `docs(diagrams): unify readmes, translate new content and restore references section`
- `docs(diagrams): fix index status and register change-log in governance rules`

### BPMN evidence

![alt text](<Image Week 10 - Telemed-core.png>)

The BPMN was corrected after the professor's feedback regarding:

- missing consultation start trigger;
- incorrect user-task modeling;
- single-pool modeling of the four core microservices;
- duplicated `ConsultationCompleted`;
- missing failure/retry/timer paths;
- repository naming inconsistencies;
- missing actors and cases.

The final BPMN was aligned with the four core microservices and the event/message-based distributed architecture.

### Portal functional evidence

![alt text](<Image Portal functional.png>)

Evidence to show:

- Documents page.
- Four document states.
- Download/retry behavior.
- Portal running correctly through the shell.
- Synthetic data used for the current Cut 2 delivery.

### Docker evidence

Evidence to show:

- Docker container running.
- Healthcheck showing `healthy`.
- `remoteEntry.json` responding successfully.
- Portal available through the shell.

### Docker failure/recovery evidence

Evidence to show:

- `docker compose stop`.
- Shell remains available.
- Remote-unavailable fallback is displayed.

![alt text](<Image Week 10 Docker Portal Documents.png>)

Evidence to show:

- `docker compose start`.
- Portal becomes available again.
- `/documents` loads correctly.

### Front integration evidence

![alt text](<Image Front Documents.png>)


Evidence to show:

- Documents entry in the sidebar.
- `/documents` route.
- Document Generation remote loaded inside the shell.

### Week 10 Session 1 — Optional Activity

- README: `optional activity session 1/README.md`
- Implementation: `optional activity session 1/optional_activity_session_1.py`
- Evidence: `optional activity session 1/evidence.md`
- Saga diagram: `optional activity session 1/saga-flow.mmd`

The activity demonstrates database-per-service, Saga, compensation, outbox, retry and idempotent consumers using an educational local simulation based on the Appointment Scheduling and Medical Consultation domains.

### Week 10 Session 2 — Optional Activity

- MVP 2 release activity: `optional activity session 2 - MVP 2 release.md`

The activity documents:

- MVP 2 release checklist.
- `develop → qa → main` promotion.
- `cherry-pick -x` traceability.
- `v2.0.0` tagging.
- Failure/compensation validation.
- Integrated-system demonstration.
- Retrospective.
- HU-status completion.
- Transition to Corte 3.

The activity distinguishes planned release evidence from evidence that has already been executed and verified.

### Team-level HU evidence

The following stories were also advanced by the team during the week:

- HU-07 — Check General Practitioner Availability
- HU-08 — Schedule Appointment
- HU-09 — Manage My Appointments
- HU-10 — View Professional Appointment

These are included as team progress and are not claimed as individual implementation work.

## Summary

Week 10 focused on closing the technical work required for MVP 2.

My main individual contribution was the completion, integration and deployment preparation of the Document Generation portal for HU-16, together with continued work on Professional Management HU-05, Front integration, BPMN correction, project documentation and release preparation.

At team level, the four core domains continued to be developed and integrated, while the shared Front shell, documentation, BPMN and release process were aligned with the distributed-systems requirements.

The Week 10 sessions were studied and applied through the optional activities covering persistence patterns and MVP 2 release preparation.

The technical release is being prepared through the required:

`develop → qa → main → v2.0.0`

flow using `cherry-pick -x` for traceability.

The remaining release actions are the final integrated-system validation, failure demonstration, approval/merge to `main`, creation of `v2.0.0`, completion of the team evidence, and preparation for the Week 11 Moodle submission and presentation.