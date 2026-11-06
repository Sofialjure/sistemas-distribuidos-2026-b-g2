# Definition of Done → blocking gates

Every item of [`telemed-ia-docs/00-governance/definition-of-done.md`](https://github.com/code-corhuila/telemed-ia-docs/blob/main/00-governance/definition-of-done.md)
mapped to the gate that enforces it in the pipelines of Professional Management and Document
Generation. **Blocking** means the merge button stays disabled until the gate is green: the
gate is a job of the required status check (`gates` / `pipeline`) or a branch protection rule.
Items that a machine cannot judge are kept as review gates (an approval is also blocking).

## Code

| DoD item | Gate | Blocking | Where |
|---|---|---|---|
| Satisfies the acceptance criteria | `tests-and-coverage` (each AC has an automated test) + reviewer | Yes | `java-service-gates.yml`, `angular-portal-gates.yml`; approvals in branch protection |
| Follows the conventions | `lint` (Checkstyle / ESLint), `build-and-types` (enforcer: Java 21, no framework in the core) | Yes | same workflows, [`../session-1/lint`](../session-1/lint) |
| Reviewed and approved (teacher + 2 members) | `required_approving_review_count` 1 on `develop`/`qa`, 3 with code owners on `main` | Yes | [`branch-protection`](branch-protection) |
| No unresolved conflicts | `strict: true` status checks (branch up to date) + Git | Yes | branch protection |
| Lint, format, compilation and CI checks pass | `build-and-types`, `lint`, the required check `gates` | Yes | workflows + branch protection |
| No unregistered technical debt | Reviewer checks the PR template item | Review | PR template |

## Tests

| DoD item | Gate | Blocking | Where |
|---|---|---|---|
| Unit tests for new logic | `tests-and-coverage` | Yes | Maven / Vitest |
| Integration tests when integrations change | `tests-and-coverage` with PostgreSQL, RustFS and RabbitMQ service containers (no skips: `TEST_*` are set) | Yes | `java-service-gates.yml` |
| All tests pass in CI | the required check `gates` | Yes | branch protection |
| Acceptance criteria verified | contract tests + smoke test | Yes | `contract`, `image-and-smoke` |
| Coverage does not decrease | `coverage-threshold` against the recorded baseline | Yes | [`coverage-gate.py`](../session-1/scripts/coverage-gate.py), [`portal-coverage-gate.py`](../session-1/scripts/portal-coverage-gate.py), [`coverage-baseline.json`](../session-1/scripts/coverage-baseline.json) |

## Architecture and domain

| DoD item | Gate | Blocking | Where |
|---|---|---|---|
| Hexagonal boundaries; domain without infrastructure | Maven enforcer `bannedDependencies` in the `-core` module (fails the build) | Yes | `build-and-types` |
| No access to another service's database | Each service connects with its own domain user, which only receives grants on its own schema; no automated check yet (story CICD-10) | Review | infra roles, approvals |
| Bounded context, business rules, ADRs | Reviewer | Review | approvals |

## Integration

| DoD item | Gate | Blocking | Where |
|---|---|---|---|
| Does not break APIs or integrations | `contract` (each service's own OpenAPI suite) + **cross-service contract check** of the recorded consumer interactions | Yes | `service-pipeline.yml`, `docs-contract-tests.yml`, [`contract-tests`](contract-tests) |
| OpenAPI updated when the API changes | contract tests fail when the code and `07-api/contracts/openapi` disagree | Yes | `DocumentServiceContractTest`, `ProfessionalServiceContractTest`, `contract-check.py` |
| `data-model.md`, `events.md`, catalogs updated | Reviewer (path filter flags the PR when `-db` or event code changes) | Review | approvals |

## Security

| DoD item | Gate | Blocking | Where |
|---|---|---|---|
| AuthN/AuthZ and ownership on the backend | HTTP and contract tests (`401`, `403`, other patient `403`) | Yes | `tests-and-coverage` |
| External input validated | HTTP tests of `400` with field `details` | Yes | `tests-and-coverage` |
| No secrets committed | `secrets` (gitleaks over the full history) | Yes | both workflows |
| Vulnerable dependencies | `dependencies` (trivy over the packaged jar; `npm audit` for the portals), HIGH/CRITICAL with a fix | Yes | both workflows |
| Sensitive data not exposed | Reviewer + tests that error bodies carry no SQL or stack trace | Yes (tests) | `tests-and-coverage` |

## Deployment

| DoD item | Gate | Blocking | Where |
|---|---|---|---|
| Integrates into `develop` without conflicts | `strict` checks | Yes | branch protection |
| Required CI checks green | `gates` / `pipeline` required | Yes | branch protection |
| Deployed to the validation environment | `release-image.yml`: tag → image scan → push → deploy by digest to `qa` (environment approval) | Yes | [`../session-1/workflows/release-image.yml`](../session-1/workflows/release-image.yml) |
| Basic smoke tests pass | `smoke-test.sh` after deploy and in `image-and-smoke` on every PR | Yes | [`smoke`](smoke) |
| A change that fails QA is fixed before `main` | `main` requires the same checks + 3 approvals; `qa` linear history | Yes | branch protection |

## Documentation

| DoD item | Gate | Blocking | Where |
|---|---|---|---|
| Docs, README, data model, events, ADR updated | Reviewer; the docs repository runs its own contract tests on every contract change | Review / Yes for contracts | `docs-contract-tests.yml` |
| Links valid, English | Reviewer | Review | approvals |
