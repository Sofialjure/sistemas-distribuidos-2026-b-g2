# Optional Activity — Week 07 — Session 1

## Inter-service Communication — REST, gRPC and Messaging

### 1. Objective

The objective of this activity is to define how the TeleMed IA bounded contexts will communicate when the current modular monolith evolves toward independent microservices.

MVP 1 is currently implemented as a modular monolith. Therefore, the communication strategies described in this activity represent the planned approach for the next development stage and do not claim that these inter-service mechanisms are already implemented.

---

## 2. Communication Strategy for TeleMed IA

When the bounded contexts are separated into independent microservices, each interaction must be evaluated according to its communication requirements.

The main decision is whether the interaction should be:

- **Synchronous:** the caller waits for a response.
- **Asynchronous:** the caller publishes an event or message and continues without waiting for the final processing.

For synchronous communication, REST is the primary option for most interactions. gRPC may be considered for internal service-to-service interactions that require high performance or low latency.

For asynchronous communication, events and messaging will be considered for operations that do not require an immediate response and can benefit from service decoupling.

---

## 3. Planned Service Interactions

| Interaction | Communication | Technology | Justification |
|---|---|---|---|
| Patient Management → Appointment Scheduling | Synchronous | REST | Appointment operations may require patient information immediately before continuing the process. |
| Appointment Scheduling → Patient Management | Synchronous | REST | The appointment service may need to retrieve patient information and receive a response before completing an operation. |
| Intelligent Agent → Appointment Scheduling | Synchronous | REST | The intelligent agent may need an immediate response when consulting availability or requesting an appointment operation. |
| Appointment Scheduling → Notifications | Asynchronous | Event / Topic | A notification does not need to block the appointment operation. The appointment can be processed while the notification is handled asynchronously. |
| Appointment Scheduling → Medical Consultation | Synchronous | REST | When information from a medical process is required immediately, request/response communication provides a direct response. |
| Appointment Scheduling → Audit/other consumers | Asynchronous | Event / Topic | Multiple consumers can react independently to an appointment-related event without tightly coupling the services. |

> **Note:** These interactions are part of the planned microservice communication design. They do not represent currently deployed independent services in MVP 1.

---

## 4. Synchronous Communication

### 4.1 REST

REST will be considered the default synchronous communication mechanism for TeleMed IA service interactions.

REST uses HTTP and JSON to implement request/response communication.

Example:

```text
Intelligent Agent
       |
       | GET /appointments/availability
       v
Appointment Service
       |
       | Response
       v
Intelligent Agent
```
REST is appropriate when the calling service needs an immediate response to continue its process.

## Advantages
- Human-readable requests and responses.
- Widely supported by development tools.
- Easy integration with HTTP-based systems.
- Suitable for external APIs and most service interactions.
- Compatible with OpenAPI for contract definition.

## Considerations
- The caller remains dependent on the availability of the receiving service.
- Long synchronous chains can increase latency.
- Timeouts, retries and circuit breakers should be considered for critical interactions.
- Large payloads should be avoided when possible.

## 5. gRPC

gRPC may be considered for internal service-to-service communication when high performance, low latency or strongly typed contracts are required.

gRPC uses a `.proto` contract to define services and messages.

Example:

```proto
service AppointmentService {
    rpc CheckAvailability (AvailabilityRequest)
        returns (AvailabilityResponse);
}

message AvailabilityRequest {
    string professionalId = 1;
}

message AvailabilityResponse {
    bool available = 1;
}
```

### Advantages
- High performance.
- Low latency.
- Strongly typed contracts.
- Efficient binary communication.
- Suitable for internal service-to-service communication.

### Considerations
- Less human-readable than REST/JSON.
- Requires additional tooling.
- Less convenient for public APIs and browser-based clients.

For TeleMed IA, gRPC is therefore considered a possible option for selected internal interactions rather than the default communication mechanism for every service.

## 6. Asynchronous Communication

Asynchronous communication allows a service to publish an event without waiting for every consumer to finish processing it.

Example:

```
Appointment Service
        |
        | AppointmentCreated
        v
   Message Broker
        |
        +--------------------+
        |                    |
        v                    v
Notification Service    Audit Service
```

A message broker such as Kafka or RabbitMQ can be used in the future microservice architecture.

### Queue

A queue distributes work among consumers.

```
Producer
    |
    v
  Queue
    |
    +------> Consumer 1
    |
    +------> Consumer 2
    |
    +------> Consumer N
```

### Topic / Publish-Subscribe

A topic allows multiple consumers to receive the same event.

```
Producer
    |
    v
  Topic
    |
    +------> Notification Service
    |
    +------> Audit Service
    |
    +------> Other Consumer
```

This model is useful when several bounded contexts need to react to the same business event.

## 7. Example Event — AppointmentCreated

A planned event for TeleMed IA could be:

```json
{
  "eventId": "evt-001",
  "eventType": "AppointmentCreated",
  "appointmentId": "APT-100",
  "patientId": "PAT-20",
  "occurredAt": "2026-09-15T10:00:00Z"
}
```

The `eventId` is important because it can be used to identify duplicate deliveries and support idempotent processing.

## 8. Idempotent Consumer

At least one asynchronous consumer must be designed to be idempotent.

For TeleMed IA, the Notification Service can be used as the example consumer.

Suppose the Appointment Service publishes:

```
AppointmentCreated
eventId = evt-001
```

Due to a retry or network failure, the same event may be delivered more than once:

```
evt-001
evt-001
```

The Notification Service must not create two identical notifications.

### Idempotent processing

```
Receive event
      |
      v
Is eventId already processed?
      |
   +--+--+
   |     |
  YES    NO
   |     |
Ignore   Process event
         |
         v
   Save eventId
```

The consumer can maintain a record of processed event IDs.

Example:

```
Event received: evt-001

Already processed?
    YES → Ignore duplicate
    NO  → Create notification
          Save evt-001
```

This allows the consumer to safely handle at-least-once message delivery.

## 9. Delivery Semantics

Distributed systems can experience message loss, duplication or retries.

| Delivery semantic | Meaning | Main risk |
|---|---|---|
| At most once | Message may be delivered zero or one time | Message loss |
| At least once | Message may be delivered one or more times | Duplicates |
| Exactly once | End-to-end exactly-once delivery is not guaranteed | Requires application-level design |

For TeleMed IA, asynchronous consumers should therefore be designed to tolerate message re-delivery.

A practical strategy is:

```
At-least-once delivery
        +
Idempotency key
        +
Duplicate detection
        =
Safe repeated processing
```

## 10. Choosing Communication per Interaction

The communication mechanism should depend on the requirements of each interaction.

| Question | Synchronous | Asynchronous |
|---|---|---|
| Is an immediate response required? | Yes | No |
| Should the caller continue if the receiver is temporarily unavailable? | No | Yes |
| Do multiple consumers need the same event? | Usually no | Yes |
| Is the interaction public/browser-facing? | REST | — |
| Is the interaction internal and performance-sensitive? | gRPC | Events may also be considered |
| Can the operation be processed later? | No | Yes |

The decision should be based on correctness, availability, latency and coupling rather than simply choosing one technology for the entire system.

## 11. Real-World Failure Scenario

A long chain of synchronous calls can create cascading failures.

Example:

```
Appointment Service
        |
        v
Payment Service
        |
        v
Fraud Detection Service
        |
        v
Slow response
```

If the last service becomes slow, the previous services may remain waiting for responses.

Potential consequences include:
- Increased latency.
- Thread accumulation.
- Exhausted connection pools.
- Cascading failures.

A possible solution is to convert non-critical operations into asynchronous events.

For example:

```
Appointment Service
        |
        | AppointmentCreated
        v
     Broker
        |
        v
Notification Service
```

The main operation can continue without waiting for the notification service to finish.

Synchronous calls that remain necessary should use appropriate timeouts, retries and circuit breakers.

## 12. Common Mistakes

The following risks should be avoided during the microservice development stage:
- Creating long synchronous chains such as A → B → C → D.
- Assuming that every message will be delivered exactly once.
- Using asynchronous communication when an immediate response is actually required.
- Using synchronous communication for operations that do not need an immediate response.
- Omitting timeouts in synchronous calls.
- Omitting retry strategies where they are appropriate.
- Omitting circuit breakers for critical synchronous dependencies.
- Creating asynchronous consumers that are not idempotent.
- Using messaging without defining event identifiers and processing rules.

## 13. Decisions for the Next Development Stage

Based on this activity, the planned communication strategy for TeleMed IA is:
- Use REST as the primary synchronous communication mechanism.
- Consider gRPC for selected internal interactions requiring high performance or low latency.
- Use events/topics or queues for asynchronous interactions that do not require an immediate response.
- Design at least one consumer to be idempotent.
- Use an event identifier to support duplicate detection.
- Avoid unnecessarily long synchronous chains.
- Define timeouts, retries and circuit breakers for critical synchronous interactions.
- Formalize these communication decisions as versioned contracts during Session 2.

## 14. Conclusion

The communication strategy for TeleMed IA must be defined according to the requirements of each interaction.

REST provides a practical synchronous mechanism, gRPC can support selected high-performance internal interactions, and asynchronous messaging can provide greater decoupling and resilience.

The current MVP 1 remains a modular monolith. These communication decisions establish the design baseline for the next stage, when the bounded contexts are progressively separated into independent microservices.

## 15. Evidence

### Evidence 1 — Session 1 Infographic

The infographic summarizes the main concepts covered during Week 07 Session 1, including synchronous and asynchronous communication, REST, gRPC, messaging, delivery semantics, idempotency, interaction selection, and common mistakes.

![REST gRPC and Messaging](<Image Week 7 - Session 1 - Inter-service Communication REST gRPC and Messaging.png>)

### Evidence 2 — TeleMed IA Communication Design

This diagram applies the concepts from the session to the planned communication architecture of TeleMed IA.

It shows the proposed use of REST, gRPC and asynchronous messaging between the bounded contexts when the current modular monolith evolves toward independent microservices.

The diagram also identifies an idempotent consumer for asynchronous event processing.

![TeleMed IA Inter-service Communication Design.png](<Optional Activity Week 7 - Session 1 - TeleMed IA Inter-service Communication Design.png>)

                              MVP 1: Modular Monolith

                                        ↓
                                Next Development Stage

                                        ↓
                            Independent Microservices

> Note: The diagram represents the planned communication design for the next development stage. These independent inter-service communication mechanisms are not claimed as implemented in MVP 1.