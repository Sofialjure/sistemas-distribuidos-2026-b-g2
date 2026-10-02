<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.
     Your weekly grade is read AUTOMATICALLY from this file:
       09-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 09

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->
- FULL_NAME: Maria Sofia Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Advance the Professional Management domain through HU-005, continue the database implementation and validation, align the project documentation with the implemented domain model, and prepare the team's MVP 2/core planning while completing the Week 09 configuration and progressive-delivery activities.
<!-- CONFIG-END -->

## 1. User stories worked this week

| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| HU-005 | Professional Management | doing | Professional Management project board; [Professional Management DB repository](https://github.com/code-corhuila/telemed-ia-professional-management-db); multiple DB PRs and commits |
| HU-007 | Individual contribution to the documented HU-007 work | doing | Professional Management project board https://github.com/orgs/code-corhuila/projects/29/views/1?pane=issue&itemId=241495773&issue=code-corhuila%7Ctelemed-ia-docs%7C17  |

## 2. My individual contribution

### Professional Management - HU-005

My main individual contribution during Week 09 continued to be the Professional Management microservice, corresponding to HU-005.

I continued the development and stabilization of the Professional Management database repository. During the week I worked on database implementation, migrations, constraints, indexes, foreign keys, seed data, validation and documentation associated with the Professional Management domain.

The Professional Management DB repository contains more than 20 pull requests associated with the ongoing implementation and review process. The work included both implementation and review/fix cycles. Evidence from the current repository history includes:

- `feat(professional-db): recreate seed ownership and idempotency FKs from 04_alter`
- `feat(professional-db): recreate seed ownership index concurrently`
- `test(professional-db): cover 27 changesets and validated FKs`
- `docs(professional-db): update readme and data dictionary for 27 changesets`
- `fix(professional-db): address PR #21 review findings`
- Merge of PR #21 from `code-corhuila/fix/HU-005-professional-db-fk-and-index-conformance`

These changes show the continued implementation, validation and correction of the Professional Management database rather than only documentation work.

Evidence:
- Professional Management project board: https://github.com/orgs/code-corhuila/projects/29/views/1?pane=issue&itemId=241495585&issue=code-corhuila%7Ctelemed-ia-docs%7C15
- Professional Management DB repository: https://github.com/code-corhuila/telemed-ia-professional-management-db

### Professional Management documentation alignment

As an individual contribution, I also reviewed and organized information in the `telemed-ia-docs` repository because some inconsistencies existed between the domain documentation and the implementation of the Professional Management microservice.

I worked on aligning the documentation with the actual Professional Management model and implementation. This included changes across the domain, data and API documentation and the addition/adjustment of architectural decisions.

The documentation work included:

- Aligning the Professional Management data model with the applied database schema.
- Correcting the professionals schema in the platform data model.
- Recording the Professional Management persistence decision.
- Addressing review recommendations from PR #48.
- Aligning professional type and status across the domain documentation.
- Aligning the professional type and status API contracts.
- Aligning professional type and status in the data model.
- Clarifying the professional status lifecycle.
- Aligning the professional requirements and traceability.
- Improving the glossary and terminology around professional availability.
- Working with ADR-012 and ADR-013 as part of the architectural documentation alignment.

The repository history provides evidence of these individual documentation contributions. In particular, the Week 09 history includes the following commits:

- `docs(architecture): address PR #48 review recommendations`
- `docs(architecture): record professional management persistence decision`
- `docs(data): correct professionals schema in platform data model`
- `docs(professional): align data model with applied schema`
- `docs: address remaining PR 46 review recommendations`
- `docs: address PR #46 review recommendations`
- `docs: complete professional type and status alignment`
- `docs(domain): clarify professional status lifecycle`
- `docs(api): align professional type and status contracts`
- `docs(professional): align type and status model`
- `docs(data): align professional type and status`
- `docs(domain): align professional type and status`
- `docs(architecture): record professional profile status ownership`
- `docs(requirements): align HU-05 formatting and administrator glossary`
- `docs(traceability): align professional requirement mapping`
- `docs(requirements): align professional functional requirements`
- `docs(requirements): align professional registration criteria`
- `docs(glossary): align professional availability terminology`

This work was intended to improve traceability between the requirements, domain model, applied database schema and service documentation instead of leaving inconsistencies between the documentation repository and the actual Professional Management implementation.

Evidence:
- `telemed-ia-docs` commit: `2d5de696cfe4b39bba80252f1388230ea5ce4b0c`
- `telemed-ia-docs` repository: https://github.com/code-corhuila/telemed-ia-docs

### Individual contribution related to HU-007

I also contributed individually to the work associated with HU-007, as documented in the Professional Management project board.

This contribution is recorded separately from my main HU-005 work because HU-005 remains my primary assigned story, while this represents individual participation in the related HU work.

Evidence:
- Professional Management project board - HU-007: https://github.com/orgs/code-corhuila/projects/29/views/1?pane=issue&itemId=241495773&issue=code-corhuila%7Ctelemed-ia-docs%7C17

### BPMN / Camunda activity

Another individual responsibility during this week was the preparation of the BPMN diagram for the project.

I worked on the BPMN representation and the corresponding swimlanes/process organization. I also installed and configured Camunda for the BPMN work and used the Docker environment provided for the course. I downloaded the Camunda image and uploaded it to the Docker environment provided by the professor so that the team could work with the BPMN/process tooling.

The BPMN work is part of the broader team effort to represent the system processes and support the analysis of the distributed architecture.

Evidence:
- Camunda/Docker environment and process tooling were prepared as part of the BPMN work.
- The BPMN activity is connected with the team's broader work on defining the system core and the processes that will support the second-cut delivery.

### Week 09 - Session 1 - Optional Activity

I completed the Week 09 Session 1 optional activity in the Systems Distributed course repository using Professional Management as the functional context.

The activity focused on:

- Creating an `.env.example` template.
- Demonstrating startup validation of required configuration variables.
- Establishing the principle that secrets must be injected at runtime and never committed to Git.
- Adding a Gitleaks-based pre-commit secret scan.
- Demonstrating an OFF-by-default feature flag.
- Testing the configuration and feature-flag behavior.
- Documenting how these controls prepare the project for secure configuration and progressive delivery.

The implementation was intentionally kept as a course-repository demonstration and did not claim to modify the real Professional Management API or database repositories.

The feature flag demonstration was:

`PROFESSIONAL_SPECIALTY_CATALOG_EXPORT_ENABLED`

with the feature disabled by default.

The activity was validated with the executable tests, Gitleaks, pre-commit and Git configuration checks.

See:
[Week 09 - Session 1 - Optional Activity](optional%20activity%20session%201%20-%20secure%20configuration.md)

### Week 09 - Session 2 - Optional Activity

I completed the Week 09 Session 2 optional activity as a planning continuation of Session 1.

The activity covered:

- A secrets ownership and rotation plan.
- Runtime secret injection and least-privilege access.
- A feature-flag naming and lifecycle policy.
- Feature-flag ownership and removal criteria.
- A proposed progressive rollout plan.
- Canary stages of OFF -> 5% -> 50% -> 100%.
- Rollback through the feature flag.
- Hardening stories with testable Given/When/Then acceptance criteria.
- Identification of pending decisions that cannot be assumed from the existing project evidence.

The selected MVP 2 capability for the planning exercise was HU-10, concerning the professional appointment schedule and the associated pre-consultation context.

The proposed flag was:

`PROFESSIONAL_APPOINTMENT_SCHEDULE_ENABLED`

This remains a planning proposal and is not presented as an implemented or deployed feature.

See:
[Week 09 - Session 2 - Optional Activity](optional%20activity%20session%202%20-%20secure%20config%20and%20rollout%20plan.md)

### Week 09 learning and evidence

During Week 09 I also reviewed and applied the concepts from Session 1 and Session 2.

For Session 1, I studied:

- Configuration by environment.
- `.env.example`.
- Runtime secret injection.
- Secret management.
- Startup/fail-fast validation.
- Feature flags.
- The distinction between deployment and release.
- The use of feature flags to enable or disable new functionality safely.

For example, the configuration exercise demonstrated that required environment variables should be validated before the application is ready to receive traffic, while secret values should be injected at runtime rather than stored in Git.

For Session 2, I reviewed:

- Secret ownership.
- Secret rotation.
- Feature-flag naming and ownership.
- Feature-flag removal and prevention of flag debt.
- Progressive delivery.
- Canary deployment.
- Monitoring gates.
- Rollback through a feature flag.
- Splitting hardening work into stories with testable acceptance criteria.

I also prepared the corresponding Week 09 Session 1 and Session 2 infographics as study/evidence material.

### Class sessions

#### Session 1 - Monday

The Monday class session was primarily used to organize the work and advance the individual contributions for the week.

The professor indicated that an evidence PR/commit should be left before 12:00 a.m. I left evidence of my progress in the `telemed-ia-docs` repository and continued work in the Professional Management DB repository.

One of the documentation evidence points from that work is commit:

`2d5de696cfe4b39bba80252f1388230ea5ce4b0c`

I also continued the Professional Management DB work during the same period.

#### Session 2 - Thursday

The Thursday session continued the individual work and included additional material provided by the professor concerning the database technology and its use in the system.

I reviewed this material in relation to the Professional Management database work and continued the analysis of the database responsibilities and configuration required by the distributed system.

### Group contribution

In addition to my individual responsibilities, the team continued working together on the architecture and core of the system for the second cut.

The team is currently dividing the system core and identifying the microservices required to support it. This includes:

- Identifying the microservices that form the core of the system.
- Coordinating the responsibilities of the different domains.
- Developing the necessary microservices.
- Preparing the corresponding architecture/process diagrams.
- Coordinating the work of the different team members according to their assigned domains.

For the current group distribution, Juliana has been working on HU-001 through HU-003, Miguel has been working on HU-004, and I have been responsible primarily for HU-005, with individual participation related to HU-007.

The group work is complementary to the individual contributions and is being organized toward the second-cut delivery.

## 3. Blockers and risks

- The Professional Management implementation is still evolving, so the database, API and documentation must continue to be kept aligned.
- Some architectural and operational decisions for MVP 2 are still proposals and require team confirmation before implementation.
- The final ownership and implementation boundaries for some cross-domain flows must be confirmed before the related MVP 2 stories are committed.
- The documentation repository and the microservice repositories must remain synchronized to avoid inconsistencies between the documented model and the applied implementation.
- For the Week 09 secure-configuration activities, the actual production secret manager, rotation cadence, feature-flag runtime mechanism, canary tooling, monitoring thresholds and rollback propagation mechanism are still pending decisions.
- HU-10 was used as a proposed MVP 2 planning capability in the Session 2 optional activity; it is not presented as an approved or implemented feature.
- The Professional Management DB continues to require validation of constraints, foreign keys, indexes, migrations and seed behavior as changes are integrated.

## 4. Plan for next week

- Continue the implementation and stabilization of Professional Management, especially the database work associated with HU-005.
- Continue aligning the Professional Management DB implementation with the corresponding documentation and API/domain contracts.
- Continue supporting the definition and implementation of the system core for the second cut.
- Continue developing and reviewing the architecture/process diagrams.
- Follow up on the pending MVP 2 decisions and dependencies before implementing features that depend on them.
- Continue the persistence work planned for the next week.
- Use the Week 09 secure-configuration and progressive-delivery planning as preparation for the MVP 2 release.
- Continue validating the Professional Management database changes through migrations, constraints, indexes, foreign keys and tests.

## 5. Compliance self-check

- [x] Conventional Commits - `type(scope): summary`
- [ ] Per-environment HU branch + PR to that environment (`hu-xxx-dev -> develop`, ...)
- [x] Testable acceptance criteria
- [x] Tests added/updated (unit / integration)
- [ ] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links

- Professional Management HU-005 board: https://github.com/orgs/code-corhuila/projects/29/views/1?pane=issue&itemId=241495585&issue=code-corhuila%7Ctelemed-ia-docs%7C15
- Professional Management HU-007 board: https://github.com/orgs/code-corhuila/projects/29/views/1?pane=issue&itemId=241495773&issue=code-corhuila%7Ctelemed-ia-docs%7C17
- Professional Management DB repository: https://github.com/code-corhuila/telemed-ia-professional-management-db
- TeleMed IA documentation repository: https://github.com/code-corhuila/telemed-ia-docs
- Week 09 – Session 1 – Optional Activity: [activity document](optional%20activity%20session%201%20-%20secure%20configuration.md)
- Week 09 – Session 2 – Optional Activity: [activity document](optional%20activity%20session%202%20-%20secure%20config%20and%20rollout%20plan.md)
- Documentation evidence commit: `2d5de696cfe4b39bba80252f1388230ea5ce4b0c`

-----------------------------------------

### Professional Management — Database evidence

- [DB - validate 27 changesets and foreign keys](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/2821598)
- [DB - recreate seed ownership index concurrently](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/41698d9)
- [DB - recreate seed ownership and idempotency foreign keys](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/a89d8a8)
- [DB - address PR #21 review findings](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/9a1b7d8)

-------------------------------------

### Professional Management — Documentation and architecture evidence

- [Docs - align professional data model with applied schema](https://github.com/code-corhuila/telemed-ia-docs/commit/a29933d)
- [Docs - correct professionals schema in platform data model](https://github.com/code-corhuila/telemed-ia-docs/commit/fd049c1)
- [Docs - record Professional Management persistence decision](https://github.com/code-corhuila/telemed-ia-docs/commit/78fdc34)
- [Docs - address PR #48 review recommendations](https://github.com/code-corhuila/telemed-ia-docs/commit/4f7efed)

--------------------------------------

### Professional Management — Domain and API documentation alignment

- [Docs - complete professional type and status alignment](https://github.com/code-corhuila/telemed-ia-docs/commit/bba24c3)
- [Docs - address remaining PR #46 review recommendations](https://github.com/code-corhuila/telemed-ia-docs/commit/54c24c4)