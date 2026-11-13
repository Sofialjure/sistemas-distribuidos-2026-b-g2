# OPTIONAL ACTIVITY — Week 15 · Session 2

## Release — shipping MVP 3 of Professional Management and Document Generation

> **Task of the corte:** ship MVP 3: promote to main, tag v3.0.0, verify the operability checklist
> (load + chaos + rollback + security), and demo the system under stress and failure. Ensure each
> member's hu-status evidence is complete.

Executed on 2026-11-12/13 on the same isolated platform as session 1. Files:
[`session-2/`](session-2), plus the session 1 suites it reuses.

---

## 1. Promote `develop → qa → main` and tag `v3.0.0`

```text
develop --cherry-pick -x--> qa --validated--> release/3.0.0 --PR (professor)--> main --> tag v3.0.0
```

- **`develop → qa`: done.** In my six repositories the tree of `qa` is identical to `develop`
  (checked file by file through the GitHub API on 2026-11-12); every commit in `qa` carries its
  `cherry picked from` line.
- **`qa → main`: the six release PRs are open** (norm 11): `release/3.0.0` cut from `main`, the
  commits of `qa` that `main` does not have re-applied with `cherry-pick -x` (each commit carries
  two trace lines, develop → qa and qa → release), the tree of each release branch **identical to
  `qa`**, and each PR lists its stories, scope, deployment instructions, rollback plan and trail:

| Repository | Release PR | Commits | Notes |
|---|---|---|---|
| professional-management-db | [#37](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/37) | 17 | after `v2.0.0`; 9 changesets (27 → 36) |
| professional-management-api | [#56](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/56) | 118 | first release to `main` |
| professional-management-portal | [#20](https://github.com/code-corhuila/telemed-ia-professional-management-portal/pull/20) | 31 | first release to `main` |
| document-generation-db | [#15](https://github.com/code-corhuila/telemed-ia-document-generation-db/pull/15) | 10 | after `v2.0.0`; 4 changesets (13 → 17) |
| document-generation-api | [#63](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/63) | 116 | first release to `main` |
| document-generation-portal | [#20](https://github.com/code-corhuila/telemed-ia-document-generation-portal/pull/20) | 9 | after `v2.0.0` |

- **Merge and tag: waiting for the professor.** `main` requires the professor's approval (norm
  9.5); the PRs request `@ariel5253` and Juliana. After each merge (Rebase and merge, so no merge
  commit reaches `main`) the tag is created on `main`:
  `git tag -a v3.0.0 -m "Release v3.0.0: …" && git push origin v3.0.0`.
- **Zero-downtime strategy**: blue-green behind nginx, rehearsed in week 12 with
  professional-management-api — 746 requests across three releases and three rollbacks with
  0 failed requests; with the readiness gate the switch took 1.61 s and the rollback 1.35 s ([week 12, session 1](../../12-week/hu-status/Optional%20Activity%20Week%2012%20-%20Session%201.md)).

## 2. The MVP 3 operability checklist

| Item | Evidence | Status |
|---|---|---|
| **Functional & pipeline** — acceptance criteria met; CI green | HU-05 and HU-16 money paths 15/15 and 15/15; suites 218 and 349 tests (0 failures), portals 46 and 26, Testcontainers 14, contract 38 and 28; the gates of week 14 written as workflows | **Partial**: every test green; CI cannot run in the organization (billing) and two gates were red when last measured in week 14 (lint in Document Generation, 2 findings; the dependency scan of both jars) and were not re-run this week |
| **Deployment** — zero downtime; rehearsed rollback | blue-green of week 12 (0 errors); database rollback of release 3.0.0 rehearsed this week on the real upgrade path (section 3) | **Met**, with the limit found in section 3 |
| **Observability** — golden-signal dashboards, a real alert with a runbook, distributed tracing | dashboards `document-generation` and `professional-management`, burn-rate alerts with `promtool` tests and runbooks (week 11: infra-postgres #25, #30; docs #102, #125); traces over OTLP to Jaeger; the metrics those dashboards read, collected after this week's load and chaos ([golden signals](session-2/results/observability-golden-signals.md)) | **Met** |
| **Security** — authn/authz in each service; no secrets in git; dependency and secret scans pass | [authorization probes](session-2/security/authz-probes.sh): 17 of 20 as expected; gitleaks: **0 leaks in 1,745 commits** of the six repositories; dependency scan: still failing (week 14) | **Partial** (section 4) |
| **Resilience** — load meets the SLO; chaos shows graceful degradation; cross-service consistency | SLO met up to 300–350 rps (professional list) and 500 rps (document list); 3 chaos experiments 26/26; outbox + idempotency: exactly one PDF per summary after retries, DLQ replay and a broker restart | **Met**, with the slow fallback found in chaos 1 |
| **Release** — versioned 3.0.0; changelog, ADRs and runbooks updated | six release PRs with scope, deployment and rollback (the PR bodies are the release notes: the repositories have no `CHANGELOG.md`); this week the shared docs were updated: ADR-025 to ADR-028, runbooks, CI/CD, backup and recovery (docs #179 to #183) | **Partial** until the merge and the tag |

## 3. Rollback, rehearsed

[`ReleaseRollbackIT`](session-1/integration-testcontainers/src/test/java/week15/ReleaseRollbackIT.java)
follows the real upgrade path with Testcontainers: migrate the database with `main` (`v2.0.0`),
upgrade it with the release (`qa`), roll back with the count the release PR states, and upgrade
again ([log](session-2/results/rollback-rehearsal.txt), 3/3):

| Database | Path | Result |
|---|---|---|
| Document Generation | 13 → 17 → `rollback-count 4` → 13 (no `outbox_event`) → 17 | passes |
| Professional Management | 27 → 36 → `rollback-count 9` → 27 → 36 | passes |
| Professional Management, after the release created a profile | 27 → 36 → insert → `rollback-count 9` | **refused** by `ddl-alter-024` (a database-generated UUID has no integer equivalent); the 3.0.0 schema and the row stay intact |

Two findings, both corrected in the release PRs the same day:

1. The first version of the rehearsal migrated straight to 3.0.0 and `rollback-count 4` removed
   the wrong changesets: on a fresh database the 4 new Document Generation changesets run in the
   middle of the order, not at the end. The count is right only on a database upgraded from
   `v2.0.0` — the real case — and the PR now says so.
2. Once Professional Management 3.0.0 registers a professional, its database cannot go back to
   `v2.0.0` (by design: the UUIDs would be lost). The plan in the PR now says that after that point
   the schema stays at 3.0.0 and the fix goes forward through `hotfix/`.

## 4. Security

[Authorization probes](session-2/results/security-authz-probes.txt), through the gateway and, for
the routes it does not publish, from inside the platform network:

- **Pass (17)**: no token / forged signature / `alg: none` → `401` on both services; PATIENT and
  PROFESSIONAL cannot register professionals or change a status (`403`); `/me` only for
  professionals; the internal saga route is not published by the gateway (`404`) and rejects an
  ADMIN token (`403`); documents only for their patient (`403` for ADMIN, PROFESSIONAL and another
  patient); `POST /generate` rejects a PATIENT and a SERVICE token of another client
  (`notifications`), the control of my week 13 threat model.
- **Known and still open (3)**: with an *empty* body both APIs answer `400` before `403` — the
  request is validated in the controller before the use case authorizes it (found in week 13 for
  documents; the probes show the same pattern in registration and the internal saga route). No
  data is exposed, only the field names. The pause switch on the management port answers without
  a token inside the platform network (story docs #151).
- **Secrets**: [gitleaks](session-2/results/security-gitleaks.txt) over every branch of the six
  repositories: 1,745 commits, 0 leaks.
- **Dependencies**: not re-run this week; the week 14 scan of both jars is still red (most of it
  is the Spring Boot 3.5.6 set) and is the main security item left for the next release.

## 5. Demo under stress and failure

[`demo-under-stress.sh`](session-2/demo/demo-under-stress.sh) runs the four demo steps **at the
same time** ([log](session-2/results/demo-under-stress.txt)):

1. **Load**: 100 rps on the professional list and 100 rps on the document list for 90 s.
2. **Full journey** under that load: money path 1 — **15/15**.
3. **Failure** under that load: chaos 2, document-generation-api killed in the middle of a
   consultation — **9/9**: the event waited in the dead-letter queue (68 s to get there under load)
   and the PDF was generated 46 s after the restart.
4. **Observability**: the golden signals read from both services afterwards.

| List during the demo | p50 | p95 | p99 | availability | SLO |
|---|---|---|---|---|---|
| professionals (its service never failed) | 23.3 ms | 231.6 ms | 908.8 ms | 100 % | **met** |
| documents (its service was down ~76 s of the 90 s) | — | — | — | 24.9 % | missed, as expected; recovered by itself |

The failure of one service did not leak into the other one, and no PDF was lost.

## 6. Retrospective toward the final presentation

- **What made the system reliable**: the transactional outbox on both sides of every event, the
  idempotency keys (one PDF per summary even after retries and replays), the dead-letter queue with
  replay, the fallbacks (the list without names), and tests at every level against real engines.
- **What we would do differently**: a circuit breaker for synchronous calls from the start (chaos
  1), dependency upgrades every week instead of at the end, the contract copies refreshed by a CI
  job instead of by hand, and an endpoint for the professionals' availability.
- **What the metrics show**: the reads stay far inside their SLO at normal load (p95 under 110 ms
  up to 300 rps) and the knee is 350–400 rps on one laptop; the asynchronous journey recovers by
  itself from the loss of any one of its services in 14–46 s.
- **For week 16**: the demo script of section 5 as the live part of the presentation; the release
  merged and tagged; the findings of this week as the next backlog (circuit breaker, authorization
  before validation, contract copies, dependency upgrade).

## 7. Evidence

| File | Content |
|---|---|
| [`session-2/security/authz-probes.sh`](session-2/security/authz-probes.sh) | authorization probe matrix |
| [`session-2/demo/demo-under-stress.sh`](session-2/demo/demo-under-stress.sh) | the demo, load + journey + failure at once |
| [`session-1/integration-testcontainers/…/ReleaseRollbackIT.java`](session-1/integration-testcontainers/src/test/java/week15/ReleaseRollbackIT.java) | rollback rehearsal |
| [`session-2/results/`](session-2/results) | probes, gitleaks, rollback, golden signals, demo and its load tables |

## 8. Self-check

- [x] I can explain why MVP 3 is production-grade: observable, secure, resilient and deployable.
- [x] I know the steps to promote and tag `v3.0.0`, and the release PRs are open with their trail.
- [x] I verified the operability checklist item by item, with what is still partial.
- [x] I demoed the system under load and failure at the same time.
- [x] My hu-status of week 15 has its evidence linked.
