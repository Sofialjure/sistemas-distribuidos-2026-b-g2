<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.

     Your weekly grade is read AUTOMATICALLY from this file:

       08-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 08

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->

- FULL_NAME: Maria Sofia Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Advance the Professional Management bounded context for HU-005 while following the repository, database, API, architecture, testing, and documentation standards defined for the project. As a team, analyze and organize the eight business microservices, establish repository access and working rules, and coordinate the separation of DB, API, and Portal repositories.

<!-- CONFIG-END -->

## 1. User stories worked this week

| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| HU-005 | Professional Management - professional DB and API implementation | doing | [Professional Management DB](https://github.com/code-corhuila/telemed-ia-professional-management-db), [Professional Management API](https://github.com/code-corhuila/telemed-ia-professional-management-api), [DB PR #1](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/1), [DB PR #2](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/2), [DB PR #3](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/3), [API PR #2](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/2), [API PR #3](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/3), [API PR #4](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/4), [API PR #5](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/5), [API PR #6](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/6), [API PR #7](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/7), [API PR #9](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/9) |

## 2. My individual contribution

### Team work - Session 1

During Session 1, the team analyzed and discussed the structure and working model proposed by the professor for the microservices.

The professor presented the documentation and repository standards that will be used as the technical reference for developing the microservices during the course. The team reviewed how the project is organized around eight business microservices / bounded contexts and how each domain is separated into its corresponding repositories, especially DB, API and Portal repositories.

The team also reviewed the responsibilities of the different repository types and the expected architecture, development workflow, naming conventions, branches, Pull Requests, testing, documentation and governance rules.

The team leader granted administrator permissions to the two team members who needed them so that the team could access, use and organize the assigned microservice repositories.

As a team, we also discussed and established the working rules needed to distribute the microservices and begin individual development while maintaining consistency across the repositories.

After the team-level analysis and organization, each member started working individually on the microservice assigned to them.

I also studied the material from Sessions 1 and 2, including the infographics created from the topics covered in those sessions. This helped me understand the repository structure, the responsibilities of each repository, the microservice organization, and the workflow that I needed to follow for my individual work.

### My individual work

My assigned bounded context is **Professional Management** and I am working on **HU-005**.

For this bounded context, the project has separate repositories for the different responsibilities:

- `telemed-ia-professional-management-db` - database, schema, seeds and migrations.
- `telemed-ia-professional-management-api` - service API.
- `telemed-ia-professional-management-portal` - web UI remote.

I worked mainly on the DB and API repositories during this week.

### Professional Management DB

I implemented and refined the Professional Management database using Liquibase.

The work included:

- Creating the Professional Management database schema.
- Creating and seeding the specialty catalog.
- Defining specialty deletion constraints and deletion policies.
- Adding schema validation tests.
- Validating professional schema constraints.
- Documenting the professional lifecycle.
- Updating repository documentation.
- Adding seed rollback support.
- Completing and simplifying Liquibase rollbacks.
- Making specialty seed rollbacks safe.
- Adding specialty seed ownership tracking.
- Testing specialty seed rollback ownership.
- Allowing safe specialty deletion.
- Removing real/default credentials from the test database configuration and keeping configuration externalized.

The main database implementation was promoted through Pull Request #1. Subsequent corrections and rollback improvements were promoted through Pull Requests #2 and #3.

### Professional Management API

I also advanced the API for HU-005 following the professor's required hexagonal architecture.

The work included:

- Initializing the service configuration.
- Implementing the domain and application layers.
- Implementing persistence adapters.
- Exposing REST endpoints and configuration.
- Documenting the service setup and endpoints.
- Adding application service tests.
- Adding persistence integration tests.
- Mapping persistence constraints to domain errors.
- Preserving persistence uniqueness mappings.
- Translating persistence conflicts into appropriate domain/API errors.
- Removing default database credentials.
- Validating specialty persistence input.
- Completing the foundation configuration.
- Clarifying API endpoints and credentials.

The API work was organized through HU-005 branches and Pull Requests, including the domain, REST, tests, persistence and documentation work.

### Individual work in `telemed-ia-docs`

As part of the individual Week 08 activity, I also worked in the team's `telemed-ia-docs` repository.

The professor's Session 2 activity required each student to create an individual contribution in the team's `-docs` repository under `07-api/`, using the provided API contract as reference.

The activity focused on maturing the API contract by closing or documenting decisions, completing API specifications, defining error responses and documenting remaining gaps.

For my contribution, I worked on API documentation and review feedback, including:

- Agent provider retry semantics.
- A reusable `SERVICE_UNAVAILABLE` response.
- Agent provider unavailability documentation.
- API contract review feedback for G-02.
- Updating the branch with `main` before completing the work.
- Reviewing and applying feedback associated with the API documentation.

The relevant Week 08 commits are:

- `docs(api): define agent provider retry semantics`
- `docs(api): add reusable service unavailable response`
- `docs(api): document agent provider unavailability`
- `merge: update branch with main`
- `docs(api): address review feedback for G-02`

### ADR-012 - Service Naming Convention

I also worked on the previously opened ADR-012 contribution related to service naming conventions.

The original contribution defined the service naming convention:

- `docs(architecture): define service naming convention`

This work was merged through Pull Request #35.

A follow-up Pull Request #44 remains **open** and addresses the review feedback for ADR-012. It clarifies the distinction between the eight business microservices / bounded contexts and their DB, API and Portal repositories, as well as the distinction between business services and transversal components such as API Gateway, Front, Infra, Workflow and Worker.

The ADR-012 follow-up is intentionally still open and must not be described as merged.

### Session 2

There was no regular class during Session 2 because the team had permission due to the robotics / mechatronics event.

Instead, the professor assigned the individual API contract activity through Teams.

Each student had to work individually in the team's `-docs` repository and create their own branch and Pull Request. I completed my individual contribution according to those instructions.

## 3. Blockers and risks

- Session 2 did not have a regular class because of the robotics / mechatronics event, so the professor's activity had to be completed individually using the instructions and reference material provided through Teams.
- The project has several repositories per business microservice, so maintaining consistency between DB, API and Portal repositories is an important coordination requirement.
- The Professional Management bounded context is still being developed, so HU-005 is marked as `doing` rather than `done`.
- The ADR-012 review follow-up is still open in `telemed-ia-docs` and therefore should not be considered completely closed yet.
- API and database changes must remain aligned with the professor's repository standards, especially the separation between the database and service layers.
- Liquibase rollback behavior required additional validation and corrections to ensure that seed ownership and deletion operations are safe.
- API persistence errors and uniqueness constraints required explicit mapping to domain/API errors.

## 4. Plan for next week

- Continue completing HU-005 for the Professional Management bounded context.
- Continue the Professional Management API according to the hexagonal architecture and the API contract.
- Continue validating the relationship between the API persistence adapters and the Professional Management database.
- Continue improving and validating tests for the domain, application and persistence layers.
- Continue the Professional Management Portal according to the project architecture.
- Continue using Liquibase for controlled database migrations and safe rollbacks.
- Resolve or respond to the remaining review feedback on ADR-012 and close PR #44 when the corrections are validated.
- Keep all changes traceable through small, meaningful Conventional Commits and the corresponding HU branches and Pull Requests.
- Keep the DB, API and Portal repositories aligned with the professor's repository standards and the team's agreed workflow.

## 5. Compliance self-check

- [x] Conventional Commits - `type(scope): summary`
- [x] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [x] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links

### Image session 1 - 2

![alt text](<Image Week 8 - Session 1 - Agile & DevOps for Distributed Teams.png>)

![alt text](<Image Week 8 - Session 2 - Planning — Story Mapping, Estimation and MVP 2 Commitment.png>)

### Team and architecture documentation

- [TeleMed IA documentation repository](https://github.com/code-corhuila/telemed-ia-docs)
- [ADR-012 original PR #35 - define service naming convention](https://github.com/code-corhuila/telemed-ia-docs/pull/35)
- [ADR-012 follow-up PR #44 - address ADR-012 review feedback - OPEN](https://github.com/code-corhuila/telemed-ia-docs/pull/44)
- [ADR-012 commit - docs(architecture): define service naming convention](https://github.com/code-corhuila/telemed-ia-docs/commit/a4108c7)

### Week 08 API documentation activity

- [Commit - docs(api): define agent provider retry semantics](https://github.com/code-corhuila/telemed-ia-docs/commit/e154029)
- [Commit - docs(api): add reusable service unavailable response](https://github.com/code-corhuila/telemed-ia-docs/commit/ff17e8e)
- [Commit - docs(api): document agent provider unavailability](https://github.com/code-corhuila/telemed-ia-docs/commit/e1d602d)
- [Commit - merge: update branch with main](https://github.com/code-corhuila/telemed-ia-docs/commit/15b6f034cf1c503ef532ebbb0505af27fbcf6fbb)
- [Commit - docs(api): address review feedback for G-02](https://github.com/code-corhuila/telemed-ia-docs/commit/1c0e9e66431e1a8caf7f6cbe71263cfa6a7d007d)

### Professional Management DB

- [Professional Management DB repository](https://github.com/code-corhuila/telemed-ia-professional-management-db)

#### Sep 23

- [feat(professional-db): add professional management schema](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/e8142ae40066cd9036a89f1bb6c097d66159b425)
- [feat(professional-db): seed specialty catalog](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/a805040afe89912f75a998f2c2d23b0ee9643be0)
- [test(professional-db): add schema validation](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/da03c02cfd2524208f1e9562fbebedebb3c093b6)
- [docs(professional-db): update repository documentation](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/2b44e9860b5a37723ced51ceb54dbe388b321fb0)
- [feat(professional-db): add seed rollbacks](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/01f11a36d837cfe50a3edc66aa766d794be0aac1)
- [feat(professional-db): define specialty deletion constraints](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/4075ac0b377cfa242da155f342050b2ff709348c)
- [test(professional-db): validate specialty lifecycle](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/3ad25b87f0d2af5a5ec517de696df81263da3c2b)
- [feat(professional-db): define specialty deletion policy](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/f9d702970cbba3d67765302704b12afdf8191553)
- [test(professional-db): validate professional schema constraints](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/b037e396ce9872730b7bda347b36ef9d8fe5c963)
- [chore(professional-db): secure test database credentials](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/f926670365c8eee00418365442f028d45a595ab5)
- [docs(professional-db): document professional lifecycle](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/41f52b7cf2aba24de85c88a7bb4a3bcdc520365d)
- [DB PR #1 - implement Professional Management database](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/1)

#### Sep 26

- [fix(professional-db): complete Liquibase rollbacks](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/9abf8a424ec1528cee8852e6aeb1fa526720eb43)
- [fix(professional-db): simplify professional rollback](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/306173e1bbe18e726d2ef72fc796e2455fa0d642)
- [DB PR #2 - complete Liquibase rollbacks](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/2)

#### Sep 27

- [fix(professional-db): make specialty seed rollbacks safe](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/d8e777a4ddaba02d2c6dd2ccaa1c83e5e9cd3593)
- [feat(professional-db): add specialty seed ownership tracking](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/fd4284efcd6e747853832e9418ea44389b75c8e7)
- [test(professional-db): validate specialty seed rollback ownership](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/022af112d9d27d3dcbd4ab69ffbecce53b4e622b)
- [fix(professional-db): allow safe specialty deletion](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/55f511274469585b756c5d043f6c03aa1be37f0d)
- [DB PR #3 - make specialty seed rollbacks safe](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/3)
- [Merge commit for DB PR #3](https://github.com/code-corhuila/telemed-ia-professional-management-db/commit/14587ee7e1428d2dbe1cafd53f31e879723f7f77)

### Professional Management API

- [Professional Management API repository](https://github.com/code-corhuila/telemed-ia-professional-management-api)

#### API Pull Requests for HU-005

- [API PR #2 - foundation](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/2)
- [API PR #3 - domain](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/3)
- [API PR #4 - persistence](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/4)
- [API PR #5 - REST](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/5)
- [API PR #6 - domain tests](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/6)
- [API PR #7 - persistence tests](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/7)
- [API PR #9 - API documentation](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/9)

#### API commits

- `feat(professional-api): initialize service configuration`
- `feat(professional-api): implement domain and application layer`
- `feat(professional-api): implement persistence adapters`
- `feat(professional-api): expose REST endpoints and configuration`
- `docs(professional-api): document service setup and endpoints`
- `test(professional-api): add application service tests`
- `test(professional-api): add persistence integration tests`
- `fix(professional-api): map persistence constraints to domain errors`
- `fix(professional-api): preserve persistence uniqueness mappings`
- `fix(professional-api): complete foundation configuration`
- `fix(professional-api): translate persistence conflicts`
- `fix(professional-api): remove default database credentials`
- `test(professional-api): verify specialty persistence input`
- `docs(professional-api): clarify endpoints and credentials`
- `merge: sync REST branch with develop`
- `Merge pull request #2 from code-corhuila/feat/HU-005-professional-api-foundation`
- `Merge pull request #3 from code-corhuila/feat/HU-005-professional-api-domain`
- `Merge pull request #4 from code-corhuila/feat/HU-005-professional-api-persistence`
- `Merge pull request #5 from code-corhuila/feat/HU-005-professional-api-rest`
- `Merge pull request #6 from code-corhuila/feat/HU-005-professional-api-tests-domain`
- `Merge pull request #7 from code-corhuila/feat/HU-005-professional-api-tests-persistence`
- `Merge pull request #9 from code-corhuila/feat/HU-005-professional-api-docs`

### Professional Management Portal

- [Professional Management Portal repository](https://github.com/code-corhuila/telemed-ia-professional-management-portal)

The Portal repository was created and organized as the web UI remote for the Professional Management bounded context. During this week, the main individual implementation effort was focused on the DB and API layers.

### Repository standards provided by the professor

- [Repository standards / course documentation](https://github.com/code-corhuila/telemed-ia-docs)
- The DB repository owns the database structure, seed data, roles and migrations.
- The API consumes the domain database and follows the required hexagonal architecture.
- The Portal is separated from the API and consumes the shared client/session mechanism.
- The professor-provided documentation and annexes are the technical reference for developing the microservices.