# Smoke test

| File | What it does |
|---|---|
| [`smoke-test.sh`](smoke-test.sh) | Eight checks against a deployed service: `/health` `200` and `UP`; a protected path `401` with the error envelope; `X-Correlation-Id` echoed; the same path `200` with a valid token; management `/actuator/health` `200`; `/actuator/prometheus` exposes the service metrics |
| [`smoke-stack.sh`](smoke-stack.sh) | Used by the `image-and-smoke` job of every PR: starts the image with only PostgreSQL and the domain migrations on a throwaway network, mints a token with a throwaway key pair, runs `smoke-test.sh`, prints the application log if it fails, and removes everything |

## Runs (2026-11-06)

| Image | Where | Result |
|---|---|---|
| `telemed-ia-document-generation-api` `v0.14.0-rc.1` (`sha-396858c`) | after the release rehearsal, deployed by digest | 8 of 8 |
| `telemed-ia-professional-management-api` `v0.14.0-rc.1` (`sha-eeb08c7`) | after the release rehearsal, deployed by digest | 8 of 8 |
| both images | `smoke-stack.sh` (PR job) | 8 of 8 each — [Document Generation](results/smoke-stack-document-generation-api.log), [Professional Management](results/smoke-stack-professional-management-api.log) |

While writing `smoke-stack.sh` the first runs failed because the stack did not pass
`STORAGE_ENDPOINT`, `IDENTITY_URL` and `CONSULTATION_BASE_URL`, which Document Generation
requires at startup; the script now prints the application log when the smoke test fails, so
that kind of failure is visible in the job output.
