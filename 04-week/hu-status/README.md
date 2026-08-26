<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.

     Your weekly grade is read AUTOMATICALLY from this file:

       04-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 04

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->

- FULL_NAME: Maria Sofia Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2
- SPRINT_GOAL: Build MVP 1 by integrating the existing telemed-backend with the frontend, allowing a patient to register, log in, consult professionals, schedule an appointment, and view their appointments.

<!-- CONFIG-END -->

## 1. User stories worked this week

| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
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

### MVP 1 planning

- Planned and documented the MVP 1 scope using the MoSCoW prioritization technique.
- Defined the Sprint Goal and selected the user stories included in the MVP.
- Defined testable acceptance criteria for HU-01, HU-02, HU-07, HU-08, and HU-09.
- Broke down the selected user stories into small development tasks.
- Reviewed the existing backend endpoints that will be consumed by the frontend.
- Documented the API endpoints required by the MVP.
- Participated in the estimation of the selected user stories using Planning Poker.
- Prepared the Sprint 1 planning documentation and Definition of Done.

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

- [ ] Conventional Commits - `type(scope): summary`
- [ ] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [ ] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links

- Backend repository: https://github.com/BondrewdXD/telemed-backend
- Project documentation repository: https://github.com/code-corhuila/telemed-ia-docs
- [MVP 1 planning documentation](<Week 4 - Session 2 - Planning - MVP 1 Sprint.pdf>)
- Weekly presentation evidence: Pending
- Frontend integration evidence: Pending
- Pull Requests / commits: Pending