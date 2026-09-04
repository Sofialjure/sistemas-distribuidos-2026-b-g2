# Optional Activity — Week 3 · Session 2

## Service Contracts, Data Ownership, Anti-Corruption Layer and First Vertical Feature

---

## Official Activity

**This week:**

For MVP 1, define the **contracts** between your services (synchronous and/or event-based), decide **data ownership** for each entity, add an **Anti-Corruption Layer (ACL)** where external systems are consumed, and divide the **first vertical feature** into stories with testable acceptance criteria.

---

## Purpose

This activity develops an initial service-planning proposal for TeleMed IA based on the DDD model created in Session 1.

The purpose is to define an initial approach for:

- Data ownership.
- Service contracts.
- Synchronous and asynchronous communication.
- Anti-Corruption Layer considerations.
- The first vertical feature for MVP 1.
- User stories with testable acceptance criteria.

These proposals may be refined later as the service boundaries, APIs, and architecture evolve.

---

## Data Ownership

The proposed rule is that **each piece of data has a single owning service**. Other services should not access the owner's database directly; they should communicate through defined contracts.

The initial ownership proposal for TeleMed IA is:

| Data | Proposed Owner Service |
|---|---|
| User | User Management Service |
| Patient | User Management / Patient Service |
| Professional | Professional Service |
| Pre-Consultation | Intelligent Pre-Consultation Service |
| Appointment | Appointment Service |
| Medical Consultation | Medical Consultation Service |
| Summary | Summary/Document Service |
| Notification | Notification Service |

This is an initial proposal. Definitive data ownership may be refined during the subsequent service and architecture design.

---

## Service Contracts

Services should communicate through explicit contracts instead of directly accessing another service's data.

For the first MVP flow, the following contracts are proposed.

### Consult Availability

**Method:**

```text
GET /api/v1/availability
```

**Purpose:**

Allow the Intelligent Pre-Consultation context to request available appointment slots from the Appointment Service.

**Proposed response:**

```json
{
  "professionalId": "P001",
  "date": "2026-09-01",
  "availableSlots": [
    "09:00",
    "10:00"
  ]
}
```

### Schedule Appointment

**Method:**

```text
POST /api/v1/appointments
```

**Purpose:**

Register an appointment after the patient selects and confirms an available time slot.

**Proposed response:**

```json
{
  "appointmentId": "C001",
  "status": "CONFIRMED"
}
```

The Appointment Service is responsible for registering the appointment and protecting the rule that the same slot cannot be assigned simultaneously to different patients.

### Save Summary

**Method:**

```text
POST /api/v1/summaries
```

**Purpose:**

Store the structured summary generated from the pre-consultation.

These contracts are initial proposals and may be refined during the detailed API and service design.

---

## Synchronous and Asynchronous Communication

The initial proposal distinguishes between synchronous communication and domain events according to whether an immediate response is required.

### Synchronous Communication

Synchronous communication is proposed when the caller needs an immediate response to continue the process.

For example, when the patient needs to see available appointment slots:

```text
Intelligent Pre-Consultation
          │
          │ GET /api/v1/availability
          ▼
   Appointment Service
          │
          │ Available slots
          ▼
Intelligent Pre-Consultation
```

The availability response is required immediately because the patient needs to select an available appointment time.

### Asynchronous Communication

Asynchronous communication can be used for actions that do not require an immediate response.

For example:

```text
Appointment Confirmed
          │
          ▼
Notification Service
          │
          ▼
    Send Notification
```

The appointment confirmation can generate a domain event that is consumed by the Notification Service.

The final selection of synchronous or asynchronous communication may be refined as the service contracts are implemented.

---

## Anti-Corruption Layer (ACL)

An Anti-Corruption Layer (ACL) is proposed when TeleMed IA consumes information from an external system or legacy application.

The ACL would translate the external model into the TeleMed IA domain model so that external names, structures, or rules do not directly enter the domain.

```text
External System
      │
      ▼
     ACL
      │
      ▼
TeleMed IA Domain
```

At this stage, no specific external system integration has been defined within the project scope that requires an ACL. Therefore, no concrete ACL adapter is established yet.

If an external integration is introduced later, the ACL will act as a translator between the external model and the corresponding TeleMed IA domain model.

---

## First Vertical Feature for MVP 1

The proposed first vertical feature is:

> **Pre-Consultation and Appointment Scheduling**

The objective is to define a small but complete functionality that can be demonstrated from beginning to end.

### Proposed Flow

```text
Patient
   │
   ▼
Start Pre-Consultation
   │
   ▼
Agent Collects Information
   │
   ▼
Consult Availability
   │
   ▼
Patient Selects Time Slot
   │
   ▼
Confirm Appointment
   │
   ▼
Appointment Registered
```

This flow is based on the TeleMed IA scenario for pre-consultation and appointment scheduling.

---

## Vertical Slice User Stories

### HU-VS-01 — Start Pre-Consultation

**User story:**

As a patient, I want to start a pre-consultation with the intelligent agent so that I can explain my reason for consultation.

**Acceptance criteria:**

- The patient can start a new pre-consultation.
- A new pre-consultation is associated with the corresponding patient.

### HU-VS-02 — Collect Information

**User story:**

As a patient, I want to answer the agent's questions so that I can provide information related to my reason for consultation.

**Acceptance criteria:**

- The patient's responses remain associated with the corresponding pre-consultation.
- The collected information can be organized for generating the consultation summary.
- A completed pre-consultation does not allow new interactions to be registered.

### HU-VS-03 — Consult Availability

**User story:**

As a patient, I want to consult available appointment times so that I can select a suitable time for my appointment.

**Acceptance criteria:**

- The system displays only available appointment slots.
- The availability information corresponds to the selected professional and date.

### HU-VS-04 — Schedule Appointment

**User story:**

As a patient, I want to select and confirm an available time slot so that I can schedule my appointment.

**Acceptance criteria:**

- The patient can select an available time slot.
- The system registers the appointment after confirmation.
- The system prevents the same time slot from being assigned simultaneously to different patients.
- The appointment receives a valid confirmation status after successful registration.

---

## Proposed Service Interaction

The first vertical feature could initially involve the following services:

```text
                 TeleMed IA
                     │
                     ▼
          ┌────────────────────┐
          │ Intelligent        │
          │ Pre-Consultation   │
          └─────────┬──────────┘
                    │
                    │ Consult availability
                    ▼
          ┌────────────────────┐
          │ Appointment        │
          │ Service            │
          └─────────┬──────────┘
                    │
                    │ Appointment confirmed
                    ▼
          ┌────────────────────┐
          │ Notification       │
          │ Service            │
          └────────────────────┘
```

This represents an initial proposal for service interaction and is not considered a definitive service architecture.

---

## Relationship with the Session 1 DDD Model

The planning activity is based on the Intelligent Pre-Consultation bounded context modeled during Session 1.

The Session 1 model identified:

- Pre-Consultation as the Aggregate Root.
- Interaction as an entity.
- Reason for Consultation and Pre-Consultation Status as value objects.
- Business invariants.
- Domain events related to the pre-consultation lifecycle.

The Session 2 planning uses this domain model as a starting point and extends the analysis toward:

```text
DDD Model
    ↓
Bounded Context
    ↓
Data Ownership
    ↓
Service Contracts
    ↓
Communication
    ↓
Vertical Slice for MVP 1
```

The Session 2 proposal does not replace the Session 1 domain model. It represents an initial proposal for translating the domain model into service interactions and an MVP vertical feature.

---

## Activity Result

The activity produced an initial service-planning proposal for TeleMed IA that defines:

- A proposed owner for each main data entity.
- Initial synchronous API contracts for availability, appointment scheduling, and summary storage.
- An asynchronous domain-event flow for appointment notifications.
- An ACL strategy for future external integrations.
- A first vertical feature covering pre-consultation and appointment scheduling.
- Four vertical-slice user stories with testable acceptance criteria.

These decisions are initial proposals and may be refined as the service boundaries, contracts, and MVP architecture evolve.