<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.
     Your weekly grade is read AUTOMATICALLY from this file:
       03-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 03


<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->

- FULL_NAME: Maria Sofia Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM:
- SPRINT_GOAL: Study Domain-Driven Design, Hexagonal Architecture, service planning, data ownership, service contracts, Anti-Corruption Layers, and vertical slicing for MVP 1.

<!-- CONFIG-END -->

## 1. User stories worked this week

| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| | | | |

No development user stories were implemented during this week. The work focused on studying the Week 03 material, modeling the domain, understanding the documentation structure, and planning the first MVP vertical slice.

## 2. My individual contribution

- Studied the Week 03 Session 1 material about Domain-Driven Design (DDD) and Hexagonal Architecture.
- Reviewed the main DDD tactical concepts: entities, value objects, aggregate roots, domain events, and invariants.
- Studied the principles of Hexagonal Architecture, including ports, adapters, and the dependency rule.
- Reviewed the importance of keeping the domain independent from infrastructure and framework-specific code.
- Created an infographic summarizing the main concepts from Session 1.
- Selected the **Preconsulta Inteligente** bounded context from TeleMed IA as an initial DDD modeling exercise.
- Created an initial DDD model identifying the proposed aggregate root, entities, value objects, invariants, and domain events.
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

## 4. Plan for next week

- Continue with the Week 04 material on building a service, service structure, layers, and the walking skeleton.
- Continue refining the proposed service boundaries and MVP 1 scope.
- Review the project's documentation and architecture as the implementation phase progresses.
- Update the Weekly Status with the evidence and activities completed during Week 04.

## 5. Compliance self-check

- [x] Conventional Commits - `type(scope): summary`
- [ ] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [ ] Testable acceptance criteria
- [ ] Tests added/updated (unit / integration)
- [ ] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links


- ![Session 1 Infographic](<Imagen Semana 3 - Sesión 1 - Modelo DDD.png>)
- ![Session 2 Infographic](<Imagen Semana 3 - Sesión 2 - Planificación diseño de servicios, propiedad de los datos y contratos.png>)
- [Session 2 Service Planning - MVP 1](<Semana 3 - Sesión 2 - Planificación De Servicios Y Mvp 1.pdf>)
- [Session 1 DDD Model - Preconsulta Inteligente](<Semana 3 - Sesión 1 - Modelo Ddd — Preconsulta Inteligente.pdf>)
- [Project Documentation Repository](https://github.com/code-corhuila/telemed-ia-docs.git)
- [Week 03 Session 2 Material - Documentation](../02-session/material-gobernanza-microservicios)


## Week 03 Summary

### Session 1 — Domain-Driven Design and Hexagonal Architecture

The Monday session was not held because it was a public holiday. However, the Week 03 Session 1 material was studied independently.

I reviewed the concepts of Domain-Driven Design and Hexagonal Architecture, focusing on domain modeling, aggregate roots, entities, value objects, invariants, domain events, ports, adapters, and the dependency rule.

As a practical activity, I selected the **Preconsulta Inteligente** bounded context from TeleMed IA and created an initial DDD model. The proposal identifies **Preconsulta** as the aggregate root and defines proposed entities, value objects, invariants, and domain events.

The model is an initial proposal and may be refined later during the service design and architecture process.

- ![Session 1 Infographic](<Imagen Semana 3 - Sesión 1 - Modelo DDD.png>)

- [Session 1 DDD Model - Preconsulta Inteligente](<Semana 3 - Sesión 1 - Modelo Ddd — Preconsulta Inteligente.pdf>)

### Session 2 — Service Design, Data Ownership and Contracts

During the Thursday session, the professor introduced the structure and purpose of the project's documentation repository.

The documentation structure was explained as the project's **source of truth**, and the purpose of the different documentation areas was reviewed. The team was also introduced to the repository structure created for the project and the way the documentation will be organized and maintained throughout the semester.

The main topics from the session were service design, data ownership, service contracts, synchronous and asynchronous communication, Anti-Corruption Layers (ACL), and vertical slicing for MVP 1.

As a practical planning activity, I created an initial proposal for TeleMed IA that defines possible data ownership, initial service contracts, ACL considerations, and a first vertical slice for MVP 1 based on **preconsultation and appointment scheduling**.

These decisions are initial proposals and may be refined as the architecture and service boundaries are developed.

- ![Session 2 Infographic](<Imagen Semana 3 - Sesión 2 - Planificación diseño de servicios, propiedad de los datos y contratos.png>)

- [Session 2 Service Planning - MVP 1](<Semana 3 - Sesión 2 - Planificación De Servicios Y Mvp 1.pdf>)

### Project Documentation Repository

The project's documentation repository was introduced during Session 2. Its structure will be used to organize the technical documentation and maintain a common source of truth for the project.

The repository contains areas for governance, context, domain, product, requirements, architecture, data, API, UML, microservices, DevOps, quality, UX/UI, operations, and training.

[Project Documentation Repository](https://github.com/code-corhuila/telemed-ia-docs)

### Week 03 Conclusion

During Week 03, I moved from studying the concepts of DDD and Hexagonal Architecture toward applying them to the TeleMed IA project through an initial domain model and service-planning proposal.

The work completed during this week is documentation and initial design. The proposed service boundaries, data ownership, contracts, and MVP 1 scope are not considered final and may be refined during the following weeks.