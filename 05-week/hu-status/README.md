<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.

     Your weekly grade is read AUTOMATICALLY from this file:

       05-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 05

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->

- FULL_NAME: Maria Sofia Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2
- SPRINT_GOAL: Complete and prepare MVP 1 for the first-cut release by integrating the frontend and backend, applying Docker containerization, reviewing release requirements, completing the selected MVP user stories, updating the project documentation, and preparing the MVP and mockup deliverables for the final Cut 1 presentation.

<!-- CONFIG-END -->

## 1. User stories worked this week

During Week 05, the team worked on the selected user stories that form the MVP 1 scope. The MVP was completed as the main deliverable for Cut 1 and prepared for presentation in Week 06.

The selected MVP user stories are:

| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| HU-001 | Patient Registration | done | MVP repository / project documentation |
| HU-002 | Login and Logout | done | MVP repository / project documentation |
| HU-003 | Password Recovery | done | MVP repository / project documentation |
| HU-004 | Profile Management | done | MVP repository / project documentation |
| HU-005 | User and Professional Management | done | MVP repository / project documentation |
| HU-007 | Consult Availability | done | MVP repository / project documentation |
| HU-008 | Schedule Appointment | done | MVP repository / project documentation |
| HU-009 | Manage My Appointments | done | MVP repository / project documentation |
| HU-010 | Consult Medical Agenda | done | MVP repository / project documentation |
| HU-011 | Update Appointment Status | done | MVP repository / project documentation |

The MVP documentation defines these eleven stories as the selected functional scope for MVP 1. The documentation also records that some capabilities are partial or simulated in this version, including real AI-provider integration, complete availability-block management, real email delivery, and other functionality planned for future iterations.

## 2. My individual contribution

During Week 05, my individual work was focused on consolidating the work from the previous weeks, reviewing the technical material, contributing to the completion of MVP 1, improving the project documentation, and preparing the project deliverables for the Cut 1 evaluation.

### Session 1 - Containerization with Docker

I reviewed the Week 05 Session 1 material available in Moodle, focusing on the concepts required to package and execute a distributed system consistently.

I studied the difference between:

- Dockerfile
- Docker image
- Docker container
- Docker registry

I also reviewed the importance of multi-stage Docker builds, layer caching, runtime images, and avoiding unnecessary files inside the final image.

I studied Docker Compose and its role in running multiple services together through a shared network. I also reviewed how services communicate using service names instead of hard-coded IP addresses.

Another important topic was configuration and persistent data. I reviewed the use of environment variables for configuration and secrets, and Docker volumes for persistent database data.

I also reviewed the common containerization mistakes presented in the session, especially:

- Using single-stage images unnecessarily.
- Copying `.env` files or secrets into images.
- Storing database data only inside disposable containers.
- Hard-coding service IP addresses.
- Building unnecessarily large images.

As part of applying these concepts to TeleMed IA, the project was containerized using Docker and Docker Compose. The MVP documentation records Docker and Docker Compose as the DevOps technologies used for containerization.

The backend project includes a Dockerfile and a `docker-compose.yml`, and the Compose configuration allows the backend, frontend and PostgreSQL environment to be executed together.

### Session 1 - Class activities and additional learning

During the Monday class session, we also reviewed additional distributed-systems concepts related to the project, including transversal services and transversal domains.

I also participated in the class activities where some classmates presented their work on the plant-related project.

The class discussion helped connect the concepts of transversal domains and shared capabilities with the architecture already defined for TeleMed IA. In the MVP documentation, Identity & Access and Notifications are described as transversal capabilities because they can support several parts of the system.

### Session 1 - Backlog repository

During this week, the professor also created a new repository intended to contain the user stories being worked on, functioning as a project backlog.

I reviewed and worked with this new organization of the project backlog and connected the MVP user stories with the functionality implemented by the team.

The MVP documentation establishes traceability between the selected user stories and the corresponding domains, including Identity & Access, Patient Management, Professional Management and Appointment Scheduling.

### MVP development contribution

Together with my teammates, I participated in the development and consolidation of the MVP.

The work included both backend and frontend components using the technologies defined for the project.

The backend was developed with:

- Java 17
- Spring Boot 3.3.13
- Spring Security
- JWT
- BCrypt
- PostgreSQL 16
- JPA/Hibernate
- Flyway
- OpenAPI / Swagger
- Actuator / Micrometer / Prometheus

The frontend was developed with:

- Angular 17+
- Ionic 7+
- Capacitor
- RxJS
- Angular Services
- Reactive Forms
- SCSS

The MVP documentation confirms that the backend exposes a REST API, uses JWT-based authentication and role control, connects to PostgreSQL, and is organized using application, domain, infrastructure, interfaces, shared and configuration areas.

The frontend was organized into reusable and functional areas such as authentication, patient, professional, appointment, admin, agent, notification and summary features.

### Mockup and UX/UI contribution

One of my main individual contributions during the development of the MVP was the creation of the project mockup.

I worked on the mockup from the initial design stage through its implementation and refinement. I approached the design as an iterative process, reviewing the interface and making improvements as the understanding of the MVP and its functionalities evolved.

The mockup was developed as one of the main project deliverables together with the functional MVP.

The interface was designed considering the different actors and functionalities of the platform, including patient, professional and administrator experiences.

### Documentation repository contribution

I also actively participated in the maintenance and improvement of the `telemed-ia-docs` documentation repository.

During the development of the project, I made commits in different documentation folders, updating existing information, adding new project information, and making improvements to the documentation as the project evolved.

The documentation repository was progressively updated beyond the initial weekly work, including documentation associated with later project weeks and the MVP delivery.

The MVP documentation references the `telemed-ia-docs` repository as one of the project's main sources of reference.

### Independent MVP repository

As part of the MVP delivery organization, the team also created an independent repository called `telemed-ia`.

This repository was used to consolidate the MVP implementation in a single independent project repository, including the backend and frontend components required for the MVP.

The MVP implementation and its technical documentation were therefore organized separately from the central documentation repository.

The central documentation repository contains the corresponding deliverables and documentation, including the material associated with the MVP delivery.

### MVP completion and Cut 1 delivery

During this week, the team completed the MVP 1 increment that will be presented during Week 06 as the final evaluation of Cut 1.

The final delivery includes two main deliverables:

1. The functional MVP.
2. The project mockup.

The MVP documentation describes the implemented version as a functional minimum product based on a selected subset of the complete TeleMed IA project.

The MVP includes backend, frontend, database, authentication, roles, patient and professional management, appointments, agenda functionality, summaries, notifications, Swagger/OpenAPI and Docker Compose.

The complete project remains larger than the MVP, and the documentation identifies several capabilities as future work, including real conversational AI integration, real SMTP email delivery, complete availability blocks, PDF generation, automated tests and the future separation into independent microservices.

## 3. Blockers and risks

There were no major technical blockers preventing the completion and delivery of MVP 1.

The main risks during this week were related to coordinating the integration of the different project components and making sure that the MVP, mockup and documentation remained aligned.

Another consideration was maintaining consistency between the central documentation repository, the independent MVP repository, and the weekly individual documentation.

The MVP documentation also identifies some functionality as partial or simulated rather than fully implemented. These limitations are documented as part of the MVP scope and are not considered blockers for the Cut 1 delivery.

The real conversational AI integration remains pending, as well as some other capabilities planned for future iterations.

## 4. Plan for next week

For Week 06, the main objective is to present and explain MVP 1 as the final deliverable for Cut 1.

My plan is to:

- Participate in the MVP presentation and demonstration.
- Explain the work completed during the first cut.
- Support the demonstration of the functional MVP.
- Present and explain the mockup and its iterative design process.
- Review the project documentation before the presentation.
- Verify that the MVP repository and documentation repository contain the expected deliverables.
- Review the feedback obtained during the MVP evaluation.
- Identify improvements and pending functionality that should be transferred to the next project iteration.
- Continue working with the team on the evolution of TeleMed IA toward the next cut.

## 5. Compliance self-check

- [x] Conventional Commits - `type(scope): summary`
- [x] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [ ] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

The project documentation records that automated unit and integration tests remain outside the implemented MVP scope for this version. The MVP instead includes documented execution and functional evidence using the backend, PostgreSQL, Swagger and frontend.

The architecture remains a modular monolith for MVP 1, with domain boundaries that are intended to evolve into independent microservices in future iterations.

## 6. Evidence links

### Project repositories

- [TeleMed IA Documentation Repository](https://github.com/code-corhuila/telemed-ia-docs)
- [Independent TeleMed IA MVP Repository](https://github.com/JulianaFerro1428/telemed-ai)
- [MVP Backend](https://github.com/JulianaFerro1428/telemed-ai/tree/main/telemedai-backend)
- [MVP Frontend](https://github.com/JulianaFerro1428/telemed-ai/tree/main/telemedai-frontend)

### MVP documentation and design

- [MVP Technical Documentation](https://github.com/JulianaFerro1428/telemed-ai/blob/main/Documentacion_MVP_TeleMed_IA.pdf)
- [TeleMed IA MVP Mockup - Figma](https://www.figma.com/proto/UycxwgGJpp0ZppwTANL0jo/Untitled?node-id=107-8&p=f&viewport=-1543%2C448%2C0.09&t=g2ePMjqU00Hzf2rQ-1&scaling=min-zoom&content-scaling=fixed&starting-point-node-id=4%3A7&page-id=0%3A1&show-proto-sidebar=1)

### Docker and containerization

#### Backend Dockerfile

- [Backend Dockerfile](https://github.com/JulianaFerro1428/telemed-ai/blob/main/telemedai-backend/Dockerfile)

The backend uses a multi-stage Docker build, separating the build environment from the runtime environment:

```dockerfile
FROM maven:3.9.9-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .

RUN mvn -q -DskipTests dependency:go-offline

COPY src ./src

RUN mvn -q -DskipTests package

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=build /app/target/telemed-backend-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]
```

This provides evidence of the multi-stage Docker build studied in Session 1, where the application is compiled in a Maven environment and then executed using a Java 17 JRE runtime image.

#### Docker Compose

- [Docker Compose](https://github.com/JulianaFerro1428/telemed-ai/blob/main/docker-compose.yml)

The Docker Compose configuration defines the PostgreSQL database, backend and frontend services:

```yaml
services:

  postgres:
    image: postgres:16-alpine
    container_name: telemed-postgres
    restart: unless-stopped

    environment:
      POSTGRES_DB: ${POSTGRES_DB:-telemed}
      POSTGRES_USER: ${POSTGRES_USER:-telemed}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-telemed}

    ports:
      - "5432:5432"

    volumes:
      - telemed_pgdata:/var/lib/postgresql/data

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-telemed} -d ${POSTGRES_DB:-telemed}"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build:
      context: ./telemedai-backend
      dockerfile: Dockerfile

    container_name: telemed-backend
    restart: unless-stopped

    depends_on:
      postgres:
        condition: service_healthy

    environment:
      SPRING_PROFILES_ACTIVE: prod
      DB_URL: jdbc:postgresql://postgres:5432/${POSTGRES_DB:-telemed}
      DB_USERNAME: ${POSTGRES_USER:-telemed}
      DB_PASSWORD: ${POSTGRES_PASSWORD:-telemed}
      JWT_SECRET: ${JWT_SECRET}
      CORS_ORIGINS: ${CORS_ORIGINS:-http://localhost:4200}

    ports:
      - "8080:8080"

  frontend:
    build:
      context: ./telemedai-frontend
      dockerfile: Dockerfile

    container_name: telemed-frontend
    restart: unless-stopped

    depends_on:
      - backend

    ports:
      - "4200:4200"

volumes:
  telemed_pgdata:
```

This configuration demonstrates the use of Docker Compose to coordinate multiple services, environment variables for configuration, a PostgreSQL healthcheck, service dependencies and a persistent volume for database data.

#### Frontend Dockerfile

- [Frontend Dockerfile](https://github.com/JulianaFerro1428/telemed-ai/blob/main/telemedai-frontend/Dockerfile)

### Functional and technical evidence

- Swagger/OpenAPI evidence:
![Swagger](<Swagger/OpenAPI evidence.png>)

### Documentation and project updates

- [Documentation Repository Commits](https://github.com/code-corhuila/telemed-ia-docs/commits/main/)
- [MVP Repository Commit History](https://github.com/JulianaFerro1428/telemed-ai/commits/main/)

#### Relevant MVP commits

- [Upload complete backend and frontend project](https://github.com/JulianaFerro1428/telemed-ai/commit/32fd808) — Upload of the complete backend and frontend project.
- [Fix Docker files](https://github.com/JulianaFerro1428/telemed-ai/commit/825a73a) — Docker configuration fixes for the MVP.
- [add MVP technical documentation PDF](https://github.com/JulianaFerro1428/telemed-ai/commit/ee4fe0b) — Added the MVP technical documentation.
- [add MVP README](https://github.com/JulianaFerro1428/telemed-ai/commit/3dd46e4) — Added the MVP README.

### MVP delivery materials

- [MVP Repository](https://github.com/JulianaFerro1428/telemed-ai)
- [MVP Technical Documentation](https://github.com/JulianaFerro1428/telemed-ai/blob/main/Documentacion_MVP_TeleMed_IA.pdf)
- [MVP Mockup - Figma](https://www.figma.com/proto/UycxwgGJpp0ZppwTANL0jo/Untitled?node-id=107-8&p=f&viewport=-1543%2C448%2C0.09&t=g2ePMjqU00Hzf2rQ-1&scaling=min-zoom&content-scaling=fixed&starting-point-node-id=4%3A7&page-id=0%3A1&show-proto-sidebar=1)

## Week 05 summary

Week 05 was focused on consolidating and completing the first MVP increment of TeleMed IA and preparing it for the final Cut 1 evaluation.

During Session 1, I reviewed the Moodle material about Docker containerization, including images, containers, registries, Dockerfiles, multi-stage builds, Docker Compose, environment configuration, volumes and common containerization mistakes. I also participated in the class activities related to transversal services and transversal domains.

Together with my teammates, I participated in the development and consolidation of the backend and frontend of the MVP and in the Dockerization of the project. The MVP was developed as a modular monolith with Java 17 and Spring Boot 3.3.13 on the backend, Angular 17+ and Ionic 7+ on the frontend, PostgreSQL and Flyway for persistence and migrations, JWT-based authentication, Swagger/OpenAPI and Docker Compose.

One of my main individual contributions was the design and development of the TeleMed IA mockup. I worked on the design iteratively, from the initial interface concepts through the refinement and final realization of the mockup.

I also actively contributed to the `telemed-ia-docs` repository through commits in different documentation folders, updating information, adding project content and making improvements as the project evolved. The team also organized the complete MVP in an independent repository called `telemed-ia`, while the documentation repository was used for the corresponding project documentation and deliverables.

The MVP was completed as the main deliverable for Cut 1, together with the mockup. The MVP technical documentation establishes that the selected MVP scope includes eleven user stories covering authentication, profile management, professional management, availability, appointments and professional agenda functionality.

The MVP is ready to be presented in Week 06 as the final evaluation of Cut 1. The remaining limitations and future functionality are documented separately so that the project can continue evolving in the next cut.