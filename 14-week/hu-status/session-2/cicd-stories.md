# CI/CD stories for MVP 3 — Professional Management and Document Generation

Sliced so each story is one PR of at most 400 lines in one repository, with acceptance
criteria that a pipeline run can prove. Priority: **P0** blocks the MVP 3 release, **P1** is
needed before `main`, **P2** follows. The findings come from the gate runs of 2026-11-06
([results](../session-1/results/README.md)).

## Slice 1 — Make the gates real (P0)

**CICD-01 · Blocking PR gates in the four code repositories**
As a reviewer, I want every PR to run build, types, lint, tests with coverage, secret scan and
dependency scan as blocking jobs, so that a red gate cannot be merged.
- [ ] `java-service-gates.yml` / `angular-portal-gates.yml` and their callers are in `.github/workflows` of each repository, with the lint configuration, coverage scripts and baseline in `.github`.
- [ ] A PR that adds an unused import fails `lint`; a PR that deletes a test so coverage drops fails `coverage-threshold`; a PR that commits a fake AWS key fails `secrets` (three throwaway PRs, linked).
- [ ] Integration tests run with `TEST_DATABASE_URL` set: the test report shows 0 skipped.

**CICD-02 · Branch protection with the required check**
As the team, I want `develop`, `qa` and `main` to require the `gates` check and approvals, so that the DoD is enforced by GitHub and not by memory.
- [ ] `branch-protection/*.json` applied to the six repositories by an organization administrator (`apply.sh --apply`).
- [ ] `gh api .../branches/develop/protection` shows `required_status_checks.checks = [gates]`, `strict: true`, 1 approval; `main` shows 3 approvals with code owners.
- [ ] A PR with a red `gates` shows the merge button disabled (screenshot).

## Slice 2 — Turn the red gates green (P0)

**CICD-03 · Exhaustive switches in Document Generation**
- [ ] `BackgroundPdfGenerator.logOutcome` and `JdbcPendingEvents.publishOldest` use switch expressions; `lint` passes with 0 violations.
- [ ] Adding a value to `GenerationAttempt` or `Outcome.Status` without handling it fails compilation (unit test or compile check documented in the PR).

**CICD-04 · Patch the Java dependencies of both APIs**
- [ ] Spring Boot parent 3.5.16 (measured: 45 → 26 in Document Generation) plus explicit versions for amqp-client, minio, bouncycastle, guava, snappy, Jackson, Tomcat and the PostgreSQL driver.
- [ ] `dependencies` passes, or the only remaining findings (spring-webmvc CVEs fixed only in Spring 7) are in `.trivyignore` with the CVE, the reason and an expiry date reviewed by the team.
- [ ] The full test suites stay green (338 and 181 tests, 0 skipped).

**CICD-05 · Portal dependency audit**
- [ ] `npm audit --omit=dev --audit-level=high` passes in both portals (upgrade `@angular-architects/native-federation` or override `vite` / `webpack-dev-server`), with `npm run build` and the tests green.

## Slice 3 — Release the tagged image (P1)

**CICD-06 · Tag → scanned image in GHCR → qa**
As the release owner, I want a tag `vX.Y.Z` on `main` to build, scan, push and deploy exactly one image, so that `qa` runs what was tested.
- [ ] `release-image.yml` in both API repositories; `deploy/compose.yml` reads the image from `IMAGE_REF`.
- [ ] Tag `v0.14.0`: the image `ghcr.io/code-corhuila/<repo>:v0.14.0` exists with its `sha-` tag; the `qa` environment requires an approval; the deployed container runs the pushed digest.
- [ ] The smoke test passes 8 of 8 against `qa`; a tag from a branch other than `main` is rejected.

**CICD-07 · Automatic rollback**
- [ ] If the smoke test fails after a deployment, the previous digest is redeployed and the job fails with the smoke output; rehearsed with an image whose `/health` answers `503`.

## Slice 4 — Contracts across services (P1)

**CICD-08 · Recorded interactions in the docs repository**
- [ ] `contract-check.py` and the interactions of the worker, both portals and Document Generation → Consultation live in `telemed-ia-docs/07-api/contracts/interactions`; `docs-contract-tests.yml` runs only the contracts a PR touches.
- [ ] Every service PR checks its consumers' interactions against docs `main` (`contract` job of `service-pipeline.yml`).
- [ ] The current drift is resolved by its owner: `consultation-service.yaml` declares the `{data}` envelope and the optional `preconsultationSummaryId` that the service returns, and the check passes.

**CICD-09 · Path-filtered pipelines**
- [ ] A README-only PR runs `changes` and `pipeline` in under a minute; a `deploy/` PR runs `image-and-smoke`; a code PR runs everything (three PRs linked).

## Slice 5 — Hardening (P2)

**CICD-10 · No cross-schema access** — the `-db` CI fails if the domain user can read another domain's schema (`SELECT` on a table of another schema returns `permission denied`).

**CICD-11 · Coverage of the Professional Management adapters** — raise `professional-management-adapters` from 52.8 % lines and record the new baseline.
