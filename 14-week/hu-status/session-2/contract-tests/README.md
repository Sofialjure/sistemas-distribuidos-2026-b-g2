# Cross-service contract tests

Each service already checks its **own** responses against its OpenAPI contract
(`DocumentServiceContractTest`, `ProfessionalServiceContractTest`). These tests check the
**seams between services**: what a consumer really sends or expects must match the provider's
contract in `telemed-ia-docs/07-api/contracts/openapi`.

| File | What it does |
|---|---|
| [`capture.py`](capture.py) | Calls the running services as their consumers do (same method, path and headers) and records each request and response; tokens are written as `Bearer <redacted>` |
| [`interactions/`](interactions) | The recorded interactions, one file per consumer → provider pair |
| [`contract-check.py`](contract-check.py) | Validates each interaction against the provider's contract: path and method exist, required headers are sent, request body, response status and response body follow the schemas (`$ref` across files resolved, OpenAPI 3.0 `nullable` supported). `--only <contract>` limits it to the contracts a PR touched |
| [`results.txt`](results.txt) | Output of the run of 2026-11-06 against `telemed-ia-docs` `main`, and of the mutation run |

## Interactions

| Consumer → provider | Source | Interactions |
|---|---|---|
| `telemed-ia-worker` → document-service | captured from the deployed image (`v0.14.0-rc.1`), as the worker calls it: `SERVICE` token, `Idempotency-Key` = event id, `X-Correlation-Id` | `POST /generate` → `201`, same key again → `200` |
| document portal → document-service | captured, patient token | list `200`, detail `200`, download of a `PENDING` document `422` |
| professional portal → professional-service | captured, administrator token | list `200`, unknown profile `404`, status of an unknown profile `404`, registration while identity is unreachable `503` |
| document-service → consultation-service | the responses `HttpConsultationSummaryReader` is tested against | `GET /post-summaries/{id}` `200`, `GET /{id}/attention` `200` |

## Result (2026-11-06)

**9 of 11 interactions pass; 2 fail, and the failure is real.** `consultation-service.yaml`
declares the post-summary and the attention as the bare object (with `preconsultationSummaryId`
required), but `medical-consultation-api` wraps every answer in `{"data": ...}`
(`internal/infrastructure/adapters/inbound/http/envelope.go`) and Document Generation reads it
that way. The contract and its implementation disagree; the owner of Medical Consultation
should declare the envelope in the contract (story CICD-08).

**Mutation check:** removing `summaryId` and `Idempotency-Key` from the worker's request makes
the check fail with both problems named, so a consumer drifting from the contract is caught.
