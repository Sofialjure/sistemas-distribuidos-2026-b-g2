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

## Output

Recorded in CP8.
