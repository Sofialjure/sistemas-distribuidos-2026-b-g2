# Optional Activity — Week 2 · Session 2

## Planning: Bounded Contexts, Architecture Selection and MVP 1 Backlog

---

## 1. Official Activity

The Week 2 — Session 2 activity focused on transforming the architectural
analysis from Session 1 into a concrete planning decision for the
TeleMed IA project.

The activity required the team to:

- Map the domain into bounded contexts.
- Define how the contexts relate to each other.
- Choose an architecture using an explicit decision path.
- Record the architectural decision in an ADR.
- Convert the architectural decision into backlog items.
- Define testable acceptance criteria for MVP 1.

The planning process followed:

```text
Refine the backlog
        ↓
Map bounded contexts
        ↓
Evaluate architecture alternatives
        ↓
Choose the architecture
        ↓
Record the decision
        ↓
Create backlog items
        ↓
Define testable acceptance criteria
```

---

## 2. Domain Map

The TeleMed IA domain was divided according to business capabilities.

The identified bounded contexts are:

```text
                         TeleMed IA
                              |
       -------------------------------------------------
       |        |          |          |                |
     Auth    Patient   Professional  Agent      Appointment
       |        |          |          |                |
       -------------------------------------------------
                              |
                 --------------------------------
                 |              |               |
            Consultation   Notifications   Documents
```

The contexts represent different business responsibilities and are
not defined simply by database tables or technical layers.

---

## 3. Bounded Contexts

| # | Bounded Context | Responsibility |
|---|---|---|
| 1 | Identity & Access | Registration, authentication, authorization, roles and permissions |
| 2 | Patient Management | Patient profile and information |
| 3 | Professional Management | Healthcare professional information, license and specialty |
| 4 | Intelligent Agent | Pre-consultation interaction, follow-up questions and information preparation |
| 5 | Appointment Scheduling | Availability, scheduling, cancellation, rescheduling and appointment status |
| 6 | Medical Consultation | Clinical observations, diagnosis, recommendations, medications and referrals |
| 7 | Notifications | Confirmation, cancellation, rescheduling and reminder notifications |
| 8 | Document Generation | Generation of consultation-related PDF documents |

These boundaries establish the main business areas of the platform.

---

## 4. Context Relationships

The main relationships can be represented conceptually as:

```text
Patient
   |
   +----> Identity & Access
   |
   +----> Patient Management
   |
   +----> Intelligent Agent
   |
   +----> Appointment Scheduling
                |
                +----> Professional Management
                |
                +----> Notifications
                |
                +----> Medical Consultation
                              |
                              +----> Document Generation
```

The diagram represents business relationships rather than a final
network topology.

The physical communication mechanisms may evolve as the architecture
evolves.

---

## 5. Architectural Decision Path

The architecture was evaluated using the following decision path:

```text
Does the MVP require independent deployment or scaling
of multiple business capabilities?
                     |
                    No
                     ↓
Can clear business boundaries still be established?
                     |
                    Yes
                     ↓
Can those boundaries be implemented as modules?
                     |
                    Yes
                     ↓
Can the modules be isolated using Hexagonal Architecture?
                     |
                    Yes
                     ↓
             Modular Monolith
                     |
                     ↓
Future extraction when a real need exists
                     |
                     ↓
          Selective Microservices
```

This path avoids choosing microservices simply because they are a
popular distributed architecture style.

---

## 6. Alternatives Considered

### Alternative A — Modular Monolith + Hexagonal Architecture

**Selected.**

The MVP is organized as business modules within one deployable
application, with Hexagonal Architecture used to isolate domain and
application logic from infrastructure.

**Advantages:**

- Lower operational complexity.
- Clear business boundaries.
- Easier development and testing.
- Suitable for the current MVP scope.
- Supports future service extraction.

**Disadvantages:**

- Modules are deployed together.
- Individual modules cannot be independently scaled during the MVP.

### Alternative B — Full Microservices Architecture

**Rejected for the initial MVP.**

The eight business domains could technically be implemented as
independent services.

However, starting with all services would introduce additional
complexity in:

- Network communication.
- Service deployment.
- Distributed tracing.
- Data consistency.
- Contract management.
- Testing.
- Failure handling.

The current project stage does not justify paying all of this
operational cost immediately.

### Alternative C — Traditional Monolith Without Explicit Modules

**Rejected.**

A traditional monolith would reduce operational complexity, but it
would not provide sufficiently explicit boundaries between the
business domains.

This could make future service extraction more difficult.

The selected modular monolith provides a balance between simplicity
and domain separation.

---

## 7. Architectural Decision

The selected architecture for the TeleMed IA MVP is:

> **Modular Monolith with Hexagonal Architecture and business-domain
> boundaries based on DDD.**

The architecture follows these principles:

- Business capabilities define the main module boundaries.
- Domain logic remains independent from infrastructure.
- Application use cases depend on ports rather than concrete
  infrastructure implementations.
- Infrastructure components implement the required adapters.
- Modules should not directly manipulate the internal implementation
  of other modules.
- Communication between modules should occur through defined
  interfaces or contracts.
- Future microservice extraction should follow existing business
  boundaries.
- A module should only be extracted when a concrete business,
  deployment, or scalability need justifies it.

---

## 8. Current MVP and Future Microservices

The selected direction can be represented as:

```text
                    CURRENT MVP

                Modular Monolith
                       |
       -----------------------------------------
       |       |        |       |       |      |
      Auth  Patient  Prof.   Agent  Appointment
       |       |        |       |       |      |
       -----------------------------------------
                       |
                 Same application


                       ↓
                Future Evolution


                  Microservices
                       |
       -----------------------------------------
       |       |        |       |       |      |
      Auth  Patient  Prof.   Agent  Appointment
       |       |        |       |       |      |
       -----------------------------------------
              Independent deployments
```

The eight bounded contexts remain the logical boundaries in both
stages.

The difference is the physical deployment model.

---

## 9. Future Service Boundaries

The planned future service mapping is:

| Bounded Context | Future Microservice |
|---|---|
| Identity & Access | `auth-service` |
| Patient Management | `patient-service` |
| Professional Management | `professional-service` |
| Intelligent Agent | `agent-service` |
| Appointment Scheduling | `appointment-service` |
| Medical Consultation | `consultation-service` |
| Notifications | `notification-service` |
| Document Generation | `document-service` |

These are future service boundaries rather than a claim that all of
these services are independently deployed in the current MVP.

---

## 10. Cross-cutting Capabilities

Two capabilities have an important transversal role in the platform.

**Identity & Access**

Authentication and authorization are required by multiple business
areas.

```text
Patient Management ───────┐
Professional Management ──┤
Appointment Scheduling ────┤
Medical Consultation ──────┤
Document Generation ───────┤
                           ↓
                    Identity & Access
```

The responsibility is centralized so that authentication, roles and
permissions do not need to be independently implemented in every
business module.

**Notifications**

Notifications can be triggered by multiple business processes.

```text
AppointmentCreated
        ↓
Notification Process

AppointmentCancelled
        ↓
Notification Process

AppointmentRescheduled
        ↓
Notification Process
```

This allows the notification capability to remain separate from the
business modules that generate the events.

---

## 11. Architecture Backlog

The architectural decision was translated into work that can be
incorporated into the MVP 1 backlog.

| Backlog Item | Objective |
|---|---|
| Define module boundaries | Establish clear responsibilities for each business domain. |
| Isolate domain logic | Keep business rules independent from infrastructure. |
| Define module interfaces | Prevent direct access to internal implementation between modules. |
| Implement application use cases | Organize business operations through application services/use cases. |
| Establish infrastructure adapters | Connect the application to databases, APIs and external technologies through ports. |
| Validate appointment boundary | Ensure appointment-related business rules remain inside the appropriate module. |
| Define notification integration | Separate notification processing from the primary business operation. |
| Document architecture | Keep the architectural direction and boundaries traceable in project documentation. |

---

## 12. Testable Acceptance Criteria

The architectural backlog items require verifiable acceptance criteria.

### Module Boundaries

*Given* the TeleMed IA business domains,
*When* the modules are implemented,
*Then* each module must have a clearly defined responsibility and
must not depend directly on another module's internal implementation.

### Domain Isolation

*Given* a business rule,
*When* it is implemented inside the domain layer,
*Then* the domain code must not directly depend on database,
HTTP, or external infrastructure components.

### Module Interfaces

*Given* two business modules that need to communicate,
*When* one module requests functionality from another,
*Then* the interaction must use a defined interface or contract
rather than accessing internal implementation details.

### Appointment Scheduling

*Given* an appointment slot,
*When* a patient requests an appointment,
*Then* the appointment module must validate the current state of
the slot before creating the appointment.

### Notifications

*Given* that an appointment has been successfully created,
*When* a notification process fails temporarily,
*Then* the primary appointment operation must remain valid and the
notification process must be able to retry independently.

### Architecture Documentation

*Given* an architectural decision,
*When* the decision is accepted,
*Then* its context, alternatives, decision and consequences must be
documented and traceable.

---

## 13. ADR and Documentation Evolution

The Week 2 — Session 2 activity required the architectural decision
to be recorded as an ADR.

The current `telemed-ia-docs` repository contains an accepted
`ADR-001` focused on Documentation and Technical Language. This ADR
does not represent the architecture decision required by the Week 2
activity, because it addresses a different concern.

The architectural direction established through this activity is:

**Modular Monolith + Hexagonal Architecture**, with business-domain
boundaries designed to support future selective extraction into
microservices.

The architectural decision and its evolution are maintained in the
team's documentation repository.
---

## 14. Activity Result

The activity transformed the architectural analysis into a concrete
planning decision for TeleMed IA.

The team mapped the main business capabilities into bounded contexts,
evaluated architectural alternatives, and selected a Modular Monolith
with Hexagonal Architecture for the MVP.

The decision preserves clear business boundaries while avoiding
premature distribution.

The architecture also establishes a path for future evolution toward
microservices when independent deployment, scalability, or another
concrete business or technical requirement justifies the extraction of
a bounded context.
---

## 15. Evidence

### Team Documentation Repository

The `telemed-ia-docs` repository was provided by the professor for the
TeleMed IA team and is currently used as the project's central
documentation repository and source of truth.

[telemed-ia-docs](<https://github.com/code-corhuila/telemed-ia-docs.git>)

### Domains, Future Microservices and Cross-cutting Capabilities

The domains infographic documents the business domains identified for
TeleMed IA, their responsibilities, their future microservice
boundaries, and the transversal role of Identity & Access and
Notifications.

### Week 2 — Session 2 Material

The official Session 2 material defines the planning process used to
map bounded contexts, evaluate architectural alternatives, select an
architecture, document the decision through an ADR, and convert the
decision into backlog items with testable acceptance criteria.

