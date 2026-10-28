# OPTIONAL ACTIVITY — Week 13 · Session 2

## Planning — threat modeling and the security backlog

> **Task of the week:** build a threat model (data-flow + trust boundaries + STRIDE), turn the
> findings into a prioritized security backlog with testable criteria, and add security gates
> (deps/secrets/authz tests) to CI.

Scope: **Professional Management** and **Document Generation**, the two domains I own, with the
services they talk to. The gates in section 4 were **run** on 2026-10-27, so the backlog starts
from real results, not from guesses.

---

## 1. Data flow and trust boundaries

```
 [Browser: shell + portals]
        │  HTTPS, Bearer JWT                                    TB1 internet → platform
════════╪═══════════════════════════════════════════════════════════════════════
        ▼
 [API gateway / nginx]  401 without credentials, rate limit, timeouts
        │  /api/v1/professionals → /api/professionals                TB2 edge → service
        │  /api/v1/documents     → /api/documents
════════╪═══════════════════════════════════════════════════════════════════════
        ▼                                         ▼
 [professional-management-api]            [document-generation-api] ◄── worker (service token)  TB3 service → service
   │        │                                │        │        │
   │        └─► identity: service token,     │        │        └─► Medical Consultation (read summary)
   │            accounts, names    TB3       │        │
   ▼                                         ▼        ▼
 [PostgreSQL: professional_management]  [PostgreSQL: document_generation] [RustFS: PDFs]   TB4 service → data
                                             │
                                             └─► outbox ─► RabbitMQ documents.events ─► Notifications  TB5 async
```

| Boundary | What crosses it | Data at stake |
|---|---|---|
| **TB1** internet → platform | user requests with a JWT | credentials, tokens |
| **TB2** gateway → service | the same request, now on the internal network | identity of the caller, role |
| **TB3** service → service | service tokens (`role: SERVICE`) | account creation, clinical summary |
| **TB4** service → data | SQL with the domain's own role; PDF objects | profiles, e-mails, clinical PDFs |
| **TB5** async (RabbitMQ) | events with ids only | patient and appointment ids |

---

## 2. STRIDE over the boundaries

| # | STRIDE | Threat | Boundary | Mitigation in place | Gap |
|---|---|---|---|---|---|
| T1 | **S**poofing | forged or tampered JWT | TB1, TB2 | RS256 signature, algorithm and `exp` checked **in each service**; `alg none`, other key, edited payload, expired → `401` (probed) | — |
| T2 | **S**poofing | a service pretends to be the worker to create PDFs | TB3 | `SERVICE` accepted only for clients in an allow-list; rogue client → `403` (probed) | no mTLS between containers |
| T3 | **T**ampering | replayed or altered creation request | TB2 | `Idempotency-Key` + SHA-256 of the request; same key, other body → `422` | — |
| T4 | **T**ampering | event altered in transit | TB5 | events carry ids only; consumers re-read by API | broker without TLS on the internal network |
| T5 | **R**epudiation | "I did not deactivate that doctor" | TB2 | domain event in the log with `traceId`, `correlationId`, `professional_id`, `status` | the log line does not record **who** (`sub`) made the change |
| T6 | **I**nformation disclosure | a patient reads every doctor's e-mail | TB2 | e-mail returned only to `ADMIN` (DEC-009), probed | — |
| T7 | **I**nformation disclosure | a patient reads another patient's PDF (IDOR) | TB2, TB4 | ownership checked in the use case → `403`; downloads are signed URLs of 5 min | `403` vs `404` reveals that the id exists |
| T8 | **I**nformation disclosure | an unauthorized caller learns the shape of `POST /generate` | TB2 | — | **validation runs before authorization** (`400` instead of `403`, probed) |
| T9 | **I**nformation disclosure | known vulnerabilities in dependencies | all | — | **33 HIGH/CRITICAL CVEs** in the API image (section 4) |
| T10 | **I**nformation disclosure | secrets committed to git | — | `.env` and keys ignored, `.env.example` without values, secrets injected at run time | no secret scan in CI yet (ran manually: 0 findings) |
| T11 | **D**enial of service | flood of list requests | TB1, TB2 | gateway rate limit, page size ≤ 100, statement timeout and pool limits | — |
| T12 | **D**enial of service | identity or Medical Consultation slow | TB3 | 5 s timeouts, bounded retries with jitter, list degrades without names, pause switch for generation | — |
| T13 | **D**enial of service | traffic sent to a release that cannot reach its database | deploy | readiness gate on `/actuator/health` (week 12) | `/health` alone reports `UP` without the database |
| T14 | **E**levation of privilege | a patient or professional calls an admin action | TB2 | role checked in the use case → `403` (probed) | — |
| T15 | **E**levation of privilege | a service writes into another domain's schema | TB4 | one database role per domain, no cross-domain FKs or writes (Anexo J) | — |

---

## 3. Prioritized security backlog

Risk = likelihood × impact. P0 = this sprint, P3 = when there is room.

| Id | Story | Acceptance criterion (testable) | Threat | Risk | Priority |
|---|---|---|---|---|---|
| **SEC-01** | Upgrade the framework to the latest patch of its line | Given the image scan, when the API image is built, then no HIGH/CRITICAL finding with a fix in the current line (`spring-boot` 3.5.x, Tomcat 10.1.x, Jackson 2.x, PostgreSQL driver) remains | T9 | likely × high | **P0** |
| **SEC-02** | Assess the two CRITICAL `spring-webmvc` CVEs fixed only in Spring 7 | Given each CVE, then a written decision (affected or not, why) is in the service decisions; if affected, the vulnerable path is disabled or the upgrade is planned | T9 | possible × high | **P0** |
| **SEC-03** | Dependency and secret scanning in CI | Given a PR, then `trivy` (HIGH/CRITICAL with fix) and `gitleaks` run, and a finding fails the build | T9, T10 | likely × high | **P1** (CI blocked by billing; runnable locally today) |
| **SEC-04** | Authorization tests in CI for every role | Given each protected route, then a test proves `401` without token and `403` for each role that must not use it (contract suites already cover most) | T6, T14 | possible × high | **P1** |
| **SEC-05** | Authorize before validating in `POST /api/documents/generate` | Given a `PATIENT` with an empty body, when it calls `POST /generate`, then `403` and no field details | T8 | possible × low | **P2** |
| **SEC-06** | Record who changed a profile status | Given a status change, then its log line carries the caller's `sub` (account id, not a name or e-mail) | T5 | possible × medium | **P2** |
| **SEC-07** | Readiness and liveness split in every deploy | Given a container whose database is unreachable, then its readiness check fails and it receives no traffic | T13 | possible × high | **P1** |
| **SEC-08** | Decide `403` vs `404` for resources of other users | Given the team decision, then the contract and the tests say which code is returned, the same in every service | T7 | unlikely × low | **P3** |
| **SEC-09** | TLS or mTLS inside the platform | Given two services, then their traffic (HTTP and AMQP) is encrypted and each one presents a certificate | T2, T4 | unlikely × high (single host today) | **P3** (when deployed beyond one host) |

---

## 4. Security gates: run now, planned for CI

### Secret scanning (gitleaks 8.21.2, full git history)

| Repository | Commits scanned | Findings |
|---|---:|---:|
| professional-management-db | 562 | 0 |
| professional-management-api | 450 | 0 |
| professional-management-portal | 109 | 0 |
| document-generation-db | 123 | 0 |
| document-generation-api | 373 | 0 |
| document-generation-portal | 166 | 0 |

Positive control: a throwaway repository with a committed private key → `leaks found: 1`, so a
zero is a real zero, not a scanner that does not work.

### Dependency scanning (trivy 0.57.1, image `professional-management-api:eeb08c7`)

- **Operating system packages** (Ubuntu 22.04 base of `eclipse-temurin:21-jre-jammy`): no
  HIGH/CRITICAL findings.
- **Java libraries in the application jar:** **33 findings (8 CRITICAL, 25 HIGH)**:

| Library | Installed | Findings | Fixed in the same line? |
|---|---|---|---|
| `tomcat-embed-core` | 10.1.46 | 6 CRITICAL, 7 HIGH | yes, 10.1.55 / 10.1.58 |
| `spring-webmvc` | 6.2.11 | 2 CRITICAL, 2 HIGH | HIGH yes (6.2.19); **CRITICAL only in 7.0.9** |
| `jackson-databind`, `jackson-core` | 2.19.2 | 8 HIGH | yes, 2.21.x / 2.22.x |
| `postgresql` driver | 42.7.7 | 2 HIGH | yes, 42.7.12 |
| `spring-data-commons`, `spring-expression`, `spring-boot`, `micrometer-core` | Boot 3.5.6 line | 6 HIGH | yes, Boot 3.5.14 line |

All of them come with the Spring Boot 3.5.6 dependency set, so **one upgrade of the parent to the
latest 3.5.x patch removes most of them** (SEC-01). The two CRITICAL `spring-webmvc` items need an
assessment (SEC-02) because their fix is only in the next major version.

### Authorization tests

Already automated and running with every `mvn -B verify`: the Anexo C contract suites
(`ProfessionalServiceContractTest`, `DocumentServiceContractTest`) check `401` without token,
with an expired token, with another key and another algorithm, and the role rules, validating
each response against the OpenAPI contract. The live probes of Session 1 add the cross-service
view (20 probes, 19 pass, the failing one is SEC-05).

### Planned CI gates (when Actions can run)

```yaml
- run: mvn -B verify                                    # unit, HTTP, contract and authz tests
- uses: gitleaks/gitleaks-action@v2                     # secrets: any finding fails
- run: docker build -f deploy/Dockerfile -t app:${{ github.sha }} .
- run: trivy image --exit-code 1 --ignore-unfixed --severity HIGH,CRITICAL app:${{ github.sha }}
```

`--ignore-unfixed` keeps the gate actionable: it fails only on findings that have a fix.

---

## 5. Common mistakes avoided

| Mistake | Here |
|---|---|
| Security as a final scan | The model and the backlog come before MVP 3; the probes and scans are repeatable |
| No trust boundaries | Five boundaries mapped, each threat tied to one |
| Findings with no owner or priority | Every finding is a story with a priority and a testable criterion |
| No gates in CI | Gates defined and run locally; they fail the build once Actions can run |

---

## 6. Evidence

| What | Where |
|---|---|
| Script of the secret and dependency scans | [scripts/security-scans.sh](scripts/security-scans.sh) |
| Live security probes | [Optional Activity Week 13 - Session 1](Optional%20Activity%20Week%2013%20-%20Session%201.md) |
| Readiness finding | [Optional Activity Week 12 - Session 1](../../12-week/hu-status/Optional%20Activity%20Week%2012%20-%20Session%201.md) |
| E-mail only for administrators (T6) | [professional-management-api #39](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/39) |
| Contract and authorization suites | [document-generation-api #30](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/30), [professional-management-api #17](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/17) |
| Service allow-list (T2) | [document-generation-api #31](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/31) |
| Limits (T11) | [professional-management-api #41](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/41) |

---

## 7. Self-check

| # | Question | Answer |
|---|---|---|
| 1 | Threats concentrate at… | Trust boundaries (where data crosses trust levels) |
| 2 | STRIDE's "E" stands for… | Elevation of privilege |
| 3 | A security finding should become… | A prioritized story with a testable acceptance criterion |
| 4 | Repudiation is mitigated by… | Audit logs with a trace_id |
| 5 | Security testing in CI includes… | Dependency + secret scanning, SAST, authz tests (fail the build) |
| 6 | "We'll review security before launch" tends to… | Surface expensive, cross-cutting fixes too late |
