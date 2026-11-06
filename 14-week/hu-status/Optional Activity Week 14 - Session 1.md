# OPTIONAL ACTIVITY — Week 14 · Session 1

## CI/CD — blocking gates on every PR and deployment of the tagged image

> **Task of the week:** set up your CI/CD: PRs run build + lint + type + tests + coverage +
> security as blocking gates; protect main; automate deployment of the tagged image.

This activity builds the pipelines of the four code repositories I own
(`document-generation-api`, `professional-management-api` and their two portals) and **runs
every gate for real** on fresh clones of `develop`. GitHub Actions cannot run in the
organization (billing limit), so each gate was executed locally with the exact commands of its
job, with the same service containers (PostgreSQL 16 with the domain migrations, RustFS,
RabbitMQ). Executed on 2026-11-06. Files: [`session-1/`](session-1).

---

## 1. From PR to deployment

```
PR to develop/qa/main
  ├─ build-and-types ─┐
  ├─ lint ────────────┤
  ├─ tests + coverage ┼─► gates  (the one required status check)  ─► merge allowed
  ├─ secrets ─────────┤
  └─ dependencies ────┘

tag vX.Y.Z on main ─► build image ─► image scan ─► push to GHCR (tag + sha) ─► deploy to qa by digest ─► smoke test
```

Every gate is its own job, so one run reports every problem at once; the final job `gates`
fails if any of them failed, and it is the only check the branch protection has to require.

## 2. The gates

| Gate | Java services ([`java-service-gates.yml`](session-1/workflows/java-service-gates.yml)) | Angular portals ([`angular-portal-gates.yml`](session-1/workflows/angular-portal-gates.yml)) |
|---|---|---|
| Build | `mvn test-compile`; the enforcer requires Java 21 and bans frameworks in `-core` | `npm run build` (federated remote) |
| Types | `javac` (part of the build) | `tsc --noEmit` for the app and the specs |
| Lint | Checkstyle with defect rules ([`checkstyle.xml`](session-1/lint/checkstyle.xml)) | ESLint: typescript-eslint, angular-eslint, template accessibility ([`eslint.config.mjs`](session-1/lint/eslint.config.mjs)) |
| Tests | unit, HTTP, contract and integration, with PostgreSQL, RustFS and RabbitMQ service containers and the `-db` migrations applied as infra does | Vitest |
| Coverage | JaCoCo; [`coverage-gate.py`](session-1/scripts/coverage-gate.py) fails if any module drops below its [baseline](session-1/scripts/coverage-baseline.json) | Vitest coverage; [`portal-coverage-gate.py`](session-1/scripts/portal-coverage-gate.py) on lines and branches |
| Security | gitleaks over the full history; trivy over the **packaged jar**, HIGH/CRITICAL with a fix | gitleaks; `npm audit --omit=dev --audit-level=high` |

Callers per repository: [Document Generation API](session-1/workflows/document-generation-api.ci.yml),
[Professional Management API](session-1/workflows/professional-management-api.ci.yml),
[portals](session-1/workflows/portal.ci.yml). All six workflows pass **actionlint 1.7.7 with 0
errors** (shellcheck included).

The test job migrates the domain schema the way `telemed-ia-infra-postgres` does (schema owned
by the application user, `search_path`, roles with `ADMIN OPTION`). I ran that step on a clean
PostgreSQL first: without the schema and the `ADMIN OPTION` Liquibase fails with `permission
denied for schema public`; with them it applies 17 changesets (Document Generation) and 36
(Professional Management).

## 3. Results on `develop`

| Repository | Build | Types | Lint | Tests | Coverage | Secrets | Dependencies |
|---|---|---|---|---|---|---|---|
| document-generation-api | PASS | PASS | **FAIL** (2) | PASS — 338, 0 skipped | PASS (core 96.2 %, adapters 94.8 %, app 87.3 %) | PASS (339 commits) | **FAIL** — 45 (11 CRITICAL) |
| professional-management-api | PASS | PASS | PASS | PASS — 181, 0 skipped | PASS (core 93.2 %, adapters 52.8 %, app 90.7 %) | PASS (359 commits) | **FAIL** — 35 (9 CRITICAL) |
| document-generation-portal | PASS | PASS | PASS | PASS — 26 | PASS (lines 93.6 %, branches 84.6 %) | PASS (110 commits) | **FAIL** — 6 high |
| professional-management-portal | PASS | PASS | PASS | PASS — 42 | PASS (lines 97.6 %, branches 90.5 %) | PASS (90 commits) | **FAIL** — 6 high |

Details: [`session-1/results`](session-1/results/README.md).

## 4. What the red gates found

- **Lint (Document Generation):** two `switch` statements over an enum without `default`
  (`BackgroundPdfGenerator.java:195`, `JdbcPendingEvents.java:40`). They cover every value
  today, but a new value would be skipped silently; as switch expressions the compiler would
  require it.
- **Java dependencies:** most come from the Spring Boot 3.5.6 set (Tomcat 10.1.46, Jackson
  2.19.2, spring-webmvc 6.2.11, PostgreSQL driver 42.7.7). In a scratch build, Spring Boot
  3.5.16 alone lowered Document Generation from 45 to 26; the rest need explicit versions, and
  two CRITICAL of spring-webmvc are fixed only in Spring 7 (Spring Boot 4) —
  [before](session-1/results/dependencies-document-generation-api.md),
  [after](session-1/results/dependencies-document-generation-api-after-boot-3.5.16.md).
- **Scanning the jar, not the poms:** `trivy fs` over the poms gave a different result on each
  run because it resolves the parent poms over the network and skipped modules silently; the
  packaged jar gave the same 45 on two runs, so the gate scans the jar.
- **Portals:** the 6 high findings (`vite`, `webpack-dev-server`, `launch-editor`) arrive through
  `@angular-architects/native-federation`, a runtime dependency that pulls the Angular build
  tools; they are not in the static files nginx serves, but the gate is right to flag them.

These are recorded as stories in session 2 ([`cicd-stories.md`](session-2/cicd-stories.md)),
not fixed here: the activity sets up the gates; the fixes go through PRs of the team
repositories.

## 5. Protect `main`

The current protection of the six repositories was read through the GitHub API: `main`
requires a PR, 1 approval with code owners and resolved conversations, but **no status check**,
so a red pipeline would not block it. The proposal (required `gates`, 3 approvals with code
owners and approval after the last push, linear history) is in
[`session-2/branch-protection`](session-2/branch-protection/README.md) with a dry-run script;
changing protection rules is done by the organization administrator.

## 6. Deployment of the tagged image

[`release-image.yml`](session-1/workflows/release-image.yml): a tag `vX.Y.Z` that is on `main`
builds the image once, blocks on the image scan, pushes `:vX.Y.Z` and `:sha-<commit>` to GHCR,
and deploys **the scanned digest** to the `qa` environment (approval required, self-hosted
runner), followed by the smoke test.

Rehearsal with a local registry ([`deploy-tagged-image.sh`](session-1/scripts/deploy-tagged-image.sh)),
tag `v0.14.0-rc.1` of both APIs:

| Step | Document Generation | Professional Management |
|---|---|---|
| Build | `sha-396858c` | `sha-eeb08c7` |
| Image scan | **FAIL** — the release stops here (jar: 45, ubuntu 22.04: 2 HIGH) | **FAIL** — the release stops here |
| Push, deploy by digest, smoke (rehearsed with `--scan-report-only`) | 8 of 8 | 8 of 8 |

So today the pipeline would **refuse to release** both services, which is the correct outcome
until CICD-04 lands.

## 7. Evidence

| Evidence | Link |
|---|---|
| Workflows (6, actionlint 0 errors) | [`session-1/workflows`](session-1/workflows) |
| Lint configurations | [`session-1/lint`](session-1/lint) |
| Gate scripts and coverage baseline | [`session-1/scripts`](session-1/scripts) |
| Gate results, dependency tables, release logs | [`session-1/results`](session-1/results/README.md) |

## 8. Self-check

- [x] Build, lint, types, tests, coverage and security run on every PR as separate blocking jobs.
- [x] One required status check (`gates`) that fails if any gate failed.
- [x] Integration tests run against real engines in CI (no skipped tests).
- [x] Coverage cannot drop: per-module baseline from today's run.
- [x] Secrets and vulnerable dependencies block the PR and the release.
- [x] The release deploys the exact digest that was scanned, and smoke tests it.
- [x] Every gate was executed; the red ones are reported with their cause, not hidden.
