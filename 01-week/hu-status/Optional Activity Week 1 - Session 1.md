# Optional Activity — Week 1 · Session 1

## Distributed Systems: Initial Backlog, Consistency and Delivery Semantics

### Team

**Team:** Telemed - Group 2

**Members:**
- María Sofia Aljure Herrera
- María Juliana Ferro Bonilla
- José Miguel Vera Garzón

---

## 1. Official Activity

The activity for Week 1 — Session 1 required the team to:

- Form the project team.
- Select the real-world problem that the distributed system would solve.
- Start the product backlog.
- Identify the main operations of the system.
- Define the required consistency for each main operation.
- Define the required delivery semantics for each main operation.
- Prepare to justify these decisions during the MVP 1 design.

This activity represents the initial design stage of the project, where the team established the first functional and distributed-systems considerations for the project.

---

## 2. Project Context

The team selected the problem of improving access to and organization of telemedicine services through a platform that connects patients and healthcare professionals.

The initial project proposal defined a **Telemedicine Platform with an Intelligent Agent**.

The initial idea was for the platform to allow a patient to interact with an intelligent agent before the medical consultation. The agent would collect information about the reason for consultation, ask follow-up questions when appropriate, organize the collected information, and support the subsequent appointment process.

The initial project flow identified by the team was:

```text
Patient
   ↓
Start interaction
   ↓
Collect consultation information
   ↓
Organize information
   ↓
Check availability
   ↓
Schedule appointment
   ↓
Generate structured information for the professional
   ↓
Medical consultation
```

At this stage, the project was still in its initial proposal phase.

---

## 3. Initial Backlog

During this stage, the team began identifying the main capabilities that the platform would need.

The following items represent the initial backlog derived from the project proposal:

| Initial Item | Description | Main Actor |
|---|---|---|
| Patient access | Allow the patient to access the telemedicine platform. | Patient |
| Pre-consultation interaction | Allow the patient to explain the reason for consultation through the Intelligent Agent. | Patient |
| Information collection | Collect relevant information from the patient through the pre-consultation interaction. | Intelligent Agent |
| Information organization | Organize the collected information into a structured format for later consultation. | Intelligent Agent |
| Availability consultation | Allow the patient to consult available professionals and appointment slots. | Patient |
| Appointment scheduling | Allow the patient to select an available professional and schedule an appointment. | Patient |
| Appointment consultation | Allow the patient to review information about a scheduled appointment. | Patient |
| Professional information access | Allow the healthcare professional to access the information prepared before the consultation. | Professional |

These items represent the starting point of the backlog and were not yet formalized as the final User Stories of the project.

---

## 4. Main Operations Identified

Based on the initial project proposal, the following operations were identified as important for the distributed system:

1. Patient access and authentication.
2. Pre-consultation interaction with the Intelligent Agent.
3. Collection and organization of consultation information.
4. Availability consultation.
5. Appointment scheduling.
6. Appointment consultation.
7. Access to structured information by the professional.

At this stage, these operations were identified at a functional level.

---

## 5. Initial Consistency Considerations

Consistency was considered according to the importance and consequences of each operation.

These were initial design considerations based on the distributed-systems concepts studied in Session 1.

| Main Operation | Initial Consistency Consideration | Reason |
|---|---|---|
| Patient access and authentication | Strong | Authentication should use current account and credential information. |
| Pre-consultation interaction | Causal | The information collected during the interaction follows a logical sequence of patient responses and agent questions. |
| Information organization | Causal | Information generated from the interaction should preserve the logical relationship between the collected data and the resulting structured information. |
| Availability consultation | Strong | Availability should reflect current appointment information to avoid presenting outdated slots. |
| Appointment scheduling | Strong | Scheduling must prevent conflicting reservations for the same professional and time slot. |
| Appointment consultation | Read-your-writes | After an appointment is created or updated, the patient should be able to see the latest successful change. |
| Professional information access | Read-your-writes / Strong where required | The professional should receive the relevant and valid information associated with the patient's consultation. |

---

## 6. Initial Delivery Semantics Considerations

The team considered how the main operations should communicate across the distributed system.

The main distinction was between:

- **Synchronous communication**, when the caller requires an immediate response.
- **Asynchronous communication**, when the operation can be processed independently through events.

The following considerations were identified:

| Main Operation | Initial Communication Approach | Delivery Consideration | Reason |
|---|---|---|---|
| Patient access and authentication | Synchronous | Request/response | The patient requires an immediate result from the authentication operation. |
| Pre-consultation interaction | Synchronous | Request/response | The patient and Intelligent Agent interact as part of the active consultation flow. |
| Availability consultation | Synchronous | Request/response | The patient needs the availability information before selecting a slot. |
| Appointment scheduling | Synchronous | Request/response | The patient needs immediate confirmation or rejection of the scheduling request. |
| Appointment consultation | Synchronous | Request/response | The patient requests current appointment information. |
| Information organization | Synchronous within the initial interaction | Depends on implementation | The structured information needs to be available for the subsequent consultation flow. |
| Secondary notifications | Asynchronous | At-least-once with idempotent processing | Notifications do not need to block the primary appointment operation and can be retried if delivery fails. |

---

## 7. Appointment Scheduling as a Critical Operation

Appointment scheduling was identified as an operation that requires special attention because the same professional and time slot should not be assigned to multiple patients.

A simplified concurrent scenario is:

```text
Patient A ───────┐
                 ├──► Appointment Scheduling
Patient B ───────┘
                         ↓
                  Same time slot
```

If two patients attempt to reserve the same slot concurrently, the system must ensure that only one reservation succeeds.

Therefore, the initial design consideration was:

```text
Check availability
        ↓
Patient selects a slot
        ↓
Revalidate availability
        ↓
Create appointment
```

The availability should be checked again before confirming the appointment so that the system does not rely only on an earlier availability response that may have become outdated.

---

## 8. Synchronous and Asynchronous Communication

For the initial design, user-facing operations were considered candidates for synchronous request/response communication because the user is waiting for a result.

For example:

```text
Patient
   ↓
System
   ↓
Check availability
   ↓
Return available options
```

Similarly, appointment scheduling requires an immediate result:

```text
Patient
   ↓
Schedule appointment
   ↓
Validate availability
   ↓
Create appointment
   ↓
Confirmation / rejection
```

Secondary processes can instead use asynchronous communication.

For example:

```text
Appointment created
        │
        │ Domain Event
        ↓
Notification process
        ↓
Confirmation notification
```

This separation allows secondary processes to be retried without necessarily invalidating the primary business operation.

---

## 9. Delivery Guarantees and Idempotency

The Session 1 material introduced three delivery guarantees:

- **At-most-once**: a message may be lost, but should not be delivered more than once.
- **At-least-once**: a message may be delivered more than once and therefore requires idempotent processing.
- **Exactly-once**: cannot be assumed as a simple network delivery guarantee; reliable exactly-once processing requires mechanisms such as idempotency and deduplication.

For the initial TeleMed IA design, asynchronous secondary processes were considered candidates for at-least-once delivery, with idempotent consumers.

A simplified example is:

```text
AppointmentCreated
        ↓
Notification Service
        ↓
Process event
        ↓
Send notification
```

If the same event is received again:

```text
AppointmentCreated
        ↓
Check eventId
        ↓
Already processed?
        ↓
Yes → Ignore duplicate
```

This consideration helps prevent duplicated effects when an event is redelivered.

---

## 10. Consistency and Availability Trade-off

The initial analysis recognized that consistency should not necessarily be identical for every operation.

Operations that directly affect important business state, especially appointment availability and appointment creation, require stronger consistency because stale information could produce an invalid result.

Other information flows can tolerate a different consistency model when immediate global agreement is not required.

Therefore, the initial design principle was:

> Consistency requirements should be selected per operation according to its business importance and failure consequences.

---

## 11. Initial Failure Scenario

A relevant failure scenario for the project is the loss of communication with a secondary notification process after an appointment has already been successfully created.

```text
Patient
   ↓
Appointment Scheduling
   ↓
Appointment = CONFIRMED
   ↓
AppointmentCreated event
   ↓
Notification Service
   X
Temporary failure
```

The initial design consideration was that the appointment should not automatically become invalid simply because the secondary notification process failed.

Instead:

```text
Appointment = CONFIRMED
        ↓
Notification failed
        ↓
Retry later
```

This separates the primary business transaction from a secondary process.

---

## 12. Initial Design Decisions Summary

| Concern | Initial Consideration |
|---|---|
| Authentication | Strong consistency |
| Pre-consultation interaction | Causal consistency |
| Information organization | Causal consistency |
| Availability | Strong consistency |
| Appointment scheduling | Strong consistency |
| Appointment consultation | Read-your-writes |
| Professional information access | Read-your-writes / Strong where required |
| User-facing operations | Synchronous communication |
| Secondary notifications | Asynchronous communication |
| Asynchronous delivery | At-least-once |
| Duplicate event handling | Idempotent processing |
| Appointment conflict prevention | Required |
| Notification failure | Retry without invalidating the primary operation |
| Consistency strategy | Selected per operation |

---

## 13. Evidence

The following evidence supports the work documented in this activity.

**Initial Project Proposal**

The initial project proposal provides evidence of the project problem selected by the team, the team members, and the initial functional flow of the TeleMed IA platform.

[Initial Project Proposal](<Telemedicine Platform Proposal with Intelligent Agent.pdf>)

**Session 1 Infographic**

The Session 1 infographic supports the distributed-systems concepts used in this activity, including consistency, CAP/PACELC, communication, delivery semantics, and idempotency.

![Session 1 Infographic](<Image Week 1 - Session 1 - Models, Time, Consistency, and Trade-offs.png>)

---

## 14. Activity Result

The team established the initial foundations for the TeleMed IA distributed system by identifying the real-world problem, beginning the backlog, identifying the main system operations, and analyzing the consistency and delivery semantics required by those operations.

These initial definitions provide a basis for the subsequent development of the project's requirements and MVP 1 design.