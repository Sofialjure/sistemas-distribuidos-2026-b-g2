<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.
     Your weekly grade is read AUTOMATICALLY from this file:
       15-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 15

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->
- FULL_NAME: María Sofía Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Ship MVP 3 of Professional Management and Document Generation: support the onboarding saga, bring the shared documentation in line with the platform as it runs, prove the whole platform end to end from `develop`, open the `v3.0.0` releases to `main`, and test both services at scale (Testcontainers, contract, money-path E2E, load to the SLO, chaos, rollback, security).
<!-- CONFIG-END -->

## 1. User stories worked this week
| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| HU-05 | User and Healthcare Professional Management (professional profiles, onboarding saga) | done | Internal profile creation for the saga [professional-management-api #52](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/52) and its contract [docs #177](https://github.com/code-corhuila/telemed-ia-docs/pull/177); promotion [#53](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/53); releases to `main` [db #37](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/37), [api #56](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/56), [portal #20](https://github.com/code-corhuila/telemed-ia-professional-management-portal/pull/20) |
| HU-16 | Download Consultation Summary as PDF | done | Releases to `main` [db #15](https://github.com/code-corhuila/telemed-ia-document-generation-db/pull/15), [api #63](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/63), [portal #20](https://github.com/code-corhuila/telemed-ia-document-generation-portal/pull/20); money path 2, chaos and load evidence in [Session 1](Optional%20Activity%20Week%2015%20-%20Session%201.md) |

## 2. My individual contribution
- Individual work:
  - **Onboarding saga, my side** (professional-management-api #52, docs #177, approved by Juliana): `POST /internal/professionals` creates the profile for `telemed-ia-workflow` with the same idempotency rules as the admin registration (`201`/`200`/`409`/`422`), only for a `SERVICE` token of an allowed client, and the status `PATCH` accepts that token only to deactivate (the compensation); 212 tests, 0 skipped. Promoted to `qa` (#53).
  - **Shared documentation brought in line with the running platform** (docs #178 to #183, one commit per change, approved by Juliana):
    - **governance** (#179): git conventions aligned with the branching policy, the Team Review Rule (one teammate approval on `develop`/`qa`, the professor on `main`), the release flow, the Definition of Done, `CONTRIBUTING.md` and the onboarding guide; closes docs #29;
    - **architecture decisions** (#180): ADR-025 (languages per service), ADR-026 (database engine and migration tool per domain), ADR-027 (Angular 21 with Native Federation and the React portal), ADR-028 (saga orchestration without an engine, superseding ADR-017, for Juliana to complete), ADR-022 completed, ADR-018 accepted;
    - **the platform as it runs** (#181): deployment, cross-cutting concerns, storage, the service catalog with the worker and the workflow, project control, runbooks and a README with the 31 repositories;
    - **worker and workflow** (#182): the worker as built and the new `11-workflow/` folder;
    - **quality and operations** (#183): HU-13 out of scope (referrals stay as free text), the testing strategy, CI/CD, code review, backup and recovery;
    - **local setup** (#178): the public-key one-liner and four wrapped commands fixed.
  - **Whole platform verified from scratch** on 2026-11-12: the 30 code repositories at `develop`, rebuilt in an isolated network; every migration applied from an empty database; onboarding saga, registration, `/me`, names, booking, consultation, automatic post-summary, worker, PDF with the real names, notification and download — all through the gateway. The gaps found in teammates' repositories were sent to their owners.
  - **MVP 3 release opened** (norm 11): six `release/3.0.0` PRs to `main` with `cherry-pick -x` (two trace lines per commit), trees identical to `qa`, scope, deployment and rollback plans; the database rollback plans corrected after rehearsing them (Session 2, section 3).
  - **Testing at scale and operability** (optional activities below): Testcontainers 14 tests, contract 38 + 28 and a drift job, two money paths 15/15 each, load to the SLO with the knee found, three chaos experiments 26/26, rollback rehearsal, security probes and a secrets scan of 1,745 commits, and a demo under load and failure.
- Team work this week:
  - **Juliana (@JulianaFerro1428):**
    - the whole **onboarding saga service** `telemed-ia-workflow` — the orchestrator, its PostgreSQL saga store, the recovery sweep of interrupted sagas and its promotion to `qa` (workflow #1 to #34) — and the worker's promotion and broker defaults (worker #14 to #17);
    - on my repositories: the professional's own profile at `/me` (professional-management-api #54, portal #18) and the patient PDF with names and the reason for the visit (document-generation-api #59, #60), with their identity and agent sides (identity-and-access-api #158 to #161, intelligent-agent-api #59);
    - the automatic post-summary and `ConsultationCompleted` (medical-consultation-api #27 to #32) and the appointment that completes with it (appointment-scheduling-api #30 to #36), plus shell and appointment-portal fixes;
    - the remaining shared documentation: user and administrator manuals, wireframes, the real design system, operations, project control and the test state (docs #188, #190 to #217);
    - she reviewed and approved my PRs (docs #177 to #183, professional-management-api #52, #53).
  - **José Miguel (@BondrewdXD):** the appointment outbox poller that survives a broker outage (appointment-scheduling-api #26, #27), the missing CI of appointments (#28, #29), Go 1.25 in the consultation CI (medical-consultation-api #25, #26) and the traceability of Patient, Appointment and Consultation (docs #189).

### Week 15 - What we covered and what I learned

![Image Week 15 - Session 01 - Testing at Scale - Contract, E2E, Load & Chaos](Image%20Week%2015%20-%20Session%2001%20-%20Testing%20at%20Scale%20-%20Contract%2C%20E2E%2C%20Load%20%26%20Chaos.png)

**Session 1 — Testing at scale: contract, E2E, load and chaos.** We adapted the testing pyramid to distributed systems: many fast unit tests, integration tests with the real dependencies started by Testcontainers and cleaned up automatically, contract tests to protect the boundaries between producer and consumer, a few slow end-to-end tests only for the money paths, and on top load and chaos tests to prove behavior under stress and failure. For load we saw tools such as k6, Gatling and JMeter, measuring latency, throughput and errors against the SLO to find the knee; for chaos, injecting a controlled failure (kill a service, add latency, drop messages) and verifying that the system degrades gracefully. The real-life case was "all green, dead on launch": every unit test passes and checkout collapses at 200 req/s.

What I learned: passing unit tests is table stakes. Testing my services under failure found things no suite had: with identity down the professional list degrades correctly but each read waits 1.5 s, so the fallback alone breaks the SLO without a circuit breaker; a "roll back everything" that passes in CI fails in the shared instance; and a load test has to measure from the scheduled time, or a slow service hides its queue.

![Image Week 15 - Session 02 - Release - Shipping MVP 3 (Production-Grade)](Image%20Week%2015%20-%20Session%2002%20-%20Release%20-%20Shipping%20MVP%203%20%28Production-Grade%29.png)

**Session 2 — Release: shipping MVP 3 (production-grade).** MVP 1 runs, MVP 2 is integrated, MVP 3 operates: observable, secure, resilient and deployable with zero downtime. We saw how to promote `develop → qa → main` through the gated pipeline and tag `v3.0.0`, the operability checklist (functional and pipeline, deployment with a rehearsed rollback, observability, security, resilience, release notes, ADRs and runbooks), how to demo the system under stress and failure, the retrospective toward the final presentation, and how MVP 3 is evaluated in the third corte. The common mistakes: demoing features but not operability, no rehearsed rollback, resilience assumed but never tested, a release not tagged.

What I learned: the final release is judged on operability, not on features. Rehearsing the rollback plan I had written changed it: on a fresh database the count rolled back the wrong changesets, and once Professional Management 3.0.0 creates a professional its schema can no longer go back — so the plan now says when to roll back and when to fix forward.

### Week 15 - Session 1 - Optional Activity

The test suite of both services completed and run against the whole platform:

- **Testcontainers**: the two `-db` repositories against `postgres:16-alpine`, bootstrapped like the shared instance, with their real Liquibase changelogs — 11 tests (plus 3 rollback tests in session 2), 0 failures;
- **contract tests in CI**: 38 and 28 tests validate every response against the OpenAPI; a new job fails when a contract copy drifts from `telemed-ia-docs` — it found a real drift in `_shared.yaml` (other services' schemas), and both suites still pass against the current contract;
- **money paths**: onboarding through the saga, and consultation → PDF → download across eight services and the object storage, 15/15 each;
- **load to the SLO** (p95 < 500 ms, ≥ 99.5 %): the professional list meets it up to 350 rps and its knee is 350–400 rps; the document list meets it up to 500 rps;
- **chaos**: identity down (graceful, but slow: finding), document API down mid-journey (DLQ and replay, exactly one PDF), broker down (outbox, relays reconnect) — 26/26.

See: [Week 15 - Session 1 - Optional Activity](Optional%20Activity%20Week%2015%20-%20Session%201.md)

### Week 15 - Session 2 - Optional Activity

MVP 3 release and operability checklist:

- `develop → qa` done in my six repositories; six `release/3.0.0` PRs to `main` open with their trail, waiting for the professor's approval to merge and tag `v3.0.0`;
- checklist item by item, with evidence and what is still partial (CI blocked by billing, the dependency scan, the release not yet merged);
- rollback rehearsed on the real upgrade path `v2.0.0 → 3.0.0 → v2.0.0 → 3.0.0`, which corrected the rollback plans of the two database PRs;
- security: 17 of 20 authorization probes as expected, the other 3 a known pattern; 0 leaks in 1,745 commits;
- demo under load and failure at the same time: one service down did not leak into the other, and no PDF was lost.

See: [Week 15 - Session 2 - Optional Activity](Optional%20Activity%20Week%2015%20-%20Session%202.md)

## 3. Blockers and risks
- The merge of the release PRs to `main` and the `v3.0.0` tags need the professor's approval (norm 9.5); the six PRs are open and no review has arrived yet.
- GitHub Actions cannot run in the organization (billing limit): every gate was run locally with the commands of its job and recorded.
- Found this week and not yet fixed: the slow fallback of the professional list when identity is down (no circuit breaker), the request validated before the authorization with an empty body in both APIs, the stale `_shared.yaml` copies of the contract tests, and the dependency scan of the jars (Spring Boot 3.5.6).

## 4. Plan for next week
- Final presentation, documentation and handover: the demo of Session 2 as the live part.
- Merge and tag `v3.0.0` in my six repositories as soon as the professor approves the release PRs.
- Turn this week's findings into stories: a circuit breaker on the names lookup, authorization before validation, the contract copies refreshed, the dependency upgrade.

## 5. Compliance self-check
- [x] Conventional Commits - `type(scope): summary`
- [x] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [x] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links
- Optional activities: [Session 1](Optional%20Activity%20Week%2015%20-%20Session%201.md) ([files](session-1/README.md)), [Session 2](Optional%20Activity%20Week%2015%20-%20Session%202.md) ([files](session-2/README.md))
- Onboarding saga, my side: https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/52, https://github.com/code-corhuila/telemed-ia-docs/pull/177 and the promotion https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/53
- Shared documentation: https://github.com/code-corhuila/telemed-ia-docs/pull/178, https://github.com/code-corhuila/telemed-ia-docs/pull/179, https://github.com/code-corhuila/telemed-ia-docs/pull/180, https://github.com/code-corhuila/telemed-ia-docs/pull/181, https://github.com/code-corhuila/telemed-ia-docs/pull/182 and https://github.com/code-corhuila/telemed-ia-docs/pull/183
- Release 3.0.0 to `main`: https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/37, https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/56, https://github.com/code-corhuila/telemed-ia-professional-management-portal/pull/20, https://github.com/code-corhuila/telemed-ia-document-generation-db/pull/15, https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/63 and https://github.com/code-corhuila/telemed-ia-document-generation-portal/pull/20
- Test runs: [Testcontainers](session-1/results/integration-testcontainers.txt), [contract](session-1/results/contract-tests.txt), [money path 1](session-1/results/e2e-money-path-1.txt), [money path 2](session-1/results/e2e-money-path-2.txt), [load](session-1/results/load-test.md), chaos [1](session-1/results/chaos-1.txt), [2](session-1/results/chaos-2.txt), [3](session-1/results/chaos-3.txt), [rollback](session-2/results/rollback-rehearsal.txt), [security](session-2/results/security-authz-probes.txt), [secrets](session-2/results/security-gitleaks.txt), [demo](session-2/results/demo-under-stress.txt)
- Team work: workflow saga https://github.com/code-corhuila/telemed-ia-workflow/pull/33, `/me` https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/54, patient PDF https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/60, manuals https://github.com/code-corhuila/telemed-ia-docs/pull/213 and https://github.com/code-corhuila/telemed-ia-docs/pull/214, appointment outbox poller https://github.com/code-corhuila/telemed-ia-appointment-scheduling-api/pull/26
