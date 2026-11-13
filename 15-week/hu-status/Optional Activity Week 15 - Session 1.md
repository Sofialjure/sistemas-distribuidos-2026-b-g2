# OPTIONAL ACTIVITY — Week 15 · Session 1

## Testing at scale — integration with Testcontainers, contract tests in CI, money-path E2E, load to the SLO and chaos

> **Task of the week:** complete your test suite: integration with testcontainers, contract tests
> in CI, a couple of e2e money-path tests, a load test to your SLO, and one chaos experiment
> (kill a service, confirm graceful degradation).

Everything below was **executed**, not only written, on 2026-11-12/13. The system under test is
the whole TeleMed IA platform built from `develop` of every repository (the 30 commits are listed
in [`platform-snapshot.md`](session-1/results/platform-snapshot.md); in my six repositories
`develop` and `qa` have the same tree), started in an isolated Docker network with its own
volumes, so nothing touched the team's running environment. Files: [`session-1/`](session-1).

---

## 1. The pyramid of my two services

| Level | Professional Management | Document Generation | Where |
|---|---|---|---|
| Unit (domain, use cases) — module `-core`, no framework | 52 | 86 | each API, `mvn -B verify` |
| Adapters: HTTP and persistence against the real engine — module `-adapters` | 55 (PostgreSQL 16) | 202 (PostgreSQL 16 + RustFS; 6 RabbitMQ tests skipped without `TEST_RABBITMQ_URL`) | each API |
| Application wiring, HTTP end to end and contract — module `-app` | 111, of them 38 contract | 61, of them 28 contract | each API; contract in section 3 |
| Database integration with **Testcontainers** | 5 | 6 | section 2 (new this week) |
| Portals (Vitest) | 46 | 26 | `npm run test:ci` |
| E2E money paths | path 1 | path 2 | section 4 (new this week) |
| Load to the SLO | professional list | document list | section 5 (new this week) |
| Chaos | identity down | document API down, broker down | section 6 (new this week) |

Unit, HTTP, integration and contract suites: `mvn -B verify` on 2026-11-12, **218 tests and 349
tests, 0 failures** (the 6 skipped are named above). Portals: build OK, 46 and 26 passed.

## 2. Integration with Testcontainers

The two APIs already test their adapters against a real PostgreSQL, but the database was started
by hand and passed in `TEST_DATABASE_URL`. This week I wrote a Testcontainers project for the two
`-db` repositories ([`integration-testcontainers/`](session-1/integration-testcontainers)): each
class starts its own `postgres:16-alpine`, bootstraps it **exactly as
`telemed-ia-infra-postgres` does** (application user, reader/writer roles, schema owned by the
user, `search_path`), runs the **real Liquibase changelog** of the repository as the application
user with the suffixed control tables, and Ryuk removes the container at the end.

| Test class | What it proves | Result |
|---|---|---|
| `ProfessionalManagementDbIT` | 36 changesets from empty; defaults (`id` UUID, `GENERAL_PRACTITIONER`, `ACTIVE`, `created_at`); unique licence `23505`; status/years checks `23514`; roll back and apply again | 5/5 |
| `DocumentGenerationDbIT` | 17 changesets from empty; document + `outbox_event` commit together and a failed event undoes the document (transactional outbox); `AVAILABLE` needs its object key and `ERROR` its message; one row per `Idempotency-Key`; roll back and apply again | 6/6 |

Result: **11 tests, 0 failures** ([log](session-1/results/integration-testcontainers.txt)).

**Finding.** The first run of "roll back everything" failed in both repositories: in the shared
instance the Liquibase control tables live inside the domain schema, and the first changeset
(`ddl-schemas-001`) is the one that creates that schema (Professional Management refuses to drop
it; Document Generation drops it with the control table inside). `db-ci.yml` does not see this
because its database keeps the control tables in `public`. It does not affect a real rollback
(the schema belongs to infra and the release rollbacks stop above it), so the test now rolls
back everything except `ddl-schemas-001`.

## 3. Contract tests in CI

- The contract suites run inside `mvn -B verify` (38 and 28 tests) and validate **every
  response** against the OpenAPI copy of `telemed-ia-docs` with `swagger-request-validator`.
- New job [`ci/contract-tests.yml`](session-1/ci/contract-tests.yml): checks out
  `telemed-ia-docs@main`, **fails if a contract copy differs** from the source, then runs only the
  contract suite. Minimum permissions and a time limit, as in Anexo I.
- I ran its two steps ([result](session-1/results/contract-tests.txt)):
  - the drift check **found drift**: `_shared.yaml` differs in both APIs (9 and 62 lines) because
    consultation and the agent changed their schemas this week; my own `professional-service.yaml`
    and `document-service.yaml` are identical to `docs`;
  - with the copies replaced by the current `docs` contract, **38/38 and 28/28 still pass**: the
    drift does not touch my endpoints, and refreshing the copies is a one-commit change.

GitHub Actions cannot run in the organization (billing limit), so the job was executed with its
exact commands.

## 4. E2E money paths

Two journeys that cross every service, through the API Gateway, with assertions
([`e2e/`](session-1/e2e)); the only direct reads are SQL checks of the asynchronous steps.

| Money path | Journey | Result |
|---|---|---|
| [1 — a professional can start working](session-1/e2e/money-path-1-onboarding.sh) | ADMIN → onboarding saga (identity creates the account inactive, professional-management creates the profile, identity activates it) → replay `200`, other body `422` → the professional signs in and reads `/me` → the admin lists it newest first with its name and e-mail, a professional sees no e-mails → `403` / `200` / `200` status changes → correlation id in the workflow log | **15/15** ([log](session-1/results/e2e-money-path-1.txt)) |
| [2 — a patient gets the PDF](session-1/e2e/money-path-2-consultation-pdf.sh) | patient registers and books → professional starts the consultation and records the attention → automatic post-summary → consultation outbox → RabbitMQ → worker → `POST /api/documents/generate` → PDF in RustFS → my outbox publishes `ConsultationPdfGenerated` → notifications inbox → appointment `COMPLETED` → the patient lists and downloads the PDF (`200`, `%PDF-`) → another patient `403`, a professional `403` | **15/15** in ~45 s ([log](session-1/results/e2e-money-path-2.txt)) |

The professional's weekly availability is inserted with SQL in path 2: the platform has no
endpoint for it (appointment-scheduling, reported to its owner).

## 5. Load test to the SLO

SLO of the reads (Professional Service `observability.md`; I applied the same read objective to
the document list, whose own SLOs in `observability.md` cover PDF generation): **availability ≥ 99.5 %** (no 5xx or timeout) and **95 % of reads under
500 ms**. [`load/load.py`](session-1/load/load.py) is an **open-loop** stepped test: each step
offers a fixed rate for 20 s and measures latency from the moment each request was *scheduled*,
so a slow service cannot hide its queue (coordinated omission). It runs inside the platform
network because the gateway limits each IP to 20 r/s (checked: at 60 r/s from one IP it accepted
219 requests in 10 s and answered `429` to 381, as configured).

**Professional list** (`GET /api/professionals?limit=20` as ADMIN — each page also asks identity
for the account names):

| offered rps | p50 ms | p95 ms | p99 ms | availability | SLO |
|---|---|---|---|---|---|
| 10 | 24.8 | 54.3 | 71.5 | 100 % | met |
| 50 | 11.2 | 19.7 | 31.0 | 100 % | met |
| 100 | 11.2 | 32.3 | 69.3 | 100 % | met |
| 200 | 8.7 | 74.4 | 189.9 | 100 % | met |
| 300 | 10.9 | 102.5 | 163.8 | 100 % | met |
| 350 | 11.7 | 490.3 | 644.8 | 100 % | met, at the limit |
| 400 | 1037.6 / 19.6 | 1548.8 / 255.4 | 1736.2 / 366.7 | 100 % | missed in one run, met in the other |

**The knee is between 350 and 400 rps** on this laptop: there the p95 jumps around the 500 ms
limit. CPU at the knee (`docker stats`): professional-management-api 107–154 %, identity 84–112 %,
PostgreSQL 46–71 %, the generator 72–105 % — the cost of one page is shared with identity (the
names lookup), and above 400 rps my one-process generator is also near its own limit, so I report
the knee as a range and not as one number.

**Document list** (`GET /api/documents?limit=20` as PATIENT): SLO met at every step up to
**500 rps** (p95 ≤ 31 ms, 100 % available). At 700 rps the generator only reached 252 rps, so that
step measures my generator, not the service: the knee of the document list is above what one
laptop can offer.

Full tables, CPU samples and the gateway check: [`load-test.md`](session-1/results/load-test.md).

## 6. Chaos experiments

Each experiment states its hypothesis, injects the failure with `docker stop`, checks the steady
state during the failure and the recovery after `docker start` ([`chaos/`](session-1/chaos)).

| Experiment | During the failure | Recovery | Result |
|---|---|---|---|
| [1 — kill identity](session-1/chaos/chaos-1-identity-down.sh) | issued tokens keep working (RS256 verified in each service); the professional list **degrades to profiles without names** (`200`); registration fails fast with `503` in 397 ms and stores nothing; the saga ends `COMPENSATED` at `create-account` with no profile; documents are not affected; new sign-ins fail (the blast radius) | names back 18 s after the restart; the same registration then answers `201` | **10/10** ([log](session-1/results/chaos-1.txt)) |
| [2 — kill document-generation-api mid-journey](session-1/chaos/chaos-2-document-api-down.sh) | the attention and the post-summary are recorded; the worker retries 3 times and parks the event in `post-consultation-summary-queue.dlq` after 15 s (**not lost**); the patient's list answers an error, not a hang | the dead-letter replay generated the PDF 14 s after the restart (the replay runs every 5 minutes, so the worst case is about 5 minutes); **exactly one** document; the DLQ is empty; download `200` | **9/9** ([log](session-1/results/chaos-2.txt)) |
| [3 — stop RabbitMQ](session-1/chaos/chaos-3-broker-down.sh) | the attention is recorded; `PostConsultationSummaryGenerated` waits as `PENDING` in the consultation outbox; no document yet | 21 s after the broker restart: event published, PDF generated once, **my relay reconnected** and published `ConsultationPdfGenerated`, notifications received it | **7/7** ([log](session-1/results/chaos-3.txt)) |

**Finding of chaos 1 — graceful but slow.** With identity down, the professional list still
answers, but each read took **1.5 s on average** waiting for the names lookup to fail: the
service degrades correctly and still **misses its latency SLO** during the outage. The fix is a
circuit breaker (or a much shorter connect timeout) around the names lookup, so the fallback is
immediate while identity is down; it is the first story of my plan for week 16.

## 7. Evidence

| File | Content |
|---|---|
| [`session-1/integration-testcontainers/`](session-1/integration-testcontainers) | Testcontainers project (`mvn -B test -Dpm.db.repo=… -Ddg.db.repo=…`) |
| [`session-1/ci/contract-tests.yml`](session-1/ci/contract-tests.yml) | contract job: drift check + contract suite |
| [`session-1/e2e/`](session-1/e2e) | money paths 1 and 2 and their helpers |
| [`session-1/load/load.py`](session-1/load/load.py) | open-loop stepped load test |
| [`session-1/chaos/`](session-1/chaos) | the three experiments |
| [`session-1/results/`](session-1/results) | every log and table quoted above |

## 8. Self-check

- [x] I can explain the pyramid adapted to distributed systems, and where load and chaos fit.
- [x] My contract tests run against the published OpenAPI, and a CI step catches a stale copy.
- [x] I used Testcontainers with the real engine and the real migrations, cleaned up automatically.
- [x] I ran a load test against my SLO and found the knee (and where my generator limits it).
- [x] I killed services and verified graceful degradation, retries, the dead-letter queue and recovery.
