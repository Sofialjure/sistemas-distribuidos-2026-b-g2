# OPTIONAL ACTIVITY — Week 12 · Session 2

## Planning — deployment plan, IaC and rollback

> **Task of the week:** write the deployment plan for MVP 3: artifact promotion, IaC for your
> environments, the chosen zero-downtime strategy, and a rehearsed rollback (documented, timed).
> Slice the deployment stories with testable acceptance criteria.

Scope: the services I own, **Professional Management** and **Document Generation** (database,
API and portal of each), inside the TeleMed IA platform. The timings come from the rehearsal of
Session 1, not from estimates.

---

## 1. Artifact promotion: one image, three environments

```
merge to develop ──► build image once ──► registry ──► develop ──► qa ──► main (prod)
                     tag = commit sha                  same digest, different configuration
```

| Step | What happens | State today |
|---|---|---|
| Build | `deploy/Dockerfile` builds the service once, tagged with the commit (`professional-management-api:eeb08c7`) | Done locally; the CI job cannot run (organization billing limit) |
| Registry | push to `ghcr.io/code-corhuila/telemed-ia-<service>:<sha>` | Planned (needs CI) |
| develop → qa | code is promoted with `git cherry-pick -x`, and every promotion PR is checked to leave **the same tree** as `develop` | Done: `qa` equals `develop` in the six repositories |
| Image to qa | because the tree is identical, the image built for that `develop` commit **is** the qa artifact: it is re-tagged, not rebuilt | Planned |
| qa → main | same rule, after the professor's approval (norm) | Pending approval |

Why the identical-tree check matters: cherry-picks create new commit ids, but if the tree is the
same, the bytes are the same, so promoting the already-tested image is safe. If a promotion ever
changed the tree, the rule is to rebuild and test again, never to deploy an untested artifact.

---

## 2. Infrastructure as Code: what is already code

| Layer | File(s) | Reproduces |
|---|---|---|
| Platform | `telemed-ia-infra-postgres/compose.yml` | one PostgreSQL instance, observability (Prometheus, Alertmanager, Grafana, OTel Collector, Jaeger), object storage |
| Instance bootstrap | `postgres/init/01-instance.sh` | roles `<domain>_app`, `_reader`, `_writer`, schemas and grants for each domain |
| Schema | each `-db` repo: Liquibase changelogs + `deploy/compose.yml` (migration executor) | the schema from an empty database, and its rollback |
| Services | each `-api` and `-portal`: `deploy/Dockerfile` + `deploy/compose.yml` | the container and its runtime contract |
| Configuration per environment | `env/{dev,qa,main}.env.example` (names, never values) + validation scripts | which variables each environment must provide |
| Observability | `observability/*.yml`, dashboards JSON, alert rules + `promtool` tests | alerts and dashboards, reviewed like code |

Rules for MVP 3:

- No change is made by hand on a running environment; it goes through a reviewed PR.
- qa and prod are created from the same files; only the `env/<environment>.env` values differ.
- The platform is rebuilt from scratch as a check: `docker compose up` + every migration executor
  on an empty volume. The platform-wide verification of 2026-10-27 rebuilt the 28 repositories
  this way on a fresh network and volume; the manual steps it still needed (test secrets, and a
  consultation row because no endpoint creates consultations yet) are listed for their owners.

Open gap, documented for the team: the shared `compose.yml` includes the `-db` executors but not
the APIs; each API is started with its own `deploy/compose.yml`. Including them is a team decision
because it changes how everyone starts the platform.

---

## 3. Zero-downtime strategy

| Component | Strategy | Why |
|---|---|---|
| `professional-management-api`, `document-generation-api` | **Blue-green** behind the front door, readiness gate on `:9081/actuator/health` | stateless; instant switch and instant rollback; rehearsed |
| Portals (static bundles served by nginx) | Blue-green of the container | a portal is a file set; the shell keeps working if a remote is down |
| Database schema | **Expand / contract** migrations | both versions must work against the same schema during the switch |
| Background work (PDF generation, outbox relay) | Both colors may run; work is claimed in the database | `FOR UPDATE SKIP LOCKED` and conditional status updates keep it single |

### Schema changes must not block the rollback

A blue-green switch is instant only if blue still works with the schema green needs. Example
already applied in Professional Management (UUID identifiers, professional-db #32):

1. **Expand:** add the new `*_uuid` columns next to the old ones, with a reversible mapping.
2. **Index** concurrently, in its own changeset.
3. **Switch** the columns in one changeset, with a rollback guarded against data that cannot go
   back.
4. **Contract:** validate the constraint, and remove the old structure only after no running
   version reads it.

---

## 4. Rollback: rehearsed and timed

| Step | Command / check | Measured |
|---|---|---|
| 1. Decide | burn-rate alert, or error rate / p95 above the SLO after the switch | — |
| 2. Switch back | `cp lb/blue.inc lb/active.inc && nginx -t && nginx -s reload` | **1.35 s** (run 3) |
| 3. Verify | every response says `X-Served-By: blue`; 5xx back to zero; burn rate below 1 | 0 failed requests during the rollback |
| 4. Keep green | do not delete green until the cause is understood (logs by `traceId`) | — |

Rehearsed three times on 2026-10-27 under continuous traffic: 746 requests, 0 failures. The
target "prod reverted in < 5 minutes" is met with margin.

Database rollback is a separate decision: an application rollback never runs a schema rollback.
Because migrations are expand/contract, the previous version keeps working on the expanded
schema; `liquibase rollback` is only for a failed migration, and the changesets that cannot
safely go back refuse to (guard).

---

## 5. Deployment stories for MVP 3

| Id | Story | Acceptance criteria (testable) | Priority |
|---|---|---|---|
| **DEP-01** | As the team, I want CI to build and push one versioned image per merge | Given a merge to `develop`, then an image tagged with the commit is in the registry; given the same commit twice, then the digest is the same | P1 (blocked by billing) |
| **DEP-02** | As the team, I want qa to run the image tested in develop | Given a promotion PR whose tree equals develop, then the qa deploy uses the existing digest, and the deploy log shows no build step | P1 |
| **DEP-03** | As an operator, I want blue-green with a readiness gate | Given a new color whose `/actuator/health` is not `UP`, when the switch runs, then it aborts and traffic stays on the live color | P0 (rehearsed) |
| **DEP-04** | As an operator, I want a rehearsed rollback under 5 minutes | Given continuous traffic, when green is switched back to blue, then 0 requests fail and the switch takes < 5 min | P0 (rehearsed: 1.35 s) |
| **DEP-05** | As the team, I want schema changes that do not block a rollback | Given a migration, then the previous API version still passes its tests against the new schema (expand/contract) | P1 |
| **DEP-06** | As the team, I want environments created only from code | Given an empty host, when compose and the migration executors run, then the platform answers its health checks with no manual step besides providing secrets | P1 |
| **DEP-07** | As security, I want configuration out of the image | Given the image, then it contains no `.env`, key or secret; given a missing required variable, then the service refuses to start | P1 |

---

## 6. Risks

| Risk | Mitigation |
|---|---|
| CI blocked by billing → no automatic image build | images built from the tagged commit with the versioned Dockerfile; reproducible locally |
| `/health` passes while the database is unreachable (found in Session 1) | readiness gate on the actuator; liveness stays on `/health` |
| APIs not in the shared compose | each API has its own versioned compose; team decision pending |
| One host only | the plan is the same for a cloud container service; only the front door changes |

---

## 7. Evidence

| What | Where |
|---|---|
| Rehearsal (Session 1) | [Optional Activity Week 12 - Session 1](Optional%20Activity%20Week%2012%20-%20Session%201.md) |
| Expand/contract migration with guarded rollback | [professional-management-db #32](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/32) |
| Environment examples validated by script | [infra-postgres #26](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/26), [#28](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/28) |
| Promotions with identical tree | promotion PRs to `qa` in the six repositories (e.g. [professional-management-api #51](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/51)) |

---

## 8. Self-check

| # | Question | Answer |
|---|---|---|
| 1 | Artifact promotion means… | Deploying the same built image to each environment (config differs) |
| 2 | Infrastructure as Code gives you… | Reproducible, version-controlled, reviewable environments |
| 3 | A rollback plan is trustworthy only if… | It has been rehearsed/tested |
| 4 | For instant switch-and-revert you'd choose… | Blue-green deployment |
| 5 | A "snowflake" server is… | A manually configured, non-reproducible machine |
| 6 | "Works in qa" is meaningful only when… | qa matches prod (built from the same IaC) |
