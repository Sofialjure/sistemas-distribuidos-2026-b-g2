<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.

     Your weekly grade is read AUTOMATICALLY from this file:

       03-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 03

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->

- FULL_NAME: Maria Sofia Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM:  Telemed - Group 2
- SPRINT_GOAL: Study Domain-Driven Design, Hexagonal Architecture, service planning, data ownership, service contracts, Anti-Corruption Layers, and vertical slicing for MVP 1.

<!-- CONFIG-END -->

## 1. User stories worked this week

| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| | | | |

No development user stories were implemented during this week. The work focused on studying the Week 03 material, extending the initial project proposal into the PDR, modeling the domain, understanding the documentation structure, and planning the first MVP vertical slice.

## 2. My individual contribution

- Studied the Week 03 Session 1 material about Domain-Driven Design (DDD) and Hexagonal Architecture.
- Reviewed the main DDD tactical concepts: entities, value objects, aggregate roots, domain events, and invariants.
- Studied the principles of Hexagonal Architecture, including ports, adapters, and the dependency rule.
- Reviewed the importance of keeping the domain independent from infrastructure and framework-specific code.
- Created an infographic summarizing the main concepts from Session 1.
- Selected the **Preconsulta Inteligente** bounded context from TeleMed IA as an initial DDD modeling exercise.
- Created an initial DDD model identifying the proposed aggregate root, entities, value objects, invariants, and domain events.
- Extended the initial project proposal created during Week 01 into a more complete **Product Requirements Document (PDR)**.
- Reviewed and documented the project's functional requirements, user stories, non-functional requirements, business rules, actors, main flows, and requirements traceability.
- Studied the Week 03 Session 2 material about service design, data ownership, contracts, Anti-Corruption Layers (ACL), and vertical slicing for MVP 1.
- Reviewed the structure and purpose of the project's documentation repository presented by the professor during the Thursday session.
- Understood that the documentation repository will serve as the project's source of truth for the technical and architectural documentation.
- Reviewed the proposed organization of the documentation by areas such as governance, context, domain, product, requirements, architecture, data, API, UML, microservices, DevOps, quality, UX/UI, operations, and training.
- Created an infographic summarizing the main concepts from Session 2.
- Created an initial planning document for TeleMed IA covering data ownership, service contracts, ACL considerations, and the first proposed vertical slice for MVP 1.
- Reviewed the initial project documentation and connected the Week 03 concepts with the TeleMed IA project.

## 3. Blockers and risks

- No technical blockers were encountered during the individual study and documentation activities.
- No development user stories were implemented during this week.
- The service boundaries, data ownership, contracts, and MVP 1 scope are still initial proposals and may be refined during the following design stages.
- No specific external system requiring an Anti-Corruption Layer (ACL) has been defined yet.
- The PDR represents the current version of the project requirements and may be refined as the project evolves.

## 4. Plan for next week

- Continue with the Week 04 material on building a service, service structure, layers, and the walking skeleton.
- Continue refining the proposed service boundaries and MVP 1 scope.
- Review the project's documentation and architecture as the implementation phase progresses.
- Use the PDR as a reference for the next stages of architecture and service development.
- Update the Weekly Status with the evidence and activities completed during Week 04.

## 5. Compliance self-check

- [x] Conventional Commits - `type(scope): summary`
- [ ] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [ ] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links

- ![Image Week 3 - Session 1](<Image Week 3 - Session 1 - DDD Model.png>)
- ![Image Week 3 - Session 2 ](<Image Week 3 - Session 2 - Service Design Planning, Data Ownership and Contracts.png>)
- [Session 1 DDD Model - Preconsulta Inteligen](<Optional Activity Week 3 - Session 1 - DDD Model - Intelligent Pre-Consultation.pdf>)
- [Session 2 Service Planning - MVP 1](<Optional Activity Week 3 - Session 2 - Service and MVP 1 Planning.pdf>)
- [TeleMed IA PDR - Requirements and User Stories](PDR_TeleMed_IA.pdf)
- [Project Documentation Repository](https://github.com/code-corhuila/telemed-ia-docs.git)
- [Week 03 Session 2 Documentation Structure](../02-session/material-gobernanza-microservicios)

## 7. Optional Activities

During Week 03, the optional activities corresponding to Session 1 and Session 2 were completed as part of the practical application of the concepts studied during the week. The detailed development of each activity is documented separately.

### Week 03 — Session 1

The Session 1 activity focused on applying Domain-Driven Design to a selected bounded context of TeleMed IA. The **Preconsulta Inteligente** context was selected and modeled by identifying **Preconsulta** as the proposed Aggregate Root, together with its entities, value objects, invariants, and domain events. The activity also considered the relationship between the domain model and the principles of keeping the domain independent from infrastructure and framework-specific concerns.

- [Otional Activity .MD](<Optional Activity Week 3 - Session 1.md>)
- [Optional Activity — Week 3 · Session 1 - DDD Model - Intelligent Pre-Consultation](<Optional Activity Week 3 - Session 1 - DDD Model - Intelligent Pre-Consultation.pdf>)
### Week 03 — Session 2

The Session 2 activity focused on planning the first MVP 1 vertical feature from a service-design perspective. The activity defined an initial proposal for data ownership, service contracts, synchronous and asynchronous communication, Anti-Corruption Layer considerations, and the **Preconsulta y agendamiento de una cita** vertical slice, divided into user stories with testable acceptance criteria.

- [Optional Activity — Week 3 · Session 2 .MD](<Optional Activity Week 3 - Session 2.md>)
- [Optional Activity — Week 3 · Session 2 - Service and MVP 1 Planning](<Optional Activity Week 3 - Session 2 - Service and MVP 1 Planning.pdf>)

## Week 03 Summary

### Session 1 — Domain-Driven Design and Hexagonal Architecture

The Monday session was not held because it was a public holiday. However, the Week 03 Session 1 material was studied independently.

I reviewed the concepts of Domain-Driven Design and Hexagonal Architecture, focusing on domain modeling, aggregate roots, entities, value objects, invariants, domain events, ports, adapters, and the dependency rule.

As a practical activity, I selected the **Preconsulta Inteligente** bounded context from TeleMed IA and created an initial DDD model. The proposal identifies **Preconsulta** as the aggregate root and defines proposed entities, value objects, invariants, and domain events.

The model is an initial proposal and may be refined later during the service design and architecture process.

- [Image Week 3 - Session 1](<Image Week 3 - Session 1 - DDD Model.png>)
- [teSession 1 DDD Model - Preconsulta Inteligen](<Optional Activity Week 3 - Session 1 - DDD Model - Intelligent Pre-Consultation.pdf>)

### PDR Development — Extension of the Initial Project Proposal

During Week 03, the initial project proposal created during Week 01 was extended into a more complete **Product Requirements Document (PDR)**.

The Week 01 document represented the initial project proposal because, at that stage, the complete requirements and user stories had not yet been defined.

During this stage, the project requirements were further developed and documented, including functional requirements, user stories, non-functional requirements, business rules, actors, main system flows, and requirements traceability.

The PDR therefore represents an extension and evolution of the initial project proposal rather than a document that was already completed during Week 01.

The PDR will serve as a reference for the following stages of the project and may be refined as the architecture, services, and MVP evolve.

- [TeleMed IA PDR - Requirements and User Stories](PDR_TeleMed_IA.pdf)
- [Week 01 - Initial Project Proposal](../01-week/hu-status/README.md)

### Session 2 — Service Design, Data Ownership and Contracts

During the Thursday session, the professor introduced the structure and purpose of the project's documentation repository.

The documentation structure was explained as the project's **source of truth**, and the purpose of the different documentation areas was reviewed. The team was also introduced to the repository structure created for the project and the way the documentation will be organized and maintained throughout the semester.

The main topics from the session were service design, data ownership, service contracts, synchronous and asynchronous communication, Anti-Corruption Layers (ACL), and vertical slicing for MVP 1.

As a practical planning activity, I created an initial proposal for TeleMed IA that defines possible data ownership, initial service contracts, ACL considerations, and a first vertical slice for MVP 1 based on **preconsultation and appointment scheduling**.

These decisions are initial proposals and may be refined as the architecture and service boundaries are developed.

- [Image Week 3 - Session 2 ](<Image Week 3 - Session 2 - Service Design Planning, Data Ownership and Contracts.png>)
- [Session 2 Service Planning - MVP 1](<Optional Activity Week 3 - Session 2 - Service and MVP 1 Planning.pdf>)

### Project Documentation Repository

The project's documentation repository was introduced during Session 2. Its structure will be used to organize the technical documentation and maintain a common source of truth for the project.

The repository contains areas for governance, context, domain, product, requirements, architecture, data, API, UML, microservices, DevOps, quality, UX/UI, operations, and training.

[Project Documentation Repository](https://github.com/code-corhuila/telemed-ia-docs.git)

### Week 03 Conclusion

During Week 03, I moved from studying the concepts of DDD and Hexagonal Architecture toward applying them to the TeleMed IA project through an initial domain model, an expanded Product Requirements Document, and a service-planning proposal.

The initial project proposal from Week 01 was extended into the current PDR as the project's requirements and user stories were defined.

The work completed during this week includes documentation and initial design. The proposed service boundaries, data ownership, contracts, and MVP 1 scope are not considered final and may be refined during the following weeks.