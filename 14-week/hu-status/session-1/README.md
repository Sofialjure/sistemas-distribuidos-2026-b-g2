# Week 14 · Session 1 — files

Main document: [Optional Activity Week 14 - Session 1](../Optional%20Activity%20Week%2014%20-%20Session%201.md).

| Folder | Content |
|---|---|
| [`workflows/`](workflows) | Reusable gates for Java services and Angular portals, the caller of each repository, the release of the tagged image, and the `actionlint.yaml` that declares the qa runner label |
| [`lint/`](lint) | Checkstyle and ESLint configurations of the lint gate |
| [`scripts/`](scripts) | `api-gates.sh` and `portal-gates.sh` (every gate locally, same commands as the jobs), the coverage gates and their baseline, and `deploy-tagged-image.sh` (local rehearsal of the release) |
| [`results/`](results/README.md) | Results of 2026-11-06: gate tables, dependency findings, release rehearsal logs |

## Run the gates locally

```bash
# Java service (export TEST_DATABASE_URL and, for Document Generation, TEST_STORAGE_* and TEST_RABBITMQ_URL)
bash scripts/api-gates.sh ../path/to/telemed-ia-document-generation-api ./out
# Angular portal
bash scripts/portal-gates.sh ../path/to/telemed-ia-document-generation-portal ./out
# Validate the workflows
docker run --rm -v "$PWD/workflows:/repo:ro" -w /repo rhysd/actionlint:1.7.7 -config-file actionlint.yaml *.yml
```
