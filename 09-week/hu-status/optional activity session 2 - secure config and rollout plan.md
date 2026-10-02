optional activity session 2

# OPTIONAL ACTIVITY — Week 09 · Session 2

## Objective and scope

Plan secure configuration ownership, feature-flag governance, progressive rollout, and
rollback for a documented MVP 2 capability in the Professional Management context.
This is a planning activity in the Systems Distributed course repository. It does not
change the Professional Management API/DB repositories, implement the selected MVP 2
feature, or claim that the team has approved this plan.

### Evidence labels

- **Documented:** stated in existing Week 08/Week 09 course evidence.
- **Proposed:** a plan for team review; not an existing production practice or approval.
- **Pending:** the repository does not identify the required tool, owner, threshold,
  environment, or operational mechanism.

## Relationship to Session 1

Session 1 created an activity-only `.env.example`, a runnable configuration/flag demo,
and a Gitleaks pre-commit setup. It demonstrated:

- environment configuration and fail-fast validation;
- runtime injection instead of storing real credentials in Git;
- secret scanning before a commit; and
- an OFF-by-default `PROFESSIONAL_SPECIALTY_CATALOG_EXPORT_ENABLED` example flag for a
  proposed specialty-catalog CSV export.

Those examples are not deployed service configuration or a production feature. Session
2 adds proposed owners, rotation/incident handling, a lifecycle policy, and rollout
gates. The separate example flag from Session 1 is not the flag proposed below for the
MVP 2 capability.

## Selected MVP 2 capability

**Feature:** a healthcare professional views their assigned appointment schedule and
the associated pre-consultation status/summary.

**Documented story:** **HU-10 — View Professional Appointment Schedule**. Week 08
lists HU-10 among the selected stories in a *proposed* MVP 2 slice (with HU-09/HU-11);
that scope is not recorded as an approved commitment. This plan does not create or
renumber a user story.

**Objective:** let an authenticated professional view appointments assigned to them and
the approved pre-consultation context needed to prepare for the consultation.

**Why progressive delivery:** the capability joins appointment assignment with
professional authorization and pre-consultation information. A staged release can
limit the initial exposure and reveal access-control, integration, or availability
problems before wider enablement. Because the view may expose sensitive health context,
any suspected cross-professional or unauthorized disclosure is an immediate stop signal.

**Proposed feature flag:** `PROFESSIONAL_APPOINTMENT_SCHEDULE_ENABLED`, default `false`.
This is a design proposal for HU-10, not an existing configuration variable, implemented
flag, or production deployment. The Session 1 flag controls only its separate
demonstration capability.

**Documented dependencies:** Week 08 identifies HU-06 (agent pre-consultation and
structured summary) and HU-08 (schedule appointment) as HU-10 prerequisites. Their
acceptance and delivery status must be confirmed before commitment. The summary delivery
semantics remain unresolved: the documented event does not settle whether summary data
is included in that event or obtained from a separately authorized API. No service may
read another service's database directly.

**Risks to address:** incorrect professional ownership filtering; unauthorized exposure
of summary data; missing, stale, or mismatched appointment/summary association; upstream
service unavailability; and duplicate or incompatible contract assumptions. Actual
service ownership of the complete HU-10 flow must be confirmed; this plan does not assign
it to an undocumented API.

## Secrets plan

No specific external secret manager, production injection platform, named owner, or
rotation interval is identified by the reviewed repository evidence. Select the
provider and operating cadence with the service/platform team before deployment.

Expected path:

```text
Secret Store (provider pending)
        → runtime/deployment injection
        → environment variables
        → Professional Management runtime
```

| Setting or secret type | Evidence and handling | Proposed accountable role | Access and rotation |
|---|---|---|---|
| `DB_PASSWORD` | Listed in Week 6 configuration material as a database credential. Store only in the environment's approved secret store; inject at runtime. Never place a value in `.env.example`, source, image, or Git. | Professional Management service owner is accountable for need/rotation coordination; platform/deployment secret operator manages the selected store/injection. Named individuals and tool are pending. | Runtime workload identity and explicitly authorized operators only. Rotate on exposure, access/ownership change, or the cadence approved for the chosen store; interval is pending. Update the store/injection, verify service connectivity, then revoke the old credential. |
| `JWT_SECRET` | Listed in Week 6 configuration and the Session 1 demo as a signing secret. Protect and inject at runtime; do not log or commit it. | Professional Management service owner coordinates compatibility; platform/deployment secret operator performs the store operation. Exact signing-key consumers and coordinated rotation behavior must be confirmed in the API. | Restrict to the runtime and authorized operators. Rotate on exposure or access change and at the approved cadence. Confirm token/key rollover behavior before rotation; overlap strategy and interval are pending. |
| `DB_URL` and `DB_USERNAME` | Documented configuration values. They may reveal infrastructure details or identify an account even though the URL is not itself a password. Supply per environment; grant the database account least privilege. | Professional Management service owner owns the required configuration; database/platform operator provisions and updates it. | Limit visibility to operators and the runtime that need it. Change endpoints/accounts through an approved environment change; exact access process is pending. |
| Other service/API credentials | No additional Professional Management integration credential is established by the reviewed evidence. Do not add one until a real dependency and contract require it. | The owner of the dependency plus Professional Management service owner, once identified. | Secret-store handling and rotation must be defined before that integration is enabled. |

**Who may access:** proposed least privilege. The application receives only the values
it needs through its runtime identity. Secret-store/deployment administration is limited
to explicitly authorized platform operators; application maintainers should not need to
copy production secret values into local files. The actual identity model, access-review
owner, and break-glass process are pending team decisions.

**Rotation workflow (proposed):**

1. The accountable service owner requests/coordinates a rotation and checks the
   consumer's supported rollover behavior.
2. The authorized secret operator issues or updates the value in the approved store and
   updates runtime injection without putting the value in a PR, ticket, or log.
3. Deploy/restart/reload using the environment's supported mechanism and verify health,
   authentication/database connectivity, and relevant tests without printing the value.
4. Revoke the previous value after successful verification and record the change
   metadata, not the secret.
5. If rotation fails, use the store's controlled recovery procedure; never restore an
   exposed credential.

No calendar interval is prescribed here because the repository does not document one.
The selected secret store's policy and team risk requirements must establish a cadence.

**Exposure response (proposed):** treat a suspected exposure as compromised; notify the
service owner and authorized security/platform contact through the team's approved
incident channel; revoke/rotate the value at the source; check access/audit records;
identify and remove the exposed value from the affected Git history/artifacts where
applicable; assess dependent services; and verify the replacement. Do not paste the
secret into an issue, chat, commit, or incident report. Gitleaks can identify staged
patterns but does not revoke credentials or guarantee removal from prior history.

**Git controls:** Session 1's template contains names/placeholders only, `.gitignore`
ignores local dotenv files, and the Gitleaks pre-commit hook scans staged changes. These
are preventive controls, not a secret store. CI scanning, history scanning and an
incident process are not evidenced here and remain to be selected/confirmed.

## Feature-flag policy

### Naming and behavior

- Proposed format: `PROFESSIONAL_<CAPABILITY>_ENABLED`, uppercase snake case, naming
  the bounded context and user-visible capability rather than an environment or release
  number.
- Existing Session 1 example: `PROFESSIONAL_SPECIALTY_CATALOG_EXPORT_ENABLED`. It is
  activity demonstration code only, not claimed as a deployed flag.
- Proposed HU-10 flag: `PROFESSIONAL_APPOINTMENT_SCHEDULE_ENABLED`. It is a planning
  proposal, not implemented configuration.
- New flags default **OFF** unless a different default is explicitly approved and
  documented. Missing/malformed values must not accidentally enable a capability.
- A flag must guard the capability at the application/API boundary, not replace
  authentication, authorization, or domain invariants.

### Ownership, audit, and removal

| Lifecycle concern | Proposed policy |
|---|---|
| Business owner | The relevant feature/service owner decides intended cohort and readiness. For HU-10, use the **Professional Management owner and the owning appointment/pre-consultation service owner**; exact service ownership and named people are pending. |
| Technical owner | The owning API/service maintainer implements, tests, observes, and removes the guard. Operations/platform role controls runtime targeting only if the deployment supports it. |
| Creation/change audit | Record flag key, requester/actor role, timestamp, reason, code/config reference, environment/cohort, previous and new state, approver, and planned review/removal date. Never record secret values or patient data. Existing audit tooling is not documented; its selection is pending. |
| Default and access | OFF by default. Only authorized release/operations roles may change production targeting after the agreed approval; the actual access mechanism is pending. |
| Removal | Remove after the capability is fully enabled or explicitly abandoned, acceptance/monitoring gates are satisfied, fallback is no longer needed, and the owner approves removal. Remove the flag branches/config/tests and update documentation in one reviewed change. |
| Flag debt | Each temporary flag needs an owner, purpose, creation record, and review/removal target. Review outstanding flags at release checkpoints; do not turn release toggles into permanent business rules or accumulate flags without owners. |

## Canary plan for HU-10

This is a proposed sequence, not evidence of an existing canary system, telemetry
dashboard, runtime-refresh mechanism, or production cohorting service.

### Preconditions

Before starting a production rollout:

1. Confirm HU-06/HU-08 dependencies and their acceptance/status.
2. Resolve the summary-access contract and ownership/authorization boundaries.
3. Verify automated authorization tests prove a professional can only view assigned
   appointments and permitted summary data.
4. Implement `PROFESSIONAL_APPOINTMENT_SCHEDULE_ENABLED` OFF by default and prove OFF
   retains the pre-feature safe behavior.
5. Agree baseline, SLO/thresholds, measurement window, alerting/monitoring owner, and
   cohort-selection mechanism. None is established in this repository.
6. Verify rollback configuration can be applied and observed for the target environment.

### Rollout stages

| Stage | Action and population | Advance only when |
|---|---|---|
| Deploy, flag OFF | Deploy the compatible code/configuration with the HU-10 flag OFF for everyone. Run deployment health checks and confirm the new capability is unavailable while existing safe behavior remains. | Deployment health and existing regression/authorization tests pass. No production canary begins if rollback control or required monitoring is unavailable. |
| Canary 5% | Turn ON for a stable 5% cohort of eligible, authenticated professional users who have assigned appointments, and only for the approved environment. Do not target patients or expose data to professionals without assignment. The cohort implementation (allow-list, stable hash, or other supported mechanism) is pending; percentage must be calculated over eligible professional users, not all requests, once that mechanism is chosen. | Observe the agreed window; compare availability/error/latency to the approved baseline and inspect authorization/privacy signals. Advance only if all agreed gates pass and there is no unauthorized disclosure or cross-owner data result. |
| 50% | Expand to 50% of the same eligible population through the approved flag/configuration mechanism. | Repeat the same observations and gates for the agreed window; no unresolved incident/regression; service and dependency owners approve the next step. |
| 100% | Enable for all eligible authorized professional users. Keep rollback available until the owner confirms the post-release observation criteria are met. | Meet the release acceptance and observation gates; then schedule flag removal under the policy above. |

### Signals and gates

Observe at each stage:

- request success/error rate and service availability;
- latency (including a team-selected percentile/threshold);
- authorization denials and any mismatched professional/appointment ownership;
- missing, stale, or incorrectly associated pre-consultation summaries;
- upstream dependency failures and relevant resource/exception signals;
- privacy/security incidents and audit evidence for access.

The repository does not document current dashboards, baseline values, SLOs, numeric
error/latency thresholds, alert destinations, observation duration, cohort tooling, or
who approves each transition. Mark these **pending** and agree them before rollout;
do not infer monitoring capability. Privacy or cross-owner disclosure is a zero-tolerance
stop/rollback signal. Other numeric limits must be supplied by the service/operations
owners before the rollout is authorized.

**Stop conditions:** any unauthorized/cross-professional data exposure; failed
authorization invariant; unexpected disclosure of a summary; a breach of the agreed
availability/error/latency gate; or a dependency failure that makes the returned
schedule/context misleading or unsafe. Pause immediately, prevent cohort expansion, and
invoke rollback for a security/privacy event or material user impact.

## Rollback plan

**Trigger:** any stop condition above, failed release gate, or explicit decision by the
authorized service/release owner to stop the rollout.

**Proposed responder:** on-call/release operator disables the HU-10 flag; the owning
service owner coordinates validation and follow-up. Actual roster, authority, and
incident channel are pending.

**Action and verification:**

1. Set `PROFESSIONAL_APPOINTMENT_SCHEDULE_ENABLED=false` for every cohort/environment
   through the supported runtime configuration mechanism. If runtime refresh is not
   supported, perform the approved restart/redeployment; do not claim instant toggling
   until tested in the target platform.
2. Stop cohort expansion and confirm the effective flag state is OFF using the
   environment's configuration/health evidence without logging secret values.
3. Verify a request to the new HU-10 capability is disabled/denied according to the
   API's agreed contract, and existing pre-feature behavior remains available.
4. Verify no schedule/summary information is returned through the disabled path; check
   authorization and service error/availability signals for recovery.
5. Preserve required incident evidence without patient data or secrets, notify owners
   through the approved channel, and investigate the cause.
6. Correct the defect and re-run tests/contract/security checks before requesting a new
   canary. Re-enable only through the approved release process.

Expected safety result:

```text
flag OFF → HU-10 capability disabled → previous safe behavior restored
```

This rollback is a plan, not a production-tested operation. The disabled response and
runtime propagation behavior must be specified and verified in the owning API before
release.

## Hardening stories and testable acceptance criteria

These are activity planning slices, **not newly numbered HUs** or approved backlog
items. Owners are roles, not named people.

### Story C1 — Validate required runtime configuration

**Description:** Bind and validate only the configuration required by the owning
Professional Management service at startup.

**Objective:** fail fast before serving traffic and identify the missing/invalid key
without exposing its value.

**Suggested owner:** Professional Management API/service owner.

**Acceptance criteria:**

- **Given** all documented required settings are valid, **when** the service starts,
  **then** startup completes and its readiness check succeeds.
- **Given** each required setting is tested absent or blank in turn, **when** startup
  runs, **then** it exits/fails readiness before accepting requests and identifies that
  setting by name.
- **Given** a malformed required setting, **when** startup validation runs, **then** it
  fails before readiness and its output contains no supplied secret value.
- **Given** a scan of captured startup logs from those cases, **when** checked for the
  fake secret fixtures used by the test, **then** none of the fixture values appears.

### Story C2 — Inject and rotate secrets outside Git

**Description:** Source real credentials from the approved environment secret store
through runtime injection.

**Objective:** keep credential values out of source, configuration templates, images,
Git, and logs.

**Suggested owner:** service owner with the platform/deployment secret operator.

**Acceptance criteria:**

- **Given** a deployment environment, **when** the service starts, **then** required
  secret values are supplied by the approved runtime injection path and no committed
  file contains a real value.
- **Given** an authorized rotation, **when** the new value is injected, **then** service
  connectivity/authentication is verified without printing either value and the old
  value is revoked after successful verification.
- **Given** a local checkout, **when** `.env`/dotenv variants are checked, **then**
  Git ignores them while the placeholder `.env.example` remains trackable.
- **Given** a suspected exposure, **when** the incident procedure is invoked, **then**
  the affected value is revoked/rotated and the recorded incident excludes the value.

### Story C3 — Block detected secrets before commit

**Description:** Run the repository's Gitleaks pre-commit hook against staged changes.

**Objective:** prevent an obvious credential pattern from entering a commit.

**Suggested owner:** repository maintainer; hook execution belongs to each contributor.

**Acceptance criteria:**

- **Given** the documented hook setup, **when** pre-commit runs on ordinary staged
  changes, **then** Gitleaks executes and returns its scan result.
- **Given** a known-fake token pattern staged in a disposable test fixture, **when** the
  hook runs, **then** it returns non-zero and Git refuses the commit.
- **Given** Gitleaks is missing or cannot run, **when** the configured hook runs,
  **then** the failure is visible and the commit is not silently treated as scanned.
- **Given** the staged diff is clean, **when** the hook runs, **then** it passes.

### Story C4 — Guard HU-10 with an OFF-by-default flag

**Description:** Add the proposed schedule-view flag at the owning API boundary.

**Objective:** deploy code safely while HU-10 remains disabled and enable it only for
an approved cohort.

**Suggested owner:** owning service/API owner; exact service boundary pending.

**Acceptance criteria:**

- **Given** the flag is absent or false, **when** a user requests the new HU-10
  capability, **then** no new schedule/summary capability is exposed and prior safe
  behavior is preserved.
- **Given** the flag is true and the authenticated professional is authorized for the
  assigned appointment, **when** they request HU-10, **then** the contract-approved
  schedule/context response is returned.
- **Given** the flag is true and the professional is not assigned/authorized, **when**
  they request another professional's data, **then** access is denied and no protected
  schedule/summary data is returned.
- **Given** the flag has a malformed value, **when** configuration is validated,
  **then** startup/config reload fails closed rather than enabling the feature.

### Story C5 — Control HU-10 canary exposure

**Description:** Enable HU-10 for staged cohorts using a supported and auditable
runtime mechanism.

**Objective:** expand exposure only after agreed operational and privacy gates pass.

**Suggested owner:** feature owner and release/operations owner.

**Acceptance criteria:**

- **Given** the flag is OFF after deployment, **when** canary prerequisites are
  incomplete, **then** the feature remains unavailable to all users.
- **Given** prerequisites, eligible-user definition, metrics, thresholds, and observation
  window have been approved, **when** a 5% canary is configured, **then** exactly the
  configured cohort-selection rule is applied to eligible professional users and the
  effective cohort can be verified.
- **Given** a stage's observation window completes, **when** any agreed gate fails or a
  privacy/authorization stop signal occurs, **then** rollout does not advance.
- **Given** all approved gates pass at 5% and subsequently at 50%, **when** the owner
  authorizes the next stage, **then** exposure moves to 50% and then 100% respectively,
  with each change recorded.
- **Given** no approved baseline/threshold or monitoring evidence exists, **when** a
  rollout is requested, **then** production expansion is blocked pending those decisions.

### Story C6 — Restore safe behavior by disabling the flag

**Description:** Define and verify an operational OFF switch for the HU-10 capability.

**Objective:** stop exposure without waiting for a code rollback when the target runtime
supports live configuration changes.

**Suggested owner:** release/on-call operator, coordinated with the service owner.

**Acceptance criteria:**

- **Given** an approved rollback trigger, **when** the flag is set OFF using the
  environment's supported mechanism, **then** its effective state becomes OFF within
  the agreed propagation time (time limit pending runtime selection).
- **Given** the effective state is OFF, **when** a user calls the new capability,
  **then** the capability is unavailable and the prior safe behavior is restored.
- **Given** rollback is complete, **when** health, access-control, and feature-state
  checks are performed, **then** no HU-10 summary data is served through the disabled
  path and the service meets its agreed recovery gates.
- **Given** an incident is unresolved, **when** re-enablement is requested, **then**
  the feature remains OFF until corrective checks and the release approval are recorded.

## Decisions and information pending

The following must be confirmed before this plan becomes an operational release plan:

- secret-store product, runtime injection mechanism, named role access list, rotation
  cadence, emergency access, and incident channel;
- current status/acceptance of HU-06 and HU-08 and formal approval of the proposed
  MVP 2 scope;
- service ownership and final HU-10 API/event contract for summary access;
- production flag-management mechanism, cohort allocation method, runtime propagation
  time, approval/audit tooling, and accountable named roles;
- baseline/SLO values, numeric thresholds, observation windows, dashboards/alerts, and
  transition approvers;
- exact disabled response and regression behavior for the actual service.

No current monitoring dashboard, production canary, production secret manager, named
operator, test result, production rollback, HU number beyond documented HU-10, PR, or
commit is asserted by this activity.

## Relationship to MVP 2

This plan creates a proposed path from **MVP 2 implementation → secure configuration →
OFF-by-default flag → controlled canary → monitoring gates → rollback**. It does not
implement HU-10 or the broader MVP 2 slice. The Week 08 scope and dependencies remain
proposals until the team verifies prerequisites and approves a commitment.

## Sources reviewed

- [Week 08 · Session 2 MVP 2 planning activity](../../08-week/hu-status/Optional%20Activity%20Week%208%20-%20Session%202.md)
- [Week 06 environment configuration matrix](../../06-week/hu-status/Environment%20Configuration%20Matrix.md)
- [Week 09 · Session 1 activity](optional%20activity%20session%201%20-%20secure%20configuration.md)
- [Week 09 HU Status](README.md)

## Validation evidence

This document was checked against the Week 08 MVP 2 activity, Week 06 environment
configuration material, the Week 09 Session 1 activity document and HU Status. No
Session 2 application/test results are claimed because this deliverable is a plan.
