<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.

     Your weekly grade is read AUTOMATICALLY from this file:

       07-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 07

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->

- FULL_NAME: Maria Sofia Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Review the Cut 1 results, understand the evaluation and evidence requirements for Cut 2, participate in the team's preparation for the microservice development stage, complete the Week 07 learning activities, and contribute to the project governance by defining the Git workflow for the future microservice repositories.

<!-- CONFIG-END -->

## 1. User stories worked this week

| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| N/A | No product HU was implemented this week | N/A | N/A |

No product user story was implemented during Week 07.

The work focused on reviewing the Cut 1 results, understanding the Cut 2 evaluation process and evidence requirements, participating in the team's preparation for the future microservice development stage, completing the Week 07 learning activities, and contributing to the update of the project Git governance rules.

The governance contribution was documented through Pull Request #30 in the shared `telemed-ia-docs` repository.

---

## 2. My individual contribution

- Participated in the Week 07 class sessions and followed the review of the Cut 1 results, including the evaluation items, delivered work, presentations, and grading process.
- Reviewed the new evaluation guidelines and evidence requirements for Cut 2.
- Reviewed the Git and GitHub workflow explained by the professor for the documentation and individual evidence process.
- Participated in the team's discussion about the domains and bounded contexts that will be used as the basis for the future TeleMed IA microservices.
- The team reviewed the eight domains, their responsibilities, and which capabilities are considered transversal.
- The team submitted the defined domains to the professor as preparation for the creation of the repositories for the future microservices.
- Reviewed and organized my personal GitHub repository, including the documentation and evidence from Weeks 6 and 7.

### Week 07 Session 1

- Completed the optional activity for Week 07 Session 1, focused on inter-service communication using REST, gRPC, and messaging.
- Reviewed synchronous and asynchronous communication, compared REST and gRPC, studied queues and topics, analyzed delivery semantics, and documented idempotent consumer behavior and communication decisions for the future TeleMed IA microservice architecture.
- Created a proposed communication design between the TeleMed IA bounded contexts, considering the future microservice structure.
- The activity was documented as preparation for the future microservice development stage. The current TeleMed IA MVP remains a modular monolith.

### Week 07 Session 2

- Completed the optional activity for Week 07 Session 2, focused on versioned contracts, OpenAPI, event schemas, compatibility rules, and consumer-driven contract testing.
- Defined a planned OpenAPI REST contract for the future communication between the Intelligent Agent and Appointment Scheduling bounded contexts, including the `/api/v1/appointments/availability` endpoint, request parameters, response structure, HTTP status codes, and compatibility rules.
- Defined the planned `AppointmentCreated` event contract using JSON Schema, including `eventId`, `eventType`, `appointmentId`, `patientId`, and `occurredAt`.
- Documented how the event identifier can support duplicate detection and idempotent processing.
- Documented a consumer-driven contract testing strategy, including consumer expectations, provider verification, contract assertions, CI validation, API and event versioning, and compatibility rules.
- The contract-testing CI pipeline was documented as a future implementation for the independent microservice stage and was not claimed as implemented in MVP 1.

### Governance contribution

- During the Week 07 Session 2 work, I contributed to the update of the TeleMed IA project Git governance rules.
- I updated `00-governance/git-conventions.md` in the shared `telemed-ia-docs` repository to document the Git workflow for the future microservice repositories.
- The governance update defines that each microservice repository will maintain the persistent branches `dev`, `qa`, and `main`.
- The governance update defines the use of temporary branches for development, documentation, testing, fixes, maintenance, and other specific tasks.
- The governance update documents the standard promotion flow:

```text
Temporary task branch
        ↓
       Pull Request
        ↓
       dev
        ↓
       Pull Request
        ↓
       qa
        ↓
       Pull Request
        ↓
      main
```

- The governance update establishes that the other 2 project team members must review and approve a Pull Request before it is merged.
- The governance update also establishes that the Pull Request author cannot approve their own Pull Request.
- The governance update clarifies that team members can work simultaneously on different temporary branches without needing to wait for each other.
- I created Pull Request #30 in the shared `code-corhuila/telemed-ia-docs` repository with the title `docs(governance): update microservice branch workflow`.
- The Pull Request modifies only `00-governance/git-conventions.md`.
- The Pull Request was submitted to the `main` branch of the shared documentation repository for review by the other project team members.
- The Pull Request is currently pending the required reviews and has not been merged yet.
- The main evidence for this governance contribution is the Pull Request and its review status. A screenshot of Pull Request #30 is included as evidence in this weekly status.
- The governance change was made as preparation for the future microservice development stage. It does not represent the implementation of a microservice.
- No product user story or microservice was implemented by me during this week.

---

## 3. Blockers and risks

- No implementation blocker was identified because the independent microservice development stage had not started yet.
- The main risk is maintaining clear and traceable evidence of individual work in the personal repository and weekly HU Status.
- The transition from the current modular monolith MVP to independent microservices requires clear definition of responsibilities, repository structure, branch strategy, and boundaries for each domain.
- The team must maintain consistency between the defined domains, the future repositories, the architecture documentation, the Git governance rules, and the implemented services.
- The updated governance workflow requires the team to consistently use temporary branches and Pull Requests and to obtain the required approvals before merging changes.

---

## 4. Plan for next week

- Start the microservice development stage.
- Divide the microservice work among the team members.
- Work on the repository and microservice assigned to me.
- Define the initial structure and boundaries of the assigned service following DDD and Hexagonal Architecture principles.
- Begin implementing the first technical increment of the assigned microservice.
- Follow the updated Git workflow using a temporary task branch and Pull Request.
- Request review and approval from the other 2 project team members before merging changes.
- Maintain individual evidence through commits, Pull Requests, and the weekly HU Status.
- Document the technical decisions and work performed during the development stage.

---

## 5. Compliance self-check

- [ ] Conventional Commits - `type(scope): summary`
- [ ] Per-environment HU branch + PR to that environment (`hu-xxx-dev -> develop`, ...)
- [ ] Testable acceptance criteria
- [ ] Tests added/updated (unit / integration)
- [ ] DDD / hexagonal boundaries respected (domain has no I/O)
- [ ] No secrets; config via environment variables

---

## 6. Evidence links

- Personal repository: [https://github.com/Sofialjure/sistemas-distribuidos-2026-b-g2.git](https://github.com/Sofialjure/sistemas-distribuidos-2026-b-g2.git)

### Week 07 Session 1

- [Week 7 Session 1 activity](<Optional Activity Week 7 - Session 1.md>)
- ![Week 7 communication design](<Optional Activity Week 7 - Session 1 - TeleMed IA Inter-service Communication Design.png>)

### Week 07 Session 2

- [Week 7 Session 2 activity](<Optional Activity Week 7 - Session 2.md>)
- ![Week 7 OpenAPI contract](<Optional Activity Image Week 7 - Session 2 - OpenAPI REST Contract.png>)
- ![Week 7 event contract](<Optional Activity Image Week 7 - Session 2 - AppointmentCreated Event Contract.png>)
- ![Versioning and contract testing](<Image Week 7 - Session 2 - Versioned Contracts and Contract Testing.png>)


### Governance contribution
- Pull Request #30: `docs(governance): update microservice branch workflow`
- Repository: `code-corhuila/telemed-ia-docs`
- Modified file: `00-governance/git-conventions.md`
- Pull Request status: Open / awaiting review.
- ![Governance PR evidence screenshot](<Governance PR evidence screenshot.png>)
- Commit docs(governance): update microservice branch workflow https://github.com/code-corhuila/telemed-ia-docs/commit/ad781092700ff18949b951f22724f84fe14b51ba 

### Team activity

- Domain definition: discussed and submitted to the professor by the team during the Week 07 session. No repository commit or PR was created by me for the domain-definition activity.

---

## Week 07 Status Note

This week was primarily focused on reviewing the results and process of Cut 1, understanding the Cut 2 evaluation and evidence requirements, preparing for the future microservice development stage, and completing individual learning activities.

During Session 1, I worked on the optional activity about inter-service communication using REST, gRPC, and messaging and documented a proposed communication design for the future TeleMed IA microservice architecture.

During Session 2, I worked on versioned contracts, OpenAPI, event schemas, compatibility rules, and consumer-driven contract testing as preparation for the future microservice stage.

As an additional individual contribution during Session 2, I updated the project Git governance documentation in `00-governance/git-conventions.md`. The change defines the persistent `dev`, `qa`, and `main` branches for each future microservice repository, the use of temporary task branches, the Pull Request workflow, the requirement for approval from the other 2 team members, and the rule that Pull Request authors cannot approve their own Pull Requests.

The governance change was submitted through Pull Request #30 in the shared `telemed-ia-docs` repository. At the time of this weekly status, the Pull Request remains open and is awaiting review. The governance update has not been merged yet.

No product functionality or microservice code was implemented by me during Week 07. The work completed this week focused on technical preparation, documentation, governance, architecture-related learning, and preparation for the next development stage.