# Optional Activity — Week 07 — Session 2

## Versioned Contracts and Contract Testing

### 1. Objective

The objective of this activity is to define versioned contracts, compatibility rules and a consumer-driven contract testing strategy for TeleMed IA.

MVP 1 is currently implemented as a modular monolith. Therefore, the contracts and testing strategy described in this activity establish the integration baseline for the next development stage, when the bounded contexts are progressively separated into independent microservices.

The activity is based on the communication decisions defined during Week 07 Session 1.

---

## 2. TeleMed IA Integration Context

TeleMed IA currently contains eight bounded contexts:

1. Identity & Access
2. Patient Management
3. Professional Management
4. Intelligent Agent
5. Appointment Scheduling
6. Medical Consultation
7. Notifications
8. Document Generation

The following contracts focus on planned communication between these bounded contexts when they evolve into independent microservices.

### Main planned interactions

```text
Intelligent Agent
       |
       | REST
       v
Appointment Scheduling
Appointment Scheduling
       |
       | AppointmentCreated
       v
Message Broker
       |
       v
Notifications
Medical Consultation
       |
       | REST
       v
Document Generation
```

## 3. REST Contract

A versioned OpenAPI contract was defined for the planned communication between Intelligent Agent and Appointment Scheduling.

- **Consumer**: agent-service
- **Provider**: appointment-service
- **Endpoint**: `GET /api/v1/appointments/availability`

### Purpose

The endpoint allows the Intelligent Agent to request appointment availability from the Appointment Scheduling service.

The contract defines:
- Request parameters.
- Response structure.
- HTTP status codes.
- Data types.
- API version.
- Expected behavior.

The OpenAPI contract is published in:

```
appointment-service.openapi.yaml
```

## 4. REST Versioning Rules

TeleMed IA will use explicit API versions for externally exposed service contracts.

Example:

```
/api/v1/appointments/availability
```

### Compatible changes

The following changes are considered compatible with an existing API version:
- Adding a new endpoint.
- Adding an optional response field.
- Adding optional request parameters.
- Adding documentation.
- Improving non-functional implementation details without changing the contract behavior.

### Incompatible changes

The following changes require a new major API version:
- Removing an existing endpoint.
- Removing a required field.
- Changing the data type of an existing field.
- Changing the meaning of an existing field.
- Changing a required request parameter.
- Changing an existing response in a way that breaks consumers.

Example:

```
v1
 ↓
v2
```

A new major version should be introduced when an incompatible contract change is required.

## 5. Event Contract

The asynchronous communication strategy defined in Session 1 includes the planned event:

```
AppointmentCreated
```

The event is published by the Appointment Scheduling bounded context.

```
Appointment Scheduling
        |
        | AppointmentCreated
        v
  Message Broker
        |
        v
   Notifications
```

The event schema is published in:

```
AppointmentCreated.schema.json
```

### Required event fields
- eventId
- eventType
- appointmentId
- patientId
- occurredAt

The `eventId` is particularly important because it allows consumers to identify duplicate deliveries.

## 6. Event Compatibility Rules

Event schemas must preserve compatibility with existing consumers.

### Compatible event changes

Examples include:
- Adding an optional field.
- Adding additional metadata that existing consumers can ignore.
- Adding documentation.
- Extending the event without changing the meaning of existing fields.

### Incompatible event changes

Examples include:
- Removing a required field.
- Changing the type of an existing field.
- Changing the meaning of an existing field.
- Renaming a required field without providing a compatibility strategy.
- Changing the event type semantics.

For incompatible changes, a new event version or migration strategy must be defined before deployment.

## 7. Consumer-Driven Contract Testing

A consumer-driven contract test verifies that the provider continues to satisfy the expectations defined by the consumer.

For TeleMed IA, the planned relationship is:

```
Consumer
agent-service
       |
       | Consumer Contract
       v
Provider
appointment-service
```

The consumer defines the interaction it requires.

For example:

```
GET /api/v1/appointments/availability
```

The consumer expects:

```json
{
  "professionalId": "PRO-001",
  "date": "2026-09-20",
  "available": true
}
```

The provider must continue to satisfy this contract.

## 8. Planned Contract Test Scenario

### Scenario

The Intelligent Agent requests availability from the Appointment Scheduling service.

### Request

```
GET /api/v1/appointments/availability
```

Parameters:
- professionalId = PRO-001
- date = 2026-09-20

### Expected response

```json
{
  "professionalId": "PRO-001",
  "date": "2026-09-20",
  "available": true
}
```

### Contract assertions

The contract test must verify:
- The endpoint exists.
- The endpoint accepts the required parameters.
- The response status is HTTP 200 for a valid request.
- `professionalId` is a string.
- `date` uses the expected date format.
- `available` is a boolean.
- Required response fields are present.

## 9. Consumer-Driven Contract Test in CI

The intended CI flow for the next microservice development stage is:

```
Developer Push
      |
      v
GitHub Actions
      |
      v
Contract Tests
      |
      +------ PASS ------> Build continues
      |
      +------ FAIL ------> Build fails
```

The contract test must be executed automatically as part of CI once the bounded contexts are implemented as independent services.

A provider change that violates the consumer contract should cause the CI contract test to fail.

### Current MVP status

MVP 1 is still implemented as a modular monolith.

Therefore:
- The future microservices are not claimed as currently deployed.
- The contract test is not claimed as currently running against independent services.
- The CI implementation will be incorporated when the microservice development stage and repository strategy are confirmed.

This avoids treating the current modular monolith as if it were already a distributed microservice system.

## 10. Contract Testing Strategy

The planned strategy is:

```
1. Consumer defines expectations.
        ↓
2. Contract is generated or published.
        ↓
3. Provider verifies the contract.
        ↓
4. Contract test runs in CI.
        ↓
5. Incompatible changes cause the test to fail.
```

This reduces the risk of breaking consumers when a service changes its API or event schema.

## 11. Versioning Strategy

The planned versioning rules are:

### REST

Use explicit major API versions:

```
/api/v1/...
```

A breaking change creates:

```
/api/v2/...
```

### Events

Event compatibility should be preserved whenever possible.

The event identifier:

```
eventId
```

must remain available to support duplicate detection and idempotent consumers.

### Contract ownership

Each provider bounded context is responsible for maintaining the contract of the capabilities it exposes.

Consumers are responsible for defining the interactions they depend on.

## 12. Integration Stories for the Next Development Stage

The following stories divide the integration work into testable units.

### HU-INT-01 — Appointment REST Contract

**As a** development team
**I want** to define the REST contract between Intelligent Agent and Appointment Scheduling
**so that** both services can communicate using a stable and versioned interface.

**Acceptance Criteria**
- [X] The OpenAPI contract is published in the repository.
- [X] The endpoint `/api/v1/appointments/availability` is defined.
- [X] Required request parameters are defined.
- [X] Response schema is defined.
- [X] HTTP response codes are documented.
- [X] API versioning rules are documented.
- [X] Compatibility rules are documented.

### HU-INT-02 — AppointmentCreated Event Contract

**As a** development team
**I want** to define the AppointmentCreated event contract
**so that** Notification Service can consume appointment events consistently.

**Acceptance Criteria**
- [X] The event schema is published.
- [X] `eventId` is mandatory.
- [X] `eventType` is defined.
- [X] `appointmentId` is defined.
- [X] `patientId` is defined.
- [X] `occurredAt` is defined.
- [X] Event compatibility rules are documented.

### HU-INT-03 — Consumer-Driven Contract Test

**As a** development team
**I want** to validate the contract between Intelligent Agent and Appointment Scheduling
**so that** incompatible provider changes are detected automatically.

**Acceptance Criteria**
- [X] Consumer expectations are defined.
- [X] Provider verification is defined.
- [ ] The contract test validates the expected request.
- [ ] The contract test validates the expected response.
- [ ] The contract test runs automatically in CI.
- [ ] CI fails when the provider violates the contract.

### HU-INT-04 — Idempotent Appointment Event Consumer

**As a** development team
**I want** Notification Service to process AppointmentCreated idempotently
**so that** duplicate event deliveries do not generate duplicate notifications.

**Acceptance Criteria**
- [ ] Notification Service consumes AppointmentCreated.
- [ ] `eventId` is validated.
- [ ] Processed event identifiers are recorded.
- [ ] Duplicate events are ignored.
- [ ] A notification is generated only once for the same event.
- [ ] Retry behavior is documented.

### HU-INT-05 — Medical Consultation to Document Generation Contract

**As a** development team
**I want** to define the REST contract between Medical Consultation and Document Generation
**so that** consultation information can be transformed into a clinical PDF.

**Acceptance Criteria**
- [X] The REST interaction is documented.
- [ ] Request data is defined.
- [ ] Response behavior is defined.
- [ ] Versioning rules are documented.
- [ ] Compatibility rules are documented.
- [ ] Contract testing requirements are defined.

## 13. Relationship with Session 1

Session 1 defined the communication mechanisms:
- REST
- gRPC
- Events / Messaging

Session 2 converts those communication decisions into explicit contracts and compatibility rules.

```
Session 1
Communication decisions
        ↓
Session 2
Versioned contracts
        ↓
Contract testing
        ↓
CI validation
```

The main examples are:

```
Intelligent Agent
        ↓ REST
Appointment Scheduling
```

and:

```
Appointment Scheduling
        ↓ AppointmentCreated
Message Broker
        ↓
Notifications
```

## 14. Common Risks

The following risks should be avoided:
- Changing an API without considering existing consumers.
- Removing required fields from events.
- Changing data types without versioning.
- Using undocumented APIs between services.
- Assuming that integration works without automated contract validation.
- Running contract tests only manually.
- Treating the current modular monolith as if it were already independent microservices.
- Introducing breaking changes without a migration strategy.

## 15. Decisions for the Next Development Stage

The planned decisions for TeleMed IA are:
- Use OpenAPI for REST contracts.
- Use explicit API versions such as `/api/v1/`.
- Define compatibility rules before changing contracts.
- Use JSON Schema for event definitions where appropriate.
- Preserve `eventId` for duplicate detection and idempotent processing.
- Use consumer-driven contract testing between service consumers and providers.
- Execute contract tests automatically in CI when independent microservices are implemented.
- Divide integration work into independently testable stories.
- Keep contracts synchronized with the bounded context responsibilities.

## 16. Current Status

The current MVP 1 remains a modular monolith.

The following artifacts have been prepared as the contractual design baseline:
- `appointment-service.openapi.yaml`
- `AppointmentCreated.schema.json`
- This Session 2 activity document.

The independent microservices and their CI contract-testing pipeline are planned for the next development stage and are not claimed as implemented in MVP 1.

## 17. Conclusion

Versioned contracts provide a stable communication agreement between TeleMed IA bounded contexts as they evolve into independent microservices.

The OpenAPI contract defines the planned REST interaction between Intelligent Agent and Appointment Scheduling, while the AppointmentCreated schema defines an asynchronous event contract for Notifications.

Compatibility rules and consumer-driven contract testing establish a strategy for detecting breaking changes before they affect dependent services.

MVP 1 remains a modular monolith. These artifacts provide the integration baseline for the next development stage toward independent microservices.

## Evidence

### 1. OpenAPI REST Contract

The following evidence shows the versioned OpenAPI contract for the planned communication between Intelligent Agent and Appointment Scheduling.

![OpenAPI REST Contract](<Image Week 7 - Session 2 - OpenAPI REST Contract.png>)

The contract defines the `/api/v1/appointments/availability` endpoint, its request parameters and the expected REST response.

### 2. AppointmentCreated Event Contract

The following evidence shows the JSON Schema defined for the planned `AppointmentCreated` event.

![AppointmentCreated Event Contract](<Image Week 7 - Session 2 - AppointmentCreated Event Contract.png>)

The schema defines the required event fields, including `eventId`, `eventType`, `appointmentId`, `patientId`, and `occurredAt`.

### 3. Versioning and Contract Testing Strategy

The following evidence summarizes the versioning, compatibility and consumer-driven contract testing strategy defined for the next development stage.

![Versioning and Contract Testing](<Image Week 7 - Session 2 - Versioned Contracts and Contract Testing.png>)