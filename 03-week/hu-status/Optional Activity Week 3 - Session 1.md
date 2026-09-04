# Optional Activity — Week 3 · Session 1

## Domain Modeling: Bounded Context, Aggregate Root, Invariants and Domain Events

---

## Official Activity

This week:

Select a bounded context from your product and model that context: identify the aggregate root, its entities/value objects, the invariants it must protect, and the domain events it emits. The boundaries and contracts will be refined in Session 2 (planning).

---

## Selected Bounded Context

### Intelligent Pre-Consultation

For this activity, **Intelligent Pre-Consultation** was selected as an initial bounded context within TeleMed IA.

This context represents the patient's initial interaction with the intelligent agent, through which information related to the reason for consultation is collected and organized before medical attention.

The model presented is an initial DDD modeling proposal and may be refined later during service design and contract definition.

---

## Context Purpose

The purpose of the Intelligent Pre-Consultation context is to collect information provided by the patient through interaction with the intelligent agent, organize that information, and generate a summary that can later be used during the medical care process.

The intelligent agent acts as support for information collection but does not replace the healthcare professional.

According to the business rules defined for TeleMed IA, the agent must not:

- Issue diagnoses.
- Prescribe medications.
- Modify treatments.

---

## Aggregate Root

### Pre-Consultation

*Pre-Consultation* is proposed as the aggregate root because it represents the process of initially collecting information from the patient.

The aggregate root is responsible for controlling modifications to the information belonging to the pre-consultation and for maintaining the business rules associated with this process.

```text
                    PRE-CONSULTATION
                  ┌───────────────────┐
                  │   AGGREGATE ROOT   │
                  └─────────┬─────────┘
                            │
              ┌─────────────┼─────────────┐
              ↓             ↓             ↓
           Reason       Interactions     Status
              │
              ↓
      Collected Information
```

---

## Entities

Within the Intelligent Pre-Consultation context, the following entities are proposed.

**Pre-Consultation**

Represents the pre-consultation performed by a patient and has its own identity.

**Interaction**

Represents each interaction during the conversation between the patient and the intelligent agent.

Each interaction can be individually identified and contains information related to a question and its corresponding answer.

---

## Value Objects

The following value objects are proposed.

**Reason for Consultation**

Represents the main reason expressed by the patient for requesting medical attention.

**Pre-Consultation Status**

Represents the current state of the pre-consultation process.

Possible values include:

- `INITIATED`
- `IN_PROGRESS`
- `COMPLETED`

Value objects do not require their own identity and represent values used within the domain.

---

## Aggregate Invariants

Invariants are rules that must always be maintained to guarantee the correct behavior of the context.

For Intelligent Pre-Consultation, the following invariants are proposed:

1. The intelligent agent cannot issue diagnoses.
2. The intelligent agent cannot prescribe medications.
3. The intelligent agent cannot modify treatments.
4. Collected information must remain associated with its corresponding pre-consultation.
5. A pre-consultation must maintain a valid status throughout its lifecycle.
6. Once a pre-consultation has been completed, new interactions should not be allowed.

The first three rules are explicitly considered part of the TeleMed IA business rules.

---

## Domain Events

Domain events represent facts that have already occurred within the context.

The following events are proposed for this initial model:

```text
PreConsultationStarted
        ↓
InteractionRegistered
        ↓
InformationCollected
        ↓
PreConsultationCompleted
        ↓
SummaryGenerated
```

### Event Descriptions

- **PreConsultationStarted**: a new pre-consultation is started.
- **InteractionRegistered**: an interaction between the patient and the intelligent agent is registered.
- **InformationCollected**: new relevant information has been collected.
- **PreConsultationCompleted**: the information-collection process has been completed.
- **SummaryGenerated**: a structured summary of the collected information has been generated.

These events are proposed as part of the initial domain model and do not represent functionalities currently implemented.

---

## General Aggregate Model

```text
                         PRE-CONSULTATION
                         ┌─────────────┐
                         │    ROOT     │
                         └──────┬──────┘
                                │
                ┌───────────────┼───────────────┐
                ↓               ↓               ↓
             Reason        Interaction        Status
          for consultation                     │
                │                               │
                └───────────────┐               │
                                ↓               │
                      Collected Information     │


                    DOMAIN EVENTS
                           │
                           ↓
              ┌─────────────────────────────┐
              │ PreConsultationStarted      │
              │ InteractionRegistered       │
              │ InformationCollected        │
              │ PreConsultationCompleted    │
              │ SummaryGenerated             │
              └─────────────────────────────┘
```

---

## Relation to TeleMed IA

The selected context is related to one of the central functionalities of TeleMed IA: the interaction between the patient and an intelligent agent to collect and organize information before the medical consultation.

The project requirements establish that the agent will allow the patient to express their reason for consultation, answer follow-up questions, and organize the information provided before requesting an appointment.

Therefore, Intelligent Pre-Consultation represents an appropriate context for the initial domain-driven modeling exercise.

---

## Initial Model Consideration

This model represents an initial domain proposal created for the Week 3 Session 1 activity.

The selection of Intelligent Pre-Consultation as a bounded context does not mean that it has been definitively established as an independently deployed microservice.

The model may be refined as the project continues and as the boundaries and responsibilities of the contexts are further defined.