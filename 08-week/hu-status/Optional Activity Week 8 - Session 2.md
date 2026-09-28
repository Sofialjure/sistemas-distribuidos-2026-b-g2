# Optional Activity — Week 08 — Session 2

## Story Mapping, Planning Poker, and Proposed MVP 2

### Evidence labels

- **Documented:** stated in the TeleMed IA product backlog, roadmap, user-story catalog,
  service dependency map, or API contract.
- **Derived:** an implication of those documented stories/dependencies.
- **Proposed:** a planning choice for this activity. It is not an approved scope or a recorded
  team estimate.

The project documentation describes TeleMed IA as a modular monolith whose target architecture
has independently deployable services. A target service boundary is not evidence that the
service is already independently deployed. User-story statuses and operational estimates are
maintained in GitHub Projects; the activity does not infer them where they are unavailable.

### 1. Product story map

The backbone below follows the documented patient-to-professional care flow. The final column
marks the **proposed MVP 2 slice**; all other stories remain product context, prerequisites, or
later scope.

| User activity / backbone | User tasks / documented stories | Proposed MVP 2 scope |
|---|---|---|
| Access the platform | HU-01 register; HU-02 log in/out; HU-03 recover password | HU-01/HU-02 are prerequisites from the earlier core flow; HU-03 is deferred. |
| Maintain identity and profiles | HU-04 manage patient profile; HU-05 manage users and professionals | Not selected. HU-05 is also the Week 08 implementation focus, but it is not in the product roadmap's Sprint 2 story set. |
| Prepare for care | HU-06 complete agent pre-consultation and create a structured summary | Prerequisite for the professional schedule story; verify delivery status before commitment. |
| Find and book care | HU-07 view availability; HU-08 schedule an appointment | Earlier-flow prerequisites; their delivery status must be confirmed in the project board. |
| Manage appointments and prepare the professional | HU-09 view/cancel/reschedule; HU-10 view assigned professional schedule and pre-consultation information; HU-11 update permitted appointment status | **Selected:** HU-09, HU-10, HU-11. |
| Record and complete care | HU-12 record medical care; HU-13 record referral; HU-14 finalize consultation | HU-12 is a candidate but deferred; HU-13/HU-14 belong to a later roadmap increment. |
| Review care and documents | HU-15 view post-consultation summary; HU-16 download summary as PDF | Later roadmap increments. |
| Stay informed | HU-17 receive confirmation/cancellation/rescheduling notifications; HU-18 receive reminders | HU-17 is a candidate but deferred from this capacity-limited slice; HU-18 is later roadmap scope. |

### 2. MVP 2 candidate stories

The roadmap groups HU-03, HU-04, HU-09, HU-10, HU-11, HU-12, and HU-17 under Sprint 2.
They are treated as **candidate stories** here; the proposed MVP 2 boundary selects only a
cohesive appointment-management/professional-preparation slice.

| HU / Story | Description | Backlog priority | MVP 2? | Dependencies documented in the story catalog |
|---|---|---|---|---|
| HU-03 — Password Recovery | Let a user securely regain access to an account. | Should Have | No — defer | HU-01; Notifications supports delivery. |
| HU-04 — Patient Profile Management | Let a patient view/update authorized personal information. | Must Have | No — defer | HU-01, HU-02. |
| HU-09 — Manage My Appointments | Let a patient view, cancel, or reschedule appointments. | Must Have | **Yes — proposed** | HU-08. |
| HU-10 — View Professional Appointment Schedule | Let a professional view assigned appointments and associated pre-consultation status/summary. | Must Have | **Yes — proposed** | HU-06, HU-08. |
| HU-11 — Update Appointment Status | Let a professional update allowed appointment status. | Must Have | **Yes — proposed** | HU-10. Manual completion is not the consultation-completion mechanism. |
| HU-12 — Record Medical Care | Let a professional record observations, diagnosis, recommendations, and medication information. | Must Have | No — defer | HU-10. |
| HU-17 — Receive Appointment Notifications | Email a patient after an appointment is confirmed, cancelled, or rescheduled. | Should Have | No — defer | HU-08, HU-09; consumes appointment events. |

**Dependency/status gate:** HU-06 and HU-08 are prerequisites recorded by the user-story
catalog, not assumed to be complete merely because they appear earlier in the roadmap. Confirm
their acceptance tests and current project-board status before committing HU-10 or HU-09.

### 3. Planning Poker

**Proposed estimates, not historical project facts.** Use the Fibonacci-style scale
`1, 2, 3, 5, 8, 13`. No project-specific estimation scale or story-point values for these
Sprint 2 stories were found in the reviewed product documentation; the user-story catalog says
points are tracked in GitHub Projects.

| HU / Story | Estimate (SP) | Reason for proposed estimate |
|---|---:|---|
| HU-03 — Password Recovery | 5 | Expiring/reusable recovery credentials, security cases, and notification delivery across auth and notification boundaries. |
| HU-04 — Patient Profile Management | 3 | A focused profile read/update with ownership checks and field validation; moderate authorization and persistence testing. |
| HU-09 — Manage My Appointments | 5 | Patient ownership, permitted lifecycle transitions, conflict revalidation on rescheduling, and negative/error cases. |
| HU-10 — View Professional Appointment Schedule | 5 | Professional ownership checks and joining appointment data with pre-consultation status/summary access; contract and privacy testing. |
| HU-11 — Update Appointment Status | 3 | A small endpoint/use case, but status transition rules and the distinction between `NO_SHOW`/`CANCELLED` and event-driven `COMPLETED` need focused tests. |
| HU-12 — Record Medical Care | 8 | Multiple clinical fields, persistence and validation, professional authorization, and higher integration/privacy risk. |
| HU-17 — Receive Appointment Notifications | 5 | Three appointment event types, email generation, retry/failure behavior, idempotency, and cross-service contract tests. |
| **Sprint 2 candidate total** | **34** | Proposed estimates for all seven roadmap candidates, not a commitment. |

### 4. Service dependencies for the proposed MVP 2

The service names below are the documented target service names. The project describes the
message broker as **proposed**, not selected; event rows therefore name the documented
“Domain Event Infrastructure” rather than inventing a broker technology.

| From service (consumer) | To service / producer | Required information / dependency reason | Contract evidence | Sequence |
|---|---|---|---|---|
| `appointment-service` | `professional-service` (REST provider) | Professional identity/eligibility is required for availability and appointment operations. | Target OpenAPI artifacts exist for both [appointment-service](https://github.com/code-corhuila/telemed-ia-docs/blob/main/07-api/contracts/openapi/appointment-service.yaml) and [professional-service](https://github.com/code-corhuila/telemed-ia-docs/blob/main/07-api/contracts/openapi/professional-service.yaml). | Define the provider response and authorization/error behavior before appointment integration; simulate the provider while either service is developed. |
| `appointment-service` | `agent-service` (event producer) | HU-10 depends on HU-06; the appointment must be able to associate the patient's generated pre-consultation summary. | The dependency map documents `PreConsultationSummaryGenerated` from agent to appointment; event ownership/schema source is the [domain-event catalog](https://github.com/code-corhuila/telemed-ia-docs/blob/main/02-domain/domain-events.md). | Agree the event payload and summary-reference semantics first; implement the consumer against a contract fixture. |
| `notification-service` (HU-17 deferred) | `appointment-service` (event producer) | Confirmation, cancellation, and rescheduling messages react to completed appointment facts. | The documented events are `AppointmentCreated`, `AppointmentCancelled`, and `AppointmentRescheduled`; see the [dependency map](https://github.com/code-corhuila/telemed-ia-docs/blob/main/09-microservices/dependency-map.md) and [event catalog](https://github.com/code-corhuila/telemed-ia-docs/blob/main/02-domain/domain-events.md). | Define/validate event schemas before a future HU-17 implementation. This edge is **outside the proposed MVP 2 slice**. |
| `appointment-service` (HU-11 future lifecycle) | `consultation-service` (event producer) | Completion of a medical consultation, rather than a manual professional status edit, changes an appointment to `COMPLETED`. | The dependency map records `ConsultationCompleted` from consultation to appointment. | Defer event consumption to the later HU-14 consultation-finalization flow; HU-11 must not let a professional manually complete the consultation. |

The project also routes client traffic through the API Gateway. That is a documented
infrastructure route, not an additional business-service dependency. Services must not read
another service's database directly.

### 5. Dependency sequence and parallel work

1. **Validate prerequisites and acceptance:** confirm HU-06/HU-08 completion and board status;
   agree the HU-09/10/11 acceptance examples and ownership rules.
2. **Contract first:** align the appointment and professional service request/response schemas,
   the summary reference/event semantics, error responses, and the appointment state machine.
3. **Parallelize behind contracts:** the professional-service provider and appointment-service
   consumer can progress independently against the same OpenAPI fixture. The agent-event
   producer and appointment event consumer can also work against an agreed sample event.
4. **Implement and test HU-09, HU-10, and HU-11:** keep appointment persistence inside
   `appointment-service`; test patient/professional ownership and each allowed status transition.
5. **Integrate at the API boundary:** run provider/consumer contract tests, then end-to-end
   tests through the gateway. Keep HU-17 email/event delivery and HU-14's completion event
   outside this proposed increment.

Two contract questions are release gates rather than assumptions:

- The Week 7 local availability contract is explicitly **planned** and returns an
  `available` boolean for one professional/date; HU-09 rescheduling needs a valid new slot.
  Agree the slot representation and contract before claiming rescheduling is fully testable.
- HU-10 requires authorized access to a `PreConsultationSummary`. The documented event names
  the generated summary, but the reviewed materials do not settle whether the professional
  receives the summary in the event or fetches it through a separately authorized API. Decide
  this without exposing another service's database.

### 6. Contract-first approach

- Use the existing [OpenAPI 3.0.3 appointment-service contract](https://github.com/code-corhuila/telemed-ia-docs/blob/main/07-api/contracts/openapi/appointment-service.yaml)
  as the starting point for create, patient/professional queries, cancel, reschedule, and
  status operations. Its current reschedule shape uses `start`/`end` date-times and reports
  `409` for a time conflict.
- Align the professional lookup with the
  [professional-service OpenAPI contract](https://github.com/code-corhuila/telemed-ia-docs/blob/main/07-api/contracts/openapi/professional-service.yaml).
  Do not assume that a contract file proves deployed endpoints or working inter-service calls.
- The course's [Week 7 planned availability contract](../../07-week/hu-status/appointment-service.openapi.yaml)
  identifies `professionalId` and `date` and currently gives a boolean response. Treat it as
  an existing planning artifact, not a live service contract; extend/clarify it for selectable
  time slots before HU-09 rescheduling is accepted.
- Define status validation against HU-11: a professional can record permitted states such as
  `NO_SHOW`; `COMPLETED` is produced by the `ConsultationCompleted` flow. The existing sample
  OpenAPI status enum includes `COMPLETED`, so reconcile its request semantics with HU-11
  before implementation rather than allowing a manual completion accidentally.
- Specify request/response schemas, ownership/authorization failures, malformed-input
  responses, and conflict responses. The published appointment contract includes `400`,
  `401`, `403`, `404`, and `409` cases; add examples and consumer/provider tests for the chosen
  behavior.
- Preserve the documented explicit `v1` versioning and compatibility rules: compatible
  additions must not break existing consumers; removing/changing required fields or changing
  behavior incompatibly requires a new major version or migration plan. Keep event payloads
  minimal and consumers idempotent.

### 7. Simulations and mocks

**Existing evidence:** the reviewed Week 7 files provide a planned OpenAPI contract and an
`AppointmentCreated` JSON Schema. They are specifications, not evidence of a running
simulator/mock. No existing service simulation is claimed here.

**Proposed simulations:**

| Dependency to simulate | Suggested deterministic response/event | What it unblocks / verifies |
|---|---|---|
| `professional-service` lookup | Return a fixture professional ID, eligibility/specialty, or a documented not-found/unauthorized error. | Appointment validation and contract tests can run before the provider service is available. |
| `agent-service` summary event | Publish a fixture `PreConsultationSummaryGenerated` event tied to a patient/appointment reference; include only fields approved by the event contract. | Appointment association and the HU-10 summary-status path can be developed without the live agent. |
| Appointment events for future HU-17 | Replay valid `AppointmentCreated`, `AppointmentCancelled`, and `AppointmentRescheduled` fixtures; inject duplicate delivery and simulated email failure. | Verify correct notification mapping, idempotency, retries, and that email failure does not roll back an appointment. This simulation is deferred with HU-17. |

### 8. Velocity and capacity

**Historical velocity is not sufficiently documented.** The Week 04 status records **18 SP
planned** for five MVP 1 stories; it does not report completed story points. The Week 06 status
clarifies that its `done` labels described backlog organization, not functional completion.
Week 08 reports HU-005 as `doing` and has no point estimate for it. None of these is a reliable
completed-points-per-sprint velocity.

For this planning exercise only, use a **proposed capacity ceiling of 16 SP**. This is an
assumption, not a velocity calculation or approved team commitment; it is set below the earlier
18-SP *planned* scope to leave room for the documented multi-service contract and integration
uncertainty. Confirm it with the team before commitment.

| Comparison | Story points |
|---|---:|
| All seven Sprint 2 candidate stories (proposed estimates) | 34 |
| Proposed planning capacity (assumption) | 16 |
| Selected HU-09 + HU-10 + HU-11 | 13 |
| Remaining capacity for integration/unknowns | 3 |

The full roadmap candidate set exceeds the assumed capacity by 18 SP. The proposed scope is
13 SP and leaves a 3-SP buffer; this is a capacity-based proposal, not a claim about actual
velocity.

### 9. Realistic proposed MVP 2 scope

**Proposed sprint goal:** Deliver the appointment-management and professional-preparation
core: patients can view and manage their own eligible appointments, while healthcare
professionals can view assigned appointments/pre-consultation information and record only
permitted appointment statuses.

**Include:** HU-09 (5 SP), HU-10 (5 SP), and HU-11 (3 SP), for **13 SP total**.

**Keep outside this proposed increment:** HU-03 password recovery (5 SP), HU-04 patient
profiles (3 SP), HU-12 medical-care recording (8 SP), and HU-17 appointment emails (5 SP).
HU-13–HU-18 work not listed as a Sprint 2 candidate remains in its later documented roadmap
phase. HU-17 is a documented Sprint 2 roadmap candidate, but is deferred here because the
assumed capacity favors the Must Have professional-preparation flow and its async/email
integration adds a separate failure/retry path. HU-12 is deferred until the appointment
schedule and authorization/summary contract are stable.

This boundary is **not approved project scope** and is narrower than the complete documented
Sprint 2 roadmap. The official M2 milestone should not be reported complete unless its full
acceptance scope is delivered or formally re-planned.

### 10. Relationship with the sprint goal

HU-09 delivers patient control over existing appointments; HU-10 gives the healthcare
professional the assigned schedule and pre-consultation context; HU-11 preserves the
appointment lifecycle without allowing manual consultation completion. Together, these
stories advance the roadmap's documented goal of preparing professionals for scheduled
consultations. HU-06/HU-08 remain prerequisites, and their current completion must be verified
before sprint commitment. The selected 13-SP slice fits the explicitly assumed 16-SP
capacity, while the unselected roadmap candidates remain visible rather than being presented
as done.

### 11. Session 2 conclusion

The story map connects TeleMed IA's real user stories to the patient-to-professional care
flow. Planning Poker gives transparent, provisional estimates to the seven documented Sprint
2 candidates. The proposed scope selects HU-09/HU-10/HU-11 at 13 SP against an assumed
16-SP capacity because no reliable historical velocity is recorded. Contract-first sequencing,
provider/event fixtures, and explicit resolution of the availability and summary-access gaps
reduce integration risk without claiming unbuilt mocks or APIs already exist.

### Sources

- [Week 04 status — MVP 1 planned estimates](../../04-week/hu-status/README.md)
- [Week 06 status — backlog organization clarification](../../06-week/hu-status/README.md)
- [Week 08 status and project evidence](README.md)
- [Product backlog](https://github.com/code-corhuila/telemed-ia-docs/blob/main/03-product/product-backlog.md)
- [Product roadmap](https://github.com/code-corhuila/telemed-ia-docs/blob/main/03-product/roadmap.md)
- [Authoritative user stories and acceptance criteria](https://github.com/code-corhuila/telemed-ia-docs/blob/main/04-requirements/user-stories.md)
- [Target service catalog](https://github.com/code-corhuila/telemed-ia-docs/blob/main/09-microservices/service-catalog.md)
- [Service dependency map](https://github.com/code-corhuila/telemed-ia-docs/blob/main/09-microservices/dependency-map.md)
- [Communication patterns](https://github.com/code-corhuila/telemed-ia-docs/blob/main/09-microservices/communication-patterns.md)
- [Domain event catalog](https://github.com/code-corhuila/telemed-ia-docs/blob/main/02-domain/domain-events.md)
- [Week 7 versioning and contract-testing activity](../../07-week/hu-status/Optional%20Activity%20Week%207%20-%20Session%202.md)
