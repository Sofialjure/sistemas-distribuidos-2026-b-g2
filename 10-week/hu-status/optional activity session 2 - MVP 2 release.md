# OPTIONAL ACTIVITY — Week 10 · Session 2

## Objective

Week 10 is the closing and preparation stage for MVP 2. The team is expected to complete
remaining implementation, finish portal and Front/shell work, validate integration,
align documentation, consolidate release evidence, prepare/perform release tagging
according to the course process, and complete each member's HU-status evidence. This
activity records the release checklist and evidence status; it does not claim that all
release work is already complete.

Week 11 is for uploading/registering the release evidence in Moodle, presenting MVP 2,
demonstrating the integrated system and its failure/compensation path, and completing
the final release presentation/sustentation. Week 11 is not the start of technical
implementation or release preparation.

The expected MVP 2 tag is **`v2.0.0`**. Release status is evidence-based. The release
trail is `develop` → `qa` → `main` → `v2.0.0`; promotion between permanent branches uses
`git cherry-pick -x` to retain source-commit traceability. No promotion or tag result is
claimed here without verifiable evidence.

## Project Context and Evidence Boundary

Course materials describe eight domains and identify the core distributed flow as
Intelligent Agent, Appointment Scheduling, Medical Consultation, and Document
Generation. The Week 01 architecture document describes the initial MVP as a modular
monolith, while the Week 07 interaction table calls service interactions planned
design. These artifacts are domain and design context, not proof of a currently
integrated MVP 2 deployment. The exact production end-to-end sequence must be verified
against the current service contracts and implementation.

Known repositories:

- [Appointment Scheduling API](https://github.com/code-corhuila/telemed-ia-appointment-scheduling-api)
- [Medical Consultation API](https://github.com/code-corhuila/telemed-ia-medical-consultation-api)
- [Document Generation API](https://github.com/code-corhuila/telemed-ia-document-generation-api)
- [Document Generation Portal](https://github.com/code-corhuila/telemed-ia-document-generation-portal)
- [Front](https://github.com/code-corhuila/telemed-ia-front)
- [PostgreSQL infrastructure](https://github.com/code-corhuila/telemed-ia-infra-postgres)

Repository links identify project locations. Completion and release status are stated
only where evidence is available below.

## Release Status Checklist

| Release requirement | Status | Evidence / next evidence to record |
|---|---|---|
| Acceptance criteria for committed stories | NOT VERIFIED | Add each committed story, acceptance result, and implementation/verification link. |
| Unit tests | IN PROGRESS | Appointment Scheduling and Medical Consultation commit titles include unit-test work. Current release test execution/results and coverage: Not verified in this activity. |
| Integration tests | NOT VERIFIED | Add current integration test command and actual result from participating services. |
| Contract tests | NOT VERIFIED | Week 07 includes an Appointment Scheduling OpenAPI artifact and contract-planning material; passing MVP 2 contract test results were not available. |
| Whole-system startup (`docker compose up`) | NOT VERIFIED | Add environment, startup result, participating services, and health-check evidence. |
| Cross-service flow | NOT VERIFIED | Add verified gateway journey, contracts/events, participating services, and persisted state evidence. |
| Failure and compensation | IN PROGRESS | Session 1 educational simulation is executed; actual integrated MVP 2 failure/compensation verification remains to be recorded. |
| Outbox | IN PROGRESS | Session 1 demonstrates an educational outbox and retry; production publisher/event evidence remains to be verified. |
| Idempotent consumers | IN PROGRESS | Session 1 demonstrates persistent duplicate handling; production consumer evidence remains to be verified. |
| Environment-specific configuration | NOT VERIFIED | Add evidence for each release environment's configuration. Week 09 contains planning and a demonstration template only. |
| Secrets protected in Git and images | NOT VERIFIED | Add actual secret-scan and image-inspection evidence; no results are claimed here. |
| CHANGELOG updated | IN PROGRESS | Week 10 release documentation is being prepared; add the actual release CHANGELOG link after update. |
| Relevant ADRs updated | IN PROGRESS | Add the actual ADR links after confirming and recording release-relevant decisions. |
| Promotion `develop` → `qa` | PENDING | Add real `cherry-pick -x` promotion evidence after completion. |
| Promotion `qa` → `main` | PENDING | Add real `cherry-pick -x` promotion evidence after completion. |
| Expected tag `v2.0.0` | PENDING | No matching tag was found in this course repository. The release target repository/tag could not be independently checked. v2.0.0 — pending final tag creation/verification during the Week 10 release closure. |
| HU-status evidence | IN PROGRESS | Week 10 requires each member's evidence to be ready before release presentation; add each member's links/checklist. |
| Moodle submission/registration | PLANNED FOR WEEK 11 | Record Moodle submission/registration evidence in Week 11. |
| MVP 2 presentation and final demonstration | PLANNED FOR WEEK 11 | Record presentation and integrated demo evidence in Week 11. |

Statuses describe evidence available for this activity, not an assertion that a
component or release requirement passed without proof. The test-commit titles show
implementation work; they do not establish a current passing test run. Coverage is
**Not verified in this activity.**

### Acceptance Criteria and Automated Tests

During Week 10, list the stories actually committed to MVP 2 and verify their acceptance
criteria against implementation evidence. Record unit, integration, and contract test
commands and actual outcomes from the relevant repositories. Do not infer passing tests
from a commit title or report coverage unless measured results are available.

### Whole-System Startup and Cross-Service Flow

Record the actual `docker compose up` invocation, environment, participating services,
and health checks. Then drive the verified MVP 2 journey through the gateway and show
the data persisted by each participating service.

Course documents describe a patient pre-consultation with the Intelligent Agent,
appointment scheduling, Medical Consultation, and a possible Document Generation
request after a consultation. The Week 07 service interactions are explicitly planned
design, so this description is context for verification rather than an assertion that
this precise production sequence is implemented. Record the actual endpoints/events,
contracts, and service/database ownership used in the release demo.

### Failure, Compensation, Outbox, and Idempotency

The [Week 10 Session 1 activity](optional%20activity%20session%201/README.md) provides
executable educational evidence of failure injection, a Saga, compensation, outbox,
retry, idempotent consumer behavior, and final consistency checks. It uses SQLite and
an in-process simulated broker. It is not production RabbitMQ integration and does not
prove that the production services are connected through this Saga or outbox.

**Final MVP 2 presentation evidence must demonstrate the actual integrated system when
the release is presented.** Record the real injected failure, its detection, the
implemented compensation, duplicate handling if applicable, and the resulting
cross-service consistency. Keep that evidence distinct from Session 1's simulation.

### Configuration, Secrets, CHANGELOG, and ADRs

For each release environment, record the configuration used and verify secrets are
provided outside Git and are not baked into images. Week 09 includes configuration and
secrets planning, but this activity does not have release-specific environment, scan,
or image-inspection results. Link the actual CHANGELOG and relevant ADR updates when
they are completed during Week 10.

## Promotion Trail

```text
develop
   |
   | git cherry-pick -x <verified-commit>
   v
qa
   |
   | git cherry-pick -x <verified-commit>
   v
main
   |
   v
v2.0.0
```

Week 10 is where the team prepares and completes this release process, subject to the
project's validation and evidence requirements. `git cherry-pick -x` records the source
commit in the promoted commit message and preserves traceability. The permanent branch
flow is performed through cherry-picks, not direct merges. No source SHAs, promotion
results, or tag creation are asserted here without direct evidence.

Promotion evidence: **PENDING — add real branch/commit evidence after execution.**

Release tag: **v2.0.0 — pending final tag creation/verification during the Week 10
release closure.** No matching tag was found in this course repository, and the release
target repository/tag could not be independently checked. Do not mark it DONE until its
existence and target are verified.

## Microservice Implementation Evidence

The exact commit titles below were supplied as repository-history evidence. They are
listed without fabricated hashes, direct commit links, or PR numbers because those
could not be independently verified from the local course repository or accessible
repository pages. The titles support implementation foundations; they do not by
themselves establish that MVP 2 is integrated or released.

### Appointment Scheduling API

Repository: [telemed-ia-appointment-scheduling-api](https://github.com/code-corhuila/telemed-ia-appointment-scheduling-api)

The supplied repository history identifies these merged/verified commits dated October
4, 2026, covering the domain model, state machine, domain events, use cases, HTTP and
PostgreSQL adapters, runtime composition, idempotency-related HTTP concerns, and CI:

- `feat(api): bootstrap FastAPI application with health endpoint`
- `feat(api): add appointment domain model with state machine and unit tests`
- `feat(api): add application ports, DTOs and domain events`
- `feat(api): add appointment use cases with in-memory fake tests`
- `feat(api): add HTTP adapter with JWT, envelope, correlation and idempotency`
- `feat(api): add postgres adapter and runtime composition root`
- `chore(api): add ci workflow, pull request template and readme`

### Medical Consultation API

Repository: [telemed-ia-medical-consultation-api](https://github.com/code-corhuila/telemed-ia-medical-consultation-api)

The supplied repository history identifies these commits covering service bootstrap,
the consultation domain model, typed errors, unit-test implementation, application
ports, and DTOs. The supplied context reports corresponding merged pull requests, but
their IDs and links were not independently verified:

- `feat(api): bootstrap go service with health endpoint and timeouts`
- `feat(api): add medical-consultation domain model with typed errors and unit tests`
- `feat(api): add application ports and DTOs for the consultation flow`

These repositories provide real microservice implementation evidence and domain
references. They do not by themselves prove that production services are already
connected through the educational activity's Saga, Outbox, or simulated broker.

## MVP 2 Completion Evidence

Week 10 is the completion and release-preparation week. The project timeline supplied
for this activity says portal, Front/shell, APIs, remaining implementation,
documentation, tests, integration, release preparation, and HU-status evidence are
being finished. The status below reflects that reported work in progress; it does not
claim component completion. Add verified commit, PR, test, and demo evidence as each
item closes.

| Component / evidence area | Status | Repository / evidence |
|---|---|---|
| Document Generation Portal | IN PROGRESS | [Portal repository](https://github.com/code-corhuila/telemed-ia-document-generation-portal); completion evidence TO BE ADDED. |
| Front shell | IN PROGRESS | [Front repository](https://github.com/code-corhuila/telemed-ia-front); completion evidence TO BE ADDED. |
| Document Generation API | IN PROGRESS | [API repository](https://github.com/code-corhuila/telemed-ia-document-generation-api); completion evidence TO BE ADDED. |
| Appointment Scheduling API | IN PROGRESS | Repository-history commit titles are listed above; MVP 2 acceptance and integrated release evidence TO BE ADDED. |
| Medical Consultation API | IN PROGRESS | Repository-history commit titles are listed above; MVP 2 acceptance and integrated release evidence TO BE ADDED. |
| Other participating core services | IN PROGRESS | Identify actual participating services and add their repository/evidence links; TO BE ADDED. |
| Infrastructure | IN PROGRESS | [PostgreSQL infrastructure repository](https://github.com/code-corhuila/telemed-ia-infra-postgres); release environment/startup evidence TO BE ADDED. |
| Release documentation | IN PROGRESS | Add completed CHANGELOG, ADR, and release evidence links; TO BE ADDED. |

## Week 11 — Release Submission and Presentation

**Week 10 — technical completion and release closure:** finish remaining implementation,
portals and shell, validate tests and integration, align documentation, complete
environment/release checks, consolidate each member's HU-status evidence, and prepare
or perform final tagging under the course process.

**Week 11 — academic submission and presentation:** upload/register the release evidence
in Moodle, present MVP 2, demonstrate the integrated system, demonstrate its
failure/compensation path, and present the final release evidence. These are planned
Week 11 activities; their results should be recorded after they occur.

## Retrospective → Corte 3

### What was completed or evidenced in Week 10

- The supplied Appointment Scheduling API history records merged/verified implementation
  commits dated October 4, 2026, across domain, application, HTTP, PostgreSQL, runtime,
  and CI foundations.
- The supplied Medical Consultation API history records service bootstrap, domain,
  typed errors, unit-test implementation, ports, and DTO work, and reports corresponding
  merged pull requests.
- The Session 1 educational demonstration has execution evidence for its simulated
  failure, retry, compensation, idempotency, and consistency scenarios.
- Week 10 release preparation and HU-status completion are the current closure goals;
  remaining release checklist evidence is tracked above rather than reported complete.

### Integration challenges and risks

- Week 09 HU-status records unresolved ownership and implementation boundaries for some
  cross-domain flows and calls for continued alignment of service, database, and API
  documentation.
- Week 09 identifies production secret management, rotation, feature-flag runtime,
  canary tooling, monitoring thresholds, and rollback propagation as pending decisions.
- The Week 07 interaction document describes planned service interactions, while Week
  01 describes the initial MVP as a modular monolith. Confirm current service contracts,
  portal/Front integration, and deployment composition rather than treating those older
  designs as current runtime evidence.
- A passing educational failure simulation does not establish production distributed
  consistency. The integrated failure and compensation path still needs actual MVP 2
  validation and must be presented in Week 11.

These are documented dependencies and verification risks, not claims that a production
incident occurred.

### Remaining work for Week 11 and Corte 3 preparation

Week 11 handoff: register the final release/tag evidence in Moodle, present the actual
integrated MVP 2 system, and show the verified failure/compensation and consistency
path. Add dates and links after submission and presentation.

Corte 3 preparation should carry forward the course's stated focus on observability,
deployment, security, CI/CD, and final release. Use verified MVP 2 integration and
retrospective findings to prioritize that operational work; do not convert unverified
assumptions into new product requirements.

## HU-status Evidence

Each team member should have their HU-status evidence complete and ready before the
release presentation. Add an actual link for each item when available; keep **TO BE
ADDED** for evidence that does not yet exist or has not been linked.

- [ ] User story and acceptance status — TO BE ADDED where missing
- [ ] Individual contribution — TO BE ADDED where missing
- [ ] PR links — TO BE ADDED where missing
- [ ] Commit links — TO BE ADDED where missing
- [ ] Test results — TO BE ADDED where missing
- [ ] Screenshots, if applicable — TO BE ADDED where missing
- [ ] Repository links — TO BE ADDED where missing
- [ ] Release/tag evidence — TO BE ADDED after verification
- [ ] Retrospective and Corte 3 backlog — TO BE ADDED where missing

Each member should include their own links and evidence; no team-member PRs, commits,
or release results are invented in this document.

## Evidence References

- [Week 10 HU-status page](README.md)
- [Week 10 Session 1 activity](optional%20activity%20session%201/README.md)
- [Session 1 execution and evidence matrix](optional%20activity%20session%201/evidence.md)
- [Week 07 planned service interactions](../../07-week/hu-status/Optional%20Activity%20Week%207%20-%20Session%201.md)
- [Week 07 Appointment Scheduling OpenAPI artifact](../../07-week/hu-status/appointment-service.openapi.yaml)
- [Week 01 architectural context](../../01-week/hu-status/Optional%20Activity%20Week%201%20-%20Session%202.md)
- [Week 09 HU-status and documented risks](../../09-week/hu-status/README.md)

## Conclusion

Week 10 is the time to complete, validate, prepare, and tag MVP 2; Week 11 is the time
to register evidence in Moodle and present the release. Real Appointment Scheduling
and Medical Consultation implementation commit titles provide evidence of service
foundations. Session 1 provides executed educational evidence for saga/outbox/failure
concepts. The current integrated startup, acceptance results, test runs, cross-service
flow, production failure/compensation, environment/security checks, completed
CHANGELOG/ADRs, promotion trail, and verified `v2.0.0` tag still require their own
evidence. Moodle submission and presentation are planned for Week 11.
