<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.

     Your weekly grade is read AUTOMATICALLY from this file:

       07-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 07

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->

- FULL_NAME: Maria Sofia Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Review the Cut 1 results, understand the evaluation rules and evidence requirements for Cut 2, participate in the team review of bounded contexts and transversal domains for the future microservice stage, and complete and document the individual learning activities for Week 07.

<!-- CONFIG-END -->

## 1. User stories worked this week

| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| N/A | No product HU was implemented this week | N/A | N/A |

No product user story was implemented during Week 07. The work focused on reviewing Cut 1, understanding the Cut 2 evaluation process, participating in the team's review of the project domains and transversal capabilities for the future microservice stage, and completing individual documentation and learning activities.

## 2. My individual contribution

- Participated in the Week 07 class sessions and followed the review of the Cut 1 results, including the evaluation items, delivered work, presentations, and grading process.
- Reviewed the new evaluation guidelines and evidence requirements for Cut 2.
- Reviewed the Git and GitHub workflow explained by the professor for the documentation and individual evidence process.
- Participated in the team's discussion about the domains and bounded contexts that will be used as the basis for the future TeleMed IA microservices.
- The team reviewed the eight domains, their responsibilities, and which capabilities are considered transversal.
- The team submitted the defined domains to the professor as preparation for the creation of the repositories for the future microservices.
- Reviewed and organized my personal GitHub repository, including the documentation and evidence from Weeks 6 and 7.
- Completed the optional activity for Week 07 Session 1, focused on inter-service communication using REST, gRPC, and messaging. I reviewed synchronous and asynchronous communication, compared REST and gRPC, studied queues and topics, analyzed delivery semantics, and documented idempotent consumer behavior and communication decisions for the future TeleMed IA microservice architecture. The activity also included a proposed communication design between the TeleMed IA bounded contexts.

- Completed the optional activity for Week 07 Session 2, focused on versioned contracts and contract testing. I defined a planned OpenAPI REST contract for the communication between Intelligent Agent and Appointment Scheduling, including the `/api/v1/appointments/availability` endpoint, request parameters, response structure, HTTP status codes, and compatibility rules.

- As part of the Session 2 activity, I also defined the planned `AppointmentCreated` event contract using JSON Schema, including `eventId`, `eventType`, `appointmentId`, `patientId`, and `occurredAt`, and documented how the event identifier can support duplicate detection and idempotent processing.

- I documented a consumer-driven contract testing strategy, including consumer expectations, provider verification, contract assertions, CI validation, API and event versioning, and compatibility rules. The contract-testing CI pipeline was documented as a future implementation for the independent microservice stage and was not claimed as implemented in MVP 1.

- These optional activities were completed as individual learning and documentation work. They establish a technical baseline for the next development stage, while the current TeleMed IA MVP remains a modular monolith.
- Reviewed the topics covered in Weeks 06 and 07 to prepare for the upcoming microservice development stage.
- No product user story or microservice was implemented by me during this week. The class focused mainly on planning, evaluation guidelines, domain definition at team level, and preparation for the next development stage.

## 3. Blockers and risks

- No implementation blocker was identified because the microservice development stage had not started yet.
- The main risk is maintaining clear and traceable evidence of individual work in the personal repository and weekly HU Status.
- The transition from the current modular monolith MVP to independent microservices requires clear definition of responsibilities and boundaries for each domain.
- The team must maintain consistency between the defined domains, the future repositories, the architecture documentation, and the implemented services.

## 4. Plan for next week

- Start the microservice development stage.
- Divide the microservice work among the team members.
- Work on the repository and microservice assigned to me.
- Define the initial structure and boundaries of the assigned service following DDD and Hexagonal Architecture principles.
- Begin implementing the first technical increment of the assigned microservice.
- Maintain individual evidence through commits and the weekly HU Status.
- Document the technical decisions and work performed during the development stage.

## 5. Compliance self-check

- [ ] Conventional Commits - `type(scope): summary`
- [ ] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [ ] Testable acceptance criteria
- [ ] Tests added/updated (unit / integration)
- [ ] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

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

### Team activity

- Domain definition: discussed and submitted to the professor by the team during the Week 07 session. No repository commit or PR was created for this activity.

### Week 07 status note

This week was primarily focused on reviewing the results and process of Cut 1, understanding the new Cut 2 evaluation and evidence requirements, participating in the team's review of the TeleMed IA domains and transversal capabilities, and completing individual optional learning activities. The Session 1 and Session 2 activities focused on inter-service communication, REST, gRPC, messaging, versioned contracts, OpenAPI, event schemas, compatibility, and consumer-driven contract testing. No product functionality or microservice code was implemented during the class sessions.