<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.

     Your weekly grade is read AUTOMATICALLY from this file:

       04-week/hu-status/README.md (inside YOUR fork). English. -->

# Weekly Status - Week 04

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->

- FULL_NAME: Maria Sofia Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2
- SPRINT_GOAL: Build MVP 1 by integrating the existing telemed-backend with the frontend, allowing a patient to register, log in, consult professionals, schedule an appointment, and view their appointments.

<!-- CONFIG-END -->

## 1. User stories worked this week

| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|-------|-------|--------------------------|----------------------------|
| HU-01 | Patient Registration | doing | Pending |
| HU-02 | Patient Login | doing | Pending |
| HU-07 | Professional Consultation | doing | Pending |
| HU-08 | Appointment Scheduling | doing | Pending |
| HU-09 | Appointment Management | doing | Pending |

> The MVP 1 scope is limited to the selected user stories above. The team will use only the functionality already available in the existing `telemed-backend` repository. No new backend functionality will be added specifically for this MVP.

## 2. My individual contribution

### Weekly presentation

- Participated in the weekly class presentation on Monday.
- Presented the progress of the Telemed project to the professor and the other teams.
- Explained the progress of the `telemed-ia-docs` repository up to the `04-requirements` section.
- Explained the purpose and content of the main documentation sections:
  - `00-governance`: team rules, agreements, and project governance.
  - `01-context`: project context, problem, purpose, users, and scope.
  - `02-domain`: domain, entities, business rules, and bounded contexts.
  - `03-product`: product definition, problem, vision, and what the team intends to build.
  - `04-requirements`: functional and non-functional requirements, user stories, acceptance criteria, and traceability.

### Class activities and topics

- Worked on understanding and framing the project problem before defining the solution.
- Reviewed the concept of Problem Framing and its relationship with the project context.
- Studied and discussed the Strangler Fig pattern as a strategy for progressive system migration.
- Reviewed the relationship between requirements, user stories, architecture, and implementation.
- Worked on defining the MVP and selecting only a limited set of functionalities from the complete project.
- Planned the MVP 1 sprint using MoSCoW prioritization.
- Defined testable acceptance criteria using Given / When / Then.
- Broke the selected user stories into small and manageable tasks.
- Estimated the selected user stories using Planning Poker and Story Points.
- Defined the Sprint Goal and the Definition of Done for MVP 1.
- Reviewed the contract-first approach for defining the API before implementation.

### Session 1 — Building a Service Structure

During Session 1, I worked on the technical foundation of the TeleMed IA backend and reviewed how the service structure, application entry point, domain entities, persistence, database configuration, containerization, and health verification fit together.

My individual contribution included:

- Reviewed the backend project structure and its separation into technical and domain responsibilities.
- Reviewed the main backend packages:
  - `application`
  - `config`
  - `domain`
  - `infrastructure`
  - `interfaces`
  - `shared`
- Reviewed the domain organization, including the areas related to:
  - authentication,
  - patients,
  - professionals,
  - appointments,
  - notifications,
  - the intelligent agent,
  - and clinical summaries.
- Reviewed the Spring Boot composition root represented by `TelemedApplication.java` and verified that it is annotated with `@SpringBootApplication`.
- Reviewed the persistent `User` entity and its JPA mapping to the `users` database table.
- Verified that the `User` entity contains the main persistence fields required for the user account, including name, email, identity document, role, password hash, account status, registration date, and last access.
- Reviewed the database configuration used by the backend, including PostgreSQL as the database and environment-based configuration for database connection values.
- Reviewed the use of Flyway migrations to create and maintain the database schema.
- Reviewed the Docker Compose configuration used to run PostgreSQL together with the backend.
- Verified the PostgreSQL container configuration, including the database service, persistent volume, port mapping, and health check.
- Verified that the backend exposes a health endpoint through Spring Boot Actuator.
- Verified that the running backend returned an `UP` health status and exposed liveness and readiness information.
- Reviewed how the backend structure supports the project's DDD and hexagonal architecture approach by keeping domain responsibilities separated from infrastructure and external I/O.
- Reviewed the relationship between the backend technical structure and the MVP implementation that would be continued in the following sprint activities.

The main result of this session was the verification of the technical foundation required to continue the MVP 1 implementation: a structured Spring Boot backend, a persistent domain entity, PostgreSQL/Flyway configuration, Docker-based execution, and a working health check.


### Session 2 — MVP 1 Sprint Planning

During Session 2, I worked on finalizing the planning of the MVP 1 sprint and translating the selected requirements into a concrete and testable sprint scope.

My individual contribution included:

- Defined and documented the MVP 1 Sprint Goal:
  - A patient must be able to register, log in, consult professionals, schedule an appointment, and view their appointments.
- Participated in defining the MVP 1 scope using the MoSCoW prioritization technique.
- Identified the MUST functionalities for the sprint:
  - HU-01 — Patient Registration.
  - HU-02 — Patient Login.
  - HU-07 — Professional Consultation.
  - HU-08 — Appointment Scheduling.
  - HU-09 — Appointment Management.
- Identified SHOULD, COULD, and WON'T functionalities in order to keep the sprint scope limited and achievable.
- Defined testable acceptance criteria using the Given / When / Then format for HU-01, HU-02, HU-07, HU-08, and HU-09.
- Broke down each selected user story into small development tasks that could be implemented and verified during the sprint.
- Reviewed the existing backend endpoints that would be consumed by the frontend instead of creating new endpoints specifically for MVP 1.
- Reviewed and documented the API contract required for the MVP based on the endpoints already available in the existing backend, including:
  - `POST /api/auth/register`
  - `POST /api/auth/login`
  - `GET /api/professionals`
  - `POST /api/appointments`
  - `GET /api/appointments/patient/{id}`
  - `PATCH /api/appointments/{id}/cancel`
  - `PATCH /api/appointments/{id}/reschedule`
- Participated in the Planning Poker estimation of the selected user stories.
- Recorded the estimated effort as 18 Story Points:
  - HU-01: 3 SP.
  - HU-02: 3 SP.
  - HU-07: 2 SP.
  - HU-08: 5 SP.
  - HU-09: 5 SP.
- Contributed to the Definition of Done for MVP 1, including acceptance criteria compliance, frontend-backend integration, testing of main and error cases, Pull Request review, Docker execution, PostgreSQL availability, API documentation, and a demonstrable increment.
- Defined the expected end-to-end patient flow for the sprint:
  Registration → Login → Professionals → Select Professional → Schedule Appointment → View Appointments → Cancel / Reschedule.
- Documented the MVP 1 sprint planning in the planning document used as evidence for this session.

The main result of this session was a defined and prioritized MVP 1 sprint scope, with user stories, acceptance criteria, implementation tasks, API endpoints, estimates, Definition of Done, and an expected functional flow.

## 3. Blockers and risks

- The MVP depends on the existing `telemed-backend` implementation and its available endpoints.
- The frontend must adapt to the request and response structures already defined by the backend.
- The API contract must reflect the real backend implementation; no new endpoints will be created only to expand the MVP scope.
- Integration between frontend, backend, and PostgreSQL must be verified before considering the MVP complete.
- Some selected stories may require adjustment if the existing backend behavior differs from the initial requirements.
- The complete project contains more requirements and user stories than those selected for MVP 1. These additional functionalities remain outside the current sprint scope.

## 4. Plan for next week

- Continue the implementation of the selected MVP 1 user stories.
- Integrate the frontend with the existing backend endpoints.
- Validate the complete patient flow:

  Registration → Login → Professionals → Schedule Appointment → View Appointments.

- Test the main success and error cases defined in the acceptance criteria.
- Verify that the backend and PostgreSQL run correctly using Docker.
- Update the API contract with the real request and response structures used by the backend.
- Prepare the MVP 1 increment for demonstration and Sprint Review.

## 5. Compliance self-check

- [x] Conventional Commits - `type(scope): summary`
- [ ] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [ ] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links

- Backend repository: [TeleMed Backend](https://github.com/JulianaFerro1428/telemed-ai/tree/main/telemedai-backend)
- MVP repository: [TeleMed IA MVP](https://github.com/JulianaFerro1428/telemed-ai.git)
- Project documentation repository: [TeleMed IA Documentation](https://github.com/code-corhuila/telemed-ia-docs.git)
- MVP 1 planning documentation: [Week 4 - Session 2 - Planning - MVP 1 Sprint.pdf](Optional%20Activity%20Week%204%20-%20Session%202%20-%20Planning%20-%20MVP%201%20Sprint.pdf) 
- UI mockup:
  - [Mockup progress](<Optional Activity Week 4 - Session 1  -  Mockup progress.png>)
### Pull Requests / commits

- [Week 04 sprint planning and weekly documentation](https://github.com/Sofialjure/sistemas-distribuidos-2026-b-g2/commit/90d7126)
- [Add MVP README](https://github.com/JulianaFerro1428/telemed-ai/commit/3dd46e4)
- [Add MVP technical documentation PDF](https://github.com/JulianaFerro1428/telemed-ai/commit/ee4fe0b)
- [Update MVP README](https://github.com/code-corhuila/telemed-ia-docs/commit/b33fb25)
- [Add Figma mockup link](https://github.com/code-corhuila/telemed-ia-docs/commit/d911416) 