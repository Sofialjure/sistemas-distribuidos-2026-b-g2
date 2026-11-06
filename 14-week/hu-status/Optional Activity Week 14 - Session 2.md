# OPTIONAL ACTIVITY — Week 14 · Session 2

## Planning — finalize the pipeline and slice the CI/CD stories for MVP 3

> **Task of the week:** map every DoD item to a blocking gate, enable branch protection on
> develop/qa/main, add path-filtered per-service pipelines + cross-service contract tests, and a
> smoke test. Slice the CI/CD stories for MVP 3.

This session finishes the pipeline of session 1 for Professional Management and Document
Generation. The contract tests and the smoke test were **run for real** on 2026-11-06 against the
images built from `develop` and the contracts on `telemed-ia-docs` `main`. Files:
[`session-2/`](session-2).

---

## 1. Every DoD item mapped to a gate

[`dod-gates.md`](session-2/dod-gates.md) takes each item of
`telemed-ia-docs/00-governance/definition-of-done.md` (code, tests, architecture, integration,
security, deployment, documentation) and names the gate that enforces it, whether it blocks, and
where it lives. Examples:

| DoD item | Gate |
|---|---|
| Linting, compilation and CI checks pass | `build-and-types`, `lint`, required check `gates` |
| Coverage does not decrease | `coverage-threshold` against the per-module baseline |
| Domain code does not depend on infrastructure | enforcer `bannedDependencies` in `-core` (fails the build) |
| Changes do not break integrations | each service's OpenAPI suite + the cross-service contract check |
| No secrets committed | gitleaks over the full history |
| Basic smoke tests pass | `image-and-smoke` on every PR and after every deployment |
| Reviewed and approved | approvals in the branch protection (1 on `develop`/`qa`, 3 with code owners on `main`) |

Items a machine cannot judge (business rules, ADRs, documentation quality) stay as review gates,
and an approval is blocking too. One item has no automated check yet (no access to another
domain's schema) and became story CICD-10.

## 2. Branch protection on `develop`, `qa` and `main`

Read through the GitHub API ([details](session-2/branch-protection/README.md)): all 18
branch/repository pairs require a PR and resolved conversations, but **none requires a status
check**, and `develop`/`qa` require **0 approvals**, which is how two of my docs PRs were merged
without a review. Proposed configuration ([`develop.json`](session-2/branch-protection/develop.json),
[`qa.json`](session-2/branch-protection/qa.json), [`main.json`](session-2/branch-protection/main.json)):

| | `develop` | `qa` | `main` |
|---|---|---|---|
| Required check | `gates` (up to date) | `gates` (up to date) | `gates` (up to date) |
| Approvals | 1 | 1 | 3 with code owners, after the last push |
| Linear history | no | yes (promotions with rebase) | yes |

[`apply.sh`](session-2/branch-protection/apply.sh) is a dry run by default; the organization
administrator applies it once the `gates` workflow exists in each repository (a required check
that never runs would block every PR).

## 3. Path-filtered per-service pipelines

| Workflow | Path filter | Runs |
|---|---|---|
| [`service-pipeline.yml`](session-2/workflows/service-pipeline.yml) (service repository) | `*-core/**`, `*-adapters/**`, `*-app/**`, `pom.xml` | every gate + contract check |
| | `deploy/**`, `.github/workflows/**` | image build + smoke test |
| | anything else (README, docs) | only `changes` and `pipeline` |
| [`docs-contract-tests.yml`](session-2/workflows/docs-contract-tests.yml) (`telemed-ia-docs`) | `document-service.yaml`, `professional-service.yaml`, `consultation-service.yaml`, `_shared.yaml`, their interactions | the contract check of **only** the services touched (matrix built from the filter) |

The required check `pipeline` passes when every needed job passed and the others were skipped by
the filter, so a README-only PR is not blocked waiting for a build. Both workflows pass
actionlint with 0 errors.

## 4. Cross-service contract tests

Each service already checks its own responses against its contract. The new check covers the
**seams**: [`capture.py`](session-2/contract-tests/capture.py) calls the deployed images as their
consumers do and records the interactions (tokens redacted), and
[`contract-check.py`](session-2/contract-tests/contract-check.py) validates them against the
provider's contract in `telemed-ia-docs`.

| Consumer → provider | Interactions | Result |
|---|---|---|
| `telemed-ia-worker` → document-service | `POST /generate` `201`, same key `200` | PASS |
| document portal → document-service | list `200`, detail `200`, download of a `PENDING` document `422` | PASS |
| professional portal → professional-service | list `200`, unknown `404`, status of unknown `404`, registration with identity down `503` | PASS |
| document-service → consultation-service | `GET /post-summaries/{id}` `200`, `GET /{id}/attention` `200` | **FAIL** |

**The failure is real:** `consultation-service.yaml` declares the bare object (and
`preconsultationSummaryId` as required), but `medical-consultation-api` wraps every answer in
`{"data": ...}` (`envelope.go`), which is what Document Generation reads. The contract and its
implementation disagree — exactly the drift these tests exist to catch. A mutation run (worker
request without `summaryId` and `Idempotency-Key`) fails with both problems named.
Output: [`results.txt`](session-2/contract-tests/results.txt).

## 5. Smoke test

[`smoke-test.sh`](session-2/smoke/smoke-test.sh): `/health` `200` and `UP`, protected path
`401` with the error envelope, `X-Correlation-Id` echoed, `200` with a valid token, management
health `200`, service metrics exposed. [`smoke-stack.sh`](session-2/smoke/smoke-stack.sh) runs it
in the PR job with only PostgreSQL and the migrations and a throwaway key pair.

| Image | After deploy by digest | `smoke-stack.sh` |
|---|---|---|
| document-generation-api `v0.14.0-rc.1` | 8 of 8 | 8 of 8 |
| professional-management-api `v0.14.0-rc.1` | 8 of 8 | 8 of 8 |

## 6. CI/CD stories for MVP 3

[`cicd-stories.md`](session-2/cicd-stories.md) — eleven stories in five slices, each one PR in
one repository, with criteria a pipeline run can prove:

| Slice | Stories | Priority |
|---|---|---|
| Make the gates real | CICD-01 gates in the four repositories, CICD-02 branch protection | P0 |
| Turn the red gates green | CICD-03 exhaustive switches, CICD-04 Java dependencies (45 → 26 measured with Spring Boot 3.5.16), CICD-05 portal audit | P0 |
| Release the tagged image | CICD-06 tag → GHCR → qa, CICD-07 automatic rollback | P1 |
| Contracts across services | CICD-08 interactions in docs + consultation contract fix, CICD-09 path filters | P1 |
| Hardening | CICD-10 no cross-schema access, CICD-11 adapters coverage | P2 |

## 7. Evidence

| Evidence | Link |
|---|---|
| DoD → gates | [`dod-gates.md`](session-2/dod-gates.md) |
| Branch protection: current state, proposal, dry-run script | [`branch-protection`](session-2/branch-protection) |
| Path-filtered workflows | [`workflows`](session-2/workflows) |
| Contract tests, interactions, results | [`contract-tests`](session-2/contract-tests/README.md) |
| Smoke test and its runs | [`smoke`](session-2/smoke/README.md) |
| Stories | [`cicd-stories.md`](session-2/cicd-stories.md) |

## 8. Self-check

- [x] Every DoD item has a gate or is explicitly a review gate.
- [x] Branch protection for the three permanent branches, with a required check and approvals.
- [x] Pipelines filtered by path, per service and per contract.
- [x] Cross-service contract tests with real interactions; one real drift found.
- [x] Smoke test run against both deployed images.
- [x] CI/CD stories sliced for MVP 3 with testable criteria.
