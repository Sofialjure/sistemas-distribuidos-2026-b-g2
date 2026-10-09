# Evidence

## Real TeleMed IA References

Appointment Scheduling:
https://github.com/code-corhuila/telemed-ia-appointment-scheduling-api

Medical Consultation:
https://github.com/code-corhuila/telemed-ia-medical-consultation-api

## Real Microservice Evidence

These repositories provide real microservice implementation evidence and domain
references. The commit titles below were supplied as repository-history evidence. Exact
commit SHAs and direct GitHub commit URLs could not be independently verified from the
available local repository or accessible repository pages, so no hashes, commit URLs,
or PR numbers are fabricated.

### Appointment Scheduling API

Repository: https://github.com/code-corhuila/telemed-ia-appointment-scheduling-api

The supplied repository history identifies these merged/verified commits dated October
4, 2026:

- `feat(api): bootstrap FastAPI application with health endpoint`
- `feat(api): add appointment domain model with state machine and unit tests`
- `feat(api): add application ports, DTOs and domain events`
- `feat(api): add appointment use cases with in-memory fake tests`
- `feat(api): add HTTP adapter with JWT, envelope, correlation and idempotency`
- `feat(api): add postgres adapter and runtime composition root`
- `chore(api): add ci workflow, pull request template and readme`

Together these titles indicate work on the appointment domain model and state machine,
domain events, application ports and DTOs, use cases, HTTP adapter, PostgreSQL adapter,
runtime composition, idempotency-related HTTP concerns, and CI. The titles are evidence
of implementation work; they are not evidence that this activity independently ran
those services or their tests.

### Medical Consultation API

Repository: https://github.com/code-corhuila/telemed-ia-medical-consultation-api

The supplied repository history identifies these commits and reports corresponding
merged pull requests; exact PR IDs and direct links were not available to verify:

- `feat(api): bootstrap go service with health endpoint and timeouts`
- `feat(api): add medical-consultation domain model with typed errors and unit tests`
- `feat(api): add application ports and DTOs for the consultation flow`

These titles indicate service bootstrap, a medical-consultation domain model and typed
errors, unit-test implementation, application ports, and DTOs.

**Evidence boundary:** These repositories provide real microservice implementation
evidence and domain references. They do not by themselves prove that the production
services are already connected through the Saga, Outbox, or broker demonstrated in this
educational activity.

## Domain Concepts Reused

Appointment events:
- `AppointmentCreated`
- `AppointmentCancelled`

Medical Consultation:
- `Consultation`
- `appointment_id`
- `patient_id`
- `professional_id`

## Educational Implementation

- Database-per-service demonstration with isolated SQLite files.
- One saga with a happy path.
- Compensation using an `AppointmentCancelled` event.
- Transactional outbox for `AppointmentCreated`.
- Persistent idempotent consumer using `processed_events`.
- Injected broker publication and consultation consumer failures.
- Retry of pending outbox publication.

## Evidence Matrix

| Requirement | Evidence | Type |
|---|---|---|
| Database per service | `appointment.db` and `medical_consultation.db` | Executed educational demo |
| Saga | `saga-flow.mmd` and Python execution | Educational implementation |
| Compensation | `AppointmentCancelled` failure path | Executed educational demo |
| Outbox | `outbox_events` table and retry scenario | Executed educational demo |
| Idempotent consumer | `processed_events` table and duplicate delivery | Executed educational demo |
| Appointment domain | Appointment Scheduling API repository and commit titles above | Real project evidence |
| Consultation domain | Medical Consultation API repository and commit titles above | Real project evidence |

The educational rows demonstrate the activity's local simulation only; they do not
claim production integration.

## Validation

Execution command:
```bash
python "10-week/hu-status/optional activity session 1/optional_activity_session_1.py"
```

Result: executed successfully. All printed checks reported `PASS`, including database per
service, Saga, compensation, outbox, outbox retry, idempotent consumer, failure handling,
and final consistency. The compensation path ended with a `CANCELLED` appointment and
zero consultations; the duplicate path ended with exactly one consultation.

## Git Evidence

- Commit: TO BE ADDED AFTER COMMIT
- Pull Request: TO BE ADDED AFTER PR CREATION
