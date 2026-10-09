# Week 10 Session 1 — Optional Activity

## Objective

This executable educational activity demonstrates four distributed-systems concepts:

- Database per service.
- One Saga with a compensation path.
- An outbox for the critical `AppointmentCreated` event.
- An idempotent event consumer.

It also injects publication and consumer failures, retries pending publication, and
checks that the final service states are consistent.

## TeleMed IA Domain References

The domain vocabulary and architectural context come from the real project repositories:

- [Appointment Scheduling API](https://github.com/code-corhuila/telemed-ia-appointment-scheduling-api)
- [Medical Consultation API](https://github.com/code-corhuila/telemed-ia-medical-consultation-api)

The Appointment Scheduling API documents an `EventPublisher` abstraction and a
`NoOpEventPublisher`; RabbitMQ is a proposed broker, not evidence of active production
publishing. Medical Consultation has concepts such as `Consultation`, `appointment_id`,
`patient_id`, `professional_id`, `IN_PROGRESS`, `COMPLETED`, `PostSummary`, and an
`EventPublisherPort`. This activity does not claim that Medical Consultation consumes
`AppointmentCreated` through RabbitMQ.

The real repositories provide domain references. The code and flow in this folder are
an educational implementation in the course repository, not a production integration.
Document Generation is not a participant in this activity.

## Architecture

```text
Appointment Service -> appointment.db -> Outbox
                                         |
                                  Simulated Broker
                                         |
Medical Consultation Service <- medical_consultation.db
```

The broker is a synchronous in-process Python simulation. No RabbitMQ, production
database, microservice, network call, or external Python dependency is required.

## Database per Service

The simulated Appointment Service accesses only `appointment.db`, which contains
`appointments` and `outbox_events`. The simulated Medical Consultation Service accesses
only `medical_consultation.db`, which contains `consultations` and `processed_events`.
The script recreates both files beside itself on each run, keeping repeated executions
deterministic. The local `.gitignore` keeps these generated database files out of Git.
This demonstrates the database-per-service principle; it does not claim that production
TeleMed IA uses a separate physical database server for every service.

## Saga

On the happy path, the Appointment Service saves the appointment and its
`AppointmentCreated` outbox record together. The outbox publisher sends the event to the
simulated broker. Medical Consultation creates an `IN_PROGRESS` consultation and records
the event ID as processed in one local transaction. The Saga then verifies the created
appointment and consultation.

## Compensation

The demo injects an exception during consultation creation. SQLite rolls back the
consumer transaction, leaving neither a partial consultation nor a processed-event
record. The Saga emits an `AppointmentCancelled` compensation carrying the appointment
ID. The Appointment Service consumes it and changes that appointment to `CANCELLED`.
This is the compensation implemented by this educational activity; the exact flow is
not claimed to exist in the production Appointment Scheduling API.

## Outbox

Creating an appointment uses one local SQLite transaction to insert both the
appointment and its `AppointmentCreated` outbox event. Publication happens after that
transaction. The publisher reads `PENDING` records and marks a row `PUBLISHED` only
after broker publication succeeds. An injected publication failure leaves the event
pending; a later attempt publishes it and updates its status. The outbox row includes
event ID, type, JSON payload, status, creation time, and publication time.

## Idempotent Consumer

Medical Consultation stores each consumed event ID in `processed_events`, whose primary
key is unique. The consultation insert and processed-event insert share a transaction.
On a repeated delivery, the consumer finds that persistent event ID and safely ignores
the duplicate. The demo sends the exact same event twice and verifies exactly one
consultation exists.

## Failure Scenarios

- **Publication failure:** injected before broker acceptance; the outbox record remains
  `PENDING`.
- **Retry:** a subsequent publication attempt succeeds and marks the event `PUBLISHED`.
- **Consumer failure:** injected while handling `AppointmentCreated`; the local
  consultation transaction rolls back.
- **Compensation:** an `AppointmentCancelled` event changes the appointment to
  `CANCELLED` after consumer failure.
- **Duplicate delivery:** the persistent processed-event key prevents a second
  consultation.

## How to Run

From this activity's directory, run:

```bash
python optional_activity_session_1.py
```

## Expected Output

The executable prints these sections and reports `PASS` only after checking each
condition:

```text
=== DATABASE PER SERVICE ===
=== OUTBOX ===
=== SAGA - HAPPY PATH ===
=== OUTBOX FAILURE + RETRY ===
=== SAGA - FAILURE + COMPENSATION ===
=== IDEMPOTENT CONSUMER ===
=== FINAL CONSISTENCY CHECK ===
=== ACTIVITY RESULT ===
```

The actual run result belongs in [evidence.md](evidence.md); this document does not
pre-report an execution result.

## Evidence

- Real [Appointment Scheduling repository](https://github.com/code-corhuila/telemed-ia-appointment-scheduling-api)
- Real [Medical Consultation repository](https://github.com/code-corhuila/telemed-ia-medical-consultation-api)
- [Executable implementation](optional_activity_session_1.py)
- [Saga flow diagram](saga-flow.mmd)
- [Validation and Git evidence](evidence.md)

## Architectural Honesty

The real TeleMed IA microservices are used as domain and architectural references.
This optional activity is an executable educational demonstration implemented in the
distributed-systems course repository. It does not claim that the production services
currently communicate through this simulated broker.
