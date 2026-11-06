# Gate results — 2026-11-06

Every gate of [`../workflows`](../workflows) was run locally with the same commands
([`../scripts`](../scripts)), on fresh clones of `develop`, because GitHub Actions cannot run in
the organization (billing limit). Integration tests ran against PostgreSQL 16 with the
domain migrations, RustFS 1.0.3 and RabbitMQ 3.12, as the CI service containers would.

## Document Generation API (`develop` 396858c)

| Gate | Result | Detail |
|---|---|---|
| build-and-types | PASS | `mvn -B -DskipTests test-compile` (javac, enforcer: Java 21, no framework in the core) |
| lint | **FAIL** | 2 Checkstyle violations: `MissingSwitchDefault` in `BackgroundPdfGenerator.java:195` and `JdbcPendingEvents.java:40` |
| tests-and-coverage | PASS | 338 tests (84 core, 193 adapters, 61 app), 0 failures, 0 skipped |
| coverage-threshold | PASS | lines: core 96.2 %, adapters 94.8 %, app 87.3 % (recorded as the baseline) |
| secrets | PASS | gitleaks over 339 commits, no leaks |
| dependencies | **FAIL** | 45 HIGH/CRITICAL with a fix in the packaged jar (11 CRITICAL) — [table](dependencies-document-generation-api.md) |

## Professional Management API (`develop` eeb08c7)

| Gate | Result | Detail |
|---|---|---|
| build-and-types | PASS | `mvn -B -DskipTests test-compile` |
| lint | PASS | no Checkstyle violations |
| tests-and-coverage | PASS | 181 tests (32 core, 55 adapters, 94 app), 0 failures, 0 skipped |
| coverage-threshold | PASS | lines: core 93.2 %, adapters 52.8 %, app 90.7 % (baseline) |
| secrets | PASS | gitleaks over 359 commits, no leaks |
| dependencies | **FAIL** | 35 HIGH/CRITICAL with a fix in the packaged jar (9 CRITICAL) — [table](dependencies-professional-management-api.md) |

## Document Generation portal (`develop` a32f379)

| Gate | Result | Detail |
|---|---|---|
| types | PASS | `tsc --noEmit` for the app and the specs |
| lint | PASS | ESLint (typescript-eslint + angular-eslint, templates and accessibility), 0 problems |
| tests-and-coverage | PASS | 26 tests; lines 93.6 %, branches 84.6 % (baseline) |
| build | PASS | federated remote |
| dependencies | **FAIL** | `npm audit --omit=dev`: 6 high (17 in total) in `vite`, `webpack-dev-server` and `launch-editor`, pulled by `@angular-architects/native-federation` |
| secrets | PASS | gitleaks over 110 commits, no leaks |

## Professional Management portal (`develop` 9b2c3a0)

| Gate | Result | Detail |
|---|---|---|
| types | PASS | `tsc --noEmit` |
| lint | PASS | 0 problems |
| tests-and-coverage | PASS | 42 tests; lines 97.6 %, branches 90.5 % (baseline) |
| build | PASS | federated remote |
| dependencies | **FAIL** | same 6 high as the document portal (same dependency tree) |
| secrets | PASS | gitleaks over 90 commits, no leaks |

## What the failing gates found

- **Lint:** both switches cover every value of their enum today, but they are statements, so a
  new value would be skipped silently. Fix: turn them into switch expressions (the compiler then
  checks that every value is handled).
- **Dependencies of the APIs:** most come from the Spring Boot 3.5.6 set (Tomcat 10.1.46,
  Jackson 2.19.2, spring-webmvc 6.2.11, PostgreSQL driver 42.7.7). Raising only the parent to
  Spring Boot 3.5.16 in a scratch build of Document Generation lowered 45 to 26
  ([table](dependencies-document-generation-api-after-boot-3.5.16.md)); the rest need explicit
  versions (amqp-client 5.34, minio 8.6, bouncycastle 1.85, guava 33.7, snappy 1.1.10.9,
  Jackson 2.21.7, Tomcat 10.1.59, PostgreSQL 42.7.12), and two CRITICAL of spring-webmvc are
  fixed only in Spring 7 (Spring Boot 4).
- **Why the jar and not `pom.xml`:** `trivy fs` over the poms gave a different result on each
  run (it resolves every parent pom over the network and skipped modules silently); the
  packaged jar gave the same 45 on two runs.

## Release of the tagged image (rehearsal)

[`../scripts/deploy-tagged-image.sh`](../scripts/deploy-tagged-image.sh) ran the steps of
[`release-image.yml`](../workflows/release-image.yml) for `v0.14.0-rc.1` of both APIs, with a
local registry in place of GHCR:

| Step | Document Generation | Professional Management |
|---|---|---|
| Build | `sha-396858c` | `sha-eeb08c7` |
| Image scan | **FAIL** (ubuntu 22.04: 2 HIGH; jar: 45) — the release stops here | **FAIL** — the release stops here |
| Push, deploy by digest, smoke test (run with `--scan-report-only` to rehearse them) | 8 of 8 smoke checks passed | 8 of 8 smoke checks passed |

Logs: [Document Generation](release-rehearsal-document-generation-api.log),
[Professional Management](release-rehearsal-professional-management-api.log).
