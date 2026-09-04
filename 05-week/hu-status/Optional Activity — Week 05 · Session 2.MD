# Optional Activity — Week 05 · Session 2

## MVP 1 Release Preparation — Cut 1

---

## Official Activity

MVP shipping 1: promote to `main`, tag `v1.0.0`, verify the checklist/DoD with evidence, demonstrate the working system, and run the retrospective. Ensure that `NN-week/hu-status/` evidence for each member is complete in their fork. Move to Cut 2.

---

## Release Context

Week 05 Session 2 focused on preparing MVP 1 as the main software deliverable for the first project cut.

The TeleMed IA team completed and consolidated the MVP functionality planned for Cut 1, including the backend, frontend, database, authentication, appointment functionality, documentation and Docker-based execution environment.

The MVP and the project mockup were prepared as the two main deliverables for the Cut 1 evaluation.

The final demonstration and feedback session will take place during Week 06, when the team will present the work completed during the first cut.

---

## MVP 1 Scope

The MVP documentation defines the following user stories as the selected functional scope for MVP 1:

| HU ID | User Story | Status |
|---|---|---|
| HU-001 | Patient Registration | Done |
| HU-002 | Login and Logout | Done |
| HU-003 | Password Recovery | Done |
| HU-004 | Profile Management | Done |
| HU-005 | User and Professional Management | Done |
| HU-007 | Consult Availability | Done |
| HU-008 | Schedule Appointment | Done |
| HU-009 | Manage My Appointments | Done |
| HU-010 | Consult Medical Agenda | Done |
| HU-011 | Update Appointment Status | Done |

The MVP documentation also identifies functionality that remains partial or simulated in this version, including real conversational AI integration, real SMTP email delivery, complete availability blocks, PDF generation and automated testing.

**Evidence:**

- [MVP Repository](https://github.com/JulianaFerro1428/telemed-ai)
- [MVP Technical Documentation](https://github.com/JulianaFerro1428/telemed-ai/blob/main/Documentacion_MVP_TeleMed_IA.pdf)

---

## Release Preparation

The MVP implementation was consolidated in the independent `telemed-ai` repository.

The repository contains the main application components:

```text
telemed-ai
│
├── telemedai-backend
├── telemedai-frontend
├── docker-compose.yml
└── Documentacion_MVP_TeleMed_IA.pdf
```

The backend, frontend and PostgreSQL environment were prepared to work together through Docker Compose.

**Evidence:**

- [Independent TeleMed IA MVP Repository](https://github.com/JulianaFerro1428/telemed-ai)
- [MVP Backend](https://github.com/JulianaFerro1428/telemed-ai/tree/main/telemedai-backend)
- [MVP Frontend](https://github.com/JulianaFerro1428/telemed-ai/tree/main/telemedai-frontend)
- [Docker Compose](https://github.com/JulianaFerro1428/telemed-ai/blob/main/docker-compose.yml)
---

## Release Version

The target version for the first MVP release is:

> **v1.0.0**

At the time of this activity documentation, the `v1.0.0` tag has not yet been created.

The tag and final release steps remain pending until the Cut 1 presentation and final release preparation are completed.

**Evidence:**

- [MVP Repository](https://github.com/JulianaFerro1428/telemed-ai)
- [MVP Repository Commit History](https://github.com/JulianaFerro1428/telemed-ai/commits/main/)


---

## Definition of Done and Release Checklist

The MVP 1 delivery was reviewed against the main project release requirements.

| Checklist item | Status |
|---|---|
| Selected MVP user stories identified | Done |
| Backend implemented | Done |
| Frontend implemented | Done |
| PostgreSQL configured | Done |
| Flyway configured | Done |
| Authentication and roles implemented | Done |
| Appointment functionality implemented | Done |
| Swagger/OpenAPI available | Done |
| Docker configuration available | Done |
| MVP documentation prepared | Done |
| Mockup prepared | Done |
| Final system demonstration | Pending Week 06 |
| Cut 1 presentation | Pending Week 06 |
| Retrospective | Pending Week 06 |
| `v1.0.0` tag | Pending |

The checklist distinguishes between the work already prepared for MVP 1 and the final release activities that will be completed during the Cut 1 presentation.

---

## Working System Demonstration

The MVP has been prepared as a functional software deliverable for the Cut 1 demonstration.

The system includes the main components required to demonstrate the selected MVP functionality:

- Patient and professional management.
- Authentication and role-based access.
- Appointment scheduling and management.
- Professional agenda.
- Medical summaries.
- Notifications.
- REST API with Swagger/OpenAPI.
- PostgreSQL persistence.
- Docker-based execution environment.

The formal demonstration of the working system will take place during the Week 06 presentation.

**Evidence:**

- MVP functional demonstration: Pending Week 06 presentation.

---

## MVP Mockup

The MVP mockup was prepared as the second main deliverable for Cut 1.

The prototype represents the user interfaces and flows considered during the development of the MVP.

**Evidence:**

- [MVP Mockup - Figma](https://www.figma.com/proto/UycxwgGJpp0ZppwTANL0jo/Untitled?node-id=107-8&p=f&viewport=-1543%2C448%2C0.09&t=g2ePMjqU00Hzf2rQ-1&scaling=min-zoom&content-scaling=fixed&starting-point-node-id=4%3A7&page-id=0%3A1&show-proto-sidebar=1)

---

## Individual Weekly Evidence

The course requires each team member to maintain individual weekly evidence in their own fork using the `NN-week/hu-status/README.md` structure.

For Week 05, the individual evidence is maintained in:

```text
05-week/
└── hu-status/
    └── README.md
```

The Week 05 README documents the individual contribution, MVP work, Dockerization, mockup work, documentation updates, evidence and release preparation.

**Evidence:**

- Personal Fork
https://github.com/Sofialjure/sistemas-distribuidos-2026-b-g2/tree/main
---

## Cut 1 Retrospective

The formal retrospective has not yet been completed.

It will be carried out after the Cut 1 presentation during Week 06, when the team will review the work completed, the feedback received, the aspects that worked well, the difficulties encountered and the improvements required for the next cut.

### Retrospective status

- Retrospective meeting: Pending Week 06.
- Presentation feedback: Pending Week 06.
- Improvement actions for Cut 2: To be defined after the evaluation.

---

## Transition to Cut 2

Cut 2 will begin after the Cut 1 presentation, feedback and retrospective.

The next iteration will use MVP 1 as its baseline and will incorporate the feedback obtained during the evaluation, pending functionality and technical improvements identified by the team.

Potential areas for future work include:

- Real conversational AI integration.
- Real email notification delivery.
- Complete availability management.
- PDF generation.
- Automated unit and integration testing.
- Further architectural evolution toward independent services.

---

## Activity Result

MVP 1 was completed and consolidated as the main software deliverable for Cut 1, together with the TeleMed IA mockup.

The team prepared the backend, frontend, PostgreSQL environment, authentication, appointment functionality, Swagger/OpenAPI, Docker configuration and project documentation required for the MVP.

The final release activities are not yet closed. The `v1.0.0` tag, formal system demonstration, Cut 1 feedback and retrospective remain pending for Week 06.

After the presentation and retrospective, the team will use the resulting feedback and identified improvements as the basis for the transition to Cut 2.