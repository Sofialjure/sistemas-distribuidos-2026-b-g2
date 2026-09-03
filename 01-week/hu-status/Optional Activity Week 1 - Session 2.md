# Optional Activity — Week 1 · Session 2

## Professional Engineering Foundations: Governance, Architecture, Backlog and Acceptance Criteria

---

## 1. Official Activity

The Week 1 — Session 2 activity focused on establishing the professional engineering foundations for the distributed systems project.

The activity required the team to:

- Configure the individual profile repository and `CONFIG` block.
- Work using the team fork.
- Use the team's `docs` repository as the documentation space.
- Define an architectural direction through an ADR.
- Start the product backlog.
- Define testable acceptance criteria for MVP 1.

The session also introduced the engineering principles that would guide the project:

- Domain-Driven Design (DDD).
- Hexagonal Architecture.
- SOLID and Clean Code.
- Resilience patterns.
- Testing strategy.
- Scrum and Git flow.
- Architectural Decision Records (ADRs).

The activity was intended to establish professional engineering practices from the beginning of the project.

---

## 2. Project Documentation Repository

The `telemed-ia-docs` repository was provided by the course professor for the TeleMed IA team.

The team did not create this repository. It was provided as the official documentation repository for the project and contains the documentation structure used throughout the development process.

The repository currently acts as the **single source of truth for the TeleMed IA project**, containing the project's architecture, context, requirements, ADRs, governance, UX/UI documentation, and other technical artifacts.

Its structure includes areas such as:

```text
00-governance/
01-context/
02-domain/
03-product/
04-requirements/
05-architecture/
06-data/
07-api/
08-ui/
09-microservices/
10-devops/
11-quality/
12-ux-ui/
13-operations/
14-training/
15-project-control/
```

This structure provides a common location for the team's technical and project documentation.

---

## 3. Architectural Context

At this stage, the project required an architectural direction that could support the development of the TeleMed IA MVP while avoiding unnecessary complexity during the initial implementation.

The project is a telemedicine platform with an Intelligent Agent and several business domains, including:

- Identity and Access.
- Patient Management.
- Professional Management.
- Intelligent Agent.
- Appointment Scheduling.
- Medical Consultation.
- Notifications.
- Document Generation.

Because these domains may evolve independently in the future, the architecture should provide clear boundaries between them.

However, the MVP is not implemented as a complete microservices ecosystem.

The current implementation approach is a **Modular Monolith with Hexagonal Architecture**, while the domain boundaries are designed so that individual modules can evolve into independent microservices in a later stage.

---

## 4. Architectural Direction — Modular Monolith + Hexagonal Architecture

The initial architectural direction for TeleMed IA is to organize the MVP as a modular monolith, applying Hexagonal Architecture inside the application.

Each business domain is treated as an independent module with clear responsibilities and boundaries.

A simplified representation is:

```text
                         TeleMed IA MVP
                               |
                       Modular Monolith
                               |
        ------------------------------------------------
        |        |          |          |               |
      Auth    Patient   Professional  Agent      Appointments
        |        |          |          |               |
        ------------------------------------------------
                               |
                       Hexagonal Architecture
                               |
                --------------------------------
                |              |               |
             Domain       Application      Infrastructure
                |              |               |
             Entities       Use Cases       Adapters
             Value Objects  Ports            Database
             Domain Events  Interfaces       External APIs
```

The objective is to maintain separation of concerns and clear domain boundaries without introducing the operational complexity of multiple independently deployed services during the MVP stage.

---

## 5. Why a Modular Monolith for the MVP?

A modular monolith was selected as the appropriate implementation approach for the MVP because it allows the team to:

- Develop the MVP with a simpler deployment model.
- Maintain clear boundaries between business domains.
- Apply DDD principles from the beginning.
- Apply Hexagonal Architecture within each module.
- Reduce unnecessary distributed communication during the initial implementation.
- Simplify local development and testing.
- Establish domain boundaries before introducing independent deployments.
- Facilitate a future transition to microservices.

The architecture therefore separates logical domain boundaries from physical deployment boundaries.

During the MVP, the domains can coexist in the same application while maintaining their own responsibilities and internal boundaries.

---

## 6. Future Evolution to Microservices

The modular architecture is designed to support a future transition toward microservices.

The planned evolution is:

```text
                CURRENT MVP

              Modular Monolith
                     |
      --------------------------------
      |      |       |       |       |
     Auth  Patient  Prof.   Agent  Appointment
      |      |       |       |       |
      --------------------------------


                     ↓
              Future Evolution


              Microservices
                     |
     -----------------------------------------
     |       |        |       |       |      |
    Auth  Patient  Professional Agent Appointment
     |       |        |       |       |      |
     -----------------------------------------
                     |
              Independent services
```

The future microservice boundaries are aligned with the business domains identified by the team.

The purpose is not to prematurely distribute the MVP, but to establish boundaries that make future extraction possible.

---

## 7. Hexagonal Architecture

Hexagonal Architecture was selected as the architectural style inside the modules.

The core principle is that the domain and application logic should not depend directly on external technologies such as databases, HTTP frameworks, or external APIs.

The dependency direction is:

```text
Adapters
    ↓
Application
    ↓
Domain
```

The domain contains the business rules and should remain independent from infrastructure concerns.

A simplified structure is:

```text
module/
├── domain/
│   ├── entity/
│   ├── valueobject/
│   └── event/
│
├── application/
│   ├── usecase/
│   └── port/
│
└── infrastructure/
    ├── adapter/
    ├── persistence/
    └── web/
```

This structure allows infrastructure components to be replaced without changing the core business logic.

---

## 8. DDD and Bounded Contexts

The TeleMed IA project identifies business domains that represent
different responsibilities within the telemedicine platform.

In the current MVP, these domains are implemented as modules within
the modular monolith. Their boundaries are intentionally defined so
that they can evolve into independent microservices in the future.

The current domains and their planned future service boundaries are:

| # | Current MVP Domain | Future Microservice | Main Responsibility |
|---|---|---|---|
| 1 | Identity & Access | `auth-service` | Registration, login, password recovery, JWT, roles and permissions |
| 2 | Patient Management | `patient-service` | Patient profile and information management |
| 3 | Professional Management | `professional-service` | Healthcare professional profile, license and specialty |
| 4 | Intelligent Agent | `agent-service` | Pre-consultation, follow-up questions and previous consultation summary |
| 5 | Appointment Scheduling | `appointment-service` | Availability, scheduling, cancellation, rescheduling and appointment status |
| 6 | Medical Consultation | `consultation-service` | Clinical observations, diagnosis, recommendations, medications and referrals |
| 7 | Notifications | `notification-service` | Confirmation, cancellation, rescheduling and reminder notifications |
| 8 | Document Generation | `document-service` | Generation of consultation-related PDF documents |

The architectural evolution can therefore be represented as:

```text
Current MVP
     ↓
Modular Monolith
     ↓
Clearly separated business modules
     ↓
Future evolution
     ↓
Independent Microservices
```

This approach allows the team to establish business boundaries
without introducing the operational complexity of independently
deployed microservices during the MVP.

### Cross-cutting capabilities

Some capabilities can support multiple domains.

Identity & Access is considered transversal because several areas
of the platform need authentication, roles and permissions.

For example:

```text
Patient Management ───────┐
Professional Management ──┤
Appointment Scheduling ────┤
Medical Consultation ──────┤
Document Generation ───────┤
                           ↓
                    Identity & Access
```

Notifications is also transversal because different business
processes may generate notification events.

For example:

```text
AppointmentCreated
        ↓
Notification Service
        ↓
Confirmation notification

AppointmentCancelled
        ↓
Notification Service
        ↓
Cancellation notification

AppointmentRescheduled
        ↓
Notification Service
        ↓
Rescheduling notification
```

These capabilities are separated from the individual business
domains so that notification and access-control concerns do not need
to be implemented independently inside every module.

---

## 9. Initial Product Backlog

The team also identified the main capabilities required for the MVP.

The backlog was later refined into formal User Stories as the project requirements evolved.

For the initial engineering activity, the main capabilities were:

| Capability | Description |
|---|---|
| Patient registration | Allow a patient to create an account. |
| Patient authentication | Allow a patient to securely access the platform. |
| Patient profile | Allow the patient to manage personal information. |
| Professional management | Allow authorized users to manage healthcare professionals. |
| Professional consultation | Allow patients to view available professionals. |
| Availability consultation | Allow patients to identify available appointment slots. |
| Appointment scheduling | Allow patients to schedule an appointment. |
| Appointment management | Allow patients to review and manage their appointments. |
| Professional agenda | Allow professionals to view their scheduled appointments. |
| Consultation management | Allow professionals to manage consultation information. |
| Notifications | Provide user-facing notifications related to relevant system events. |

These capabilities were subsequently refined into the project's formal requirements and User Stories.

---

## 10. MVP 1 Acceptance Criteria

The backlog must contain acceptance criteria that can be verified through implementation and testing.

Examples of initial acceptance criteria for the main MVP capabilities are:

### Patient Registration

*Given* a user who does not have an account,
*When* the user provides valid registration information,
*Then* the system creates the patient account successfully.

### Patient Authentication

*Given* a registered patient,
*When* the patient provides valid credentials,
*Then* the system authenticates the patient and grants access to the platform.

### Availability Consultation

*Given* a patient who wants to schedule an appointment,
*When* the patient requests available professionals or appointment slots,
*Then* the system returns the currently available options.

### Appointment Scheduling

*Given* an available appointment slot,
*When* the patient confirms the scheduling request,
*Then* the system creates the appointment if the slot is still available.

### Appointment Management

*Given* a patient with a scheduled appointment,
*When* the patient requests their appointments,
*Then* the system displays the appointments associated with the patient.

### Professional Agenda

*Given* an authenticated healthcare professional,
*When* the professional requests their agenda,
*Then* the system displays the appointments associated with that professional.

---

## 11. Professional Engineering Principles Applied

The Session 2 material established several principles that were considered relevant to TeleMed IA.

**DDD**
Business domains are separated into clear bounded contexts/modules.

**Hexagonal Architecture**
Business logic is separated from infrastructure and external interfaces.

**SOLID and Clean Code**
The implementation should maintain clear responsibilities, dependency inversion, meaningful names, and separation of concerns.

**Resilience**
Distributed communication must consider failures such as:
- Timeouts.
- Service unavailability.
- Transient failures.
- Retries.
- Duplicate messages.

**Testing**
Features should be validated through appropriate tests, including unit, integration, contract, and end-to-end testing as the project evolves.

**Scrum and Git Flow**
Development is organized around weekly work, prioritized backlog items, branches, pull requests, and incremental delivery.

**ADRs**
Architectural and technical decisions are documented so that the reasoning behind important project decisions remains traceable.

---

## 12. ADR Status and Project Evolution

The architecture decision described in this activity should not be confused with the current ADR-001.

The current project documentation contains:

**ADR-001 — Documentation and Technical Language**

This ADR establishes English for technical artifacts and Spanish for user-facing MVP content.

It is a valid and accepted architectural/documentation decision currently used by the project.

The project architecture has also evolved as the requirements and design became more mature.

Therefore, the Week 1 activity is documented as an engineering foundation and not as a claim that every current project decision had already been finalized at that moment.

The current project documentation remains the authoritative source for the latest project decisions.

---

## 13. Evidence

**Official Week 1 — Session 2 Material**

The official Session 2 material defines the engineering foundations covered during the session, including DDD, Hexagonal Architecture, SOLID, resilience, testing, Scrum, Git flow and ADRs.

**Team Documentation Repository**

The `telemed-ia-docs` repository provided by the professor is the team's central documentation repository and current source of truth for the TeleMed IA project.

**ADR-001**

The current ADR-001 documents the team's decision regarding the language used for technical artifacts and user-facing content.

**Session 2 Infographic**

The Session 2 infographic summarizes the professional engineering concepts studied during the activity.

![Session 2 Infographic](<Image Week 1 - Session 2 - Fundamentals of Professional Engineering for Distributed Systems.png>)
---

## 14. Activity Result

This activity established the professional engineering foundations used by TeleMed IA.

The team recognized the need for clear domain boundaries, separation of business logic from infrastructure, testable backlog items, documented technical decisions, and development practices suitable for a distributed systems project.

For the MVP, the project uses a Modular Monolith with Hexagonal Architecture. The modules are intentionally bounded so that they can evolve into independent microservices in a future stage.

The `telemed-ia-docs` repository provided by the professor remains the single source of truth for the project's current technical and architectural documentation.