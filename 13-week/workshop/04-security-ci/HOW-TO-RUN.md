# How to run the security gates

## What it covers

| File | Covers |
|---|---|
| `GenerateDocumentAuthorizationTest.java` | Story [#149](https://github.com/code-corhuila/telemed-ia-docs/issues/149) (STRIDE S, risk 6), first criterion: a `SERVICE` token whose `sub` is not in `GENERATION_SERVICE_CLIENTS` gets `403` on `POST /api/documents/generate` |
| `security.yml` | gitleaks, OWASP dependency-check (fails on CVSS ≥ 7) and the negative authorization tests, on every pull request to `develop`, `qa` and `main` of `telemed-ia-document-generation-api` |

## Run the negative test locally

1. Copy the test to
   `telemed-ia-document-generation-api/document-generation-app/src/test/java/co/edu/corhuila/telemedia/documentgeneration/app/`.
2. Start the API (`deploy/compose.yml`) with `GENERATION_SERVICE_CLIENTS=worker`.
3. Get a token for another service client from `identity-and-access-api`
   (`POST /internal/service-token`, client `notifications`), or sign one with the development key
   (`role: SERVICE`, `sub: notifications`).
4. Run, with Java 21:

```bash
export DOC_API_URL=http://localhost:8080 OTHER_SERVICE_TOKEN=<token>
mvn -B -pl document-generation-app -am test -Dtest=GenerateDocumentAuthorizationTest -Dsurefire.failIfNoSpecifiedTests=false
```

Expected: `Tests run: 1, Failures: 0`. Without `OTHER_SERVICE_TOKEN` the test is skipped, not passed.

## Output (2026-10-29, local platform)

Run against `document-generation-api` built from `develop` (`GENERATION_SERVICE_CLIENTS` left at its
default, `worker`), on the platform Docker network, reached through a local port forward
(`127.0.0.1:18080` → `document-generation-api:8080`). Tokens signed with the development key
of that local platform: `role: SERVICE`, `sub: notifications` for the negative case.

Positive control first, so the `403` is not a broken token or a wrong URL:

```text
$ curl -X POST http://127.0.0.1:18080/api/documents/generate  (sub: notifications)
{"error":"FORBIDDEN","message":"the operation is not allowed for this user","traceId":"6c323983-fae5-4c37-bd2a-f3a0d69b054d"}  -> 403
$ curl -X POST http://127.0.0.1:18080/api/documents/generate  (sub: worker, same body)
{"id":"f8aa9846-2857-4431-b70e-9215bd8a73b2","summaryId":"e0000000-0000-4000-8000-00000000c8c8",...,"status":"PENDING","retryCount":0,...}  -> 201
```

The test:

```text
$ mvn -B -pl document-generation-app -am test -Dtest=GenerateDocumentAuthorizationTest -Dsurefire.failIfNoSpecifiedTests=false
[INFO] Running co.edu.corhuila.telemedia.documentgeneration.app.GenerateDocumentAuthorizationTest
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.951 s -- in co.edu.corhuila.telemedia.documentgeneration.app.GenerateDocumentAuthorizationTest
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

The test was copied into the API module only to run it; it is not committed to the team repository.

## Workflow validation

```text
$ docker run --rm -v "$PWD:/repo:ro" -w /repo rhysd/actionlint:1.7.7 -no-color -verbose security.yml
verbose: Linting security.yml
verbose: Found 0 parse errors in 0 ms for security.yml
verbose: Found total 0 errors in 15 ms for security.yml
```

actionlint 1.7.7: 0 errors. The workflow cannot run in the organization today because GitHub
Actions is blocked by the billing limit; the negative authorization test was run locally as shown above.
