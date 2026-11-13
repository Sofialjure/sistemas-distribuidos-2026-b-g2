# Week 15 · Session 1 — files

Testing at scale for Professional Management and Document Generation. The write-up is
[Optional Activity Week 15 - Session 1](../Optional%20Activity%20Week%2015%20-%20Session%201.md).

| Folder | Content |
|---|---|
| [`integration-testcontainers/`](integration-testcontainers) | Testcontainers tests of the two `-db` repositories (session 1) and the rollback rehearsal of release 3.0.0 (session 2) |
| [`ci/`](ci) | the contract job: drift check against `telemed-ia-docs` + contract suite |
| [`e2e/`](e2e) | the two money-path tests and their helpers |
| [`load/`](load) | the open-loop stepped load test |
| [`chaos/`](chaos) | the three chaos experiments |
| [`results/`](results) | the logs and tables of the runs of 2026-11-12/13 |

## How to run

The scripts expect the whole platform running (see `10-devops/local-setup.md` of
`telemed-ia-docs`). Their defaults point to the isolated copy I used (gateway on
`127.0.0.1:38000`, network `tsw2`, containers prefixed `s2-`); every name can be changed with an
environment variable. No secret is stored here: the administrator's credentials and any client
secret are passed in the environment.

```bash
# Testcontainers (Java 21, Docker running)
cd integration-testcontainers
mvn -B test -Dpm.db.repo=<telemed-ia-professional-management-db> -Ddg.db.repo=<telemed-ia-document-generation-db> \
            -Dpm.db.main=<the same repo at main> -Ddg.db.main=<the same repo at main>

# money paths and chaos (bash, curl, python, docker)
export ADMIN_EMAIL=... ADMIN_PASSWORD=...
bash e2e/money-path-1-onboarding.sh
bash e2e/money-path-2-consultation-pdf.sh
bash chaos/chaos-1-identity-down.sh      # stops and starts identity
bash chaos/chaos-2-document-api-down.sh  # stops and starts document-generation-api
bash chaos/chaos-3-broker-down.sh        # stops and starts RabbitMQ

# load (inside the platform network: the gateway allows 20 r/s per IP)
docker run --rm --network <net> -v "$PWD/load:/load" -e NAME=professional-list \
  -e TARGET="http://professional-management-api:8080/api/professionals?limit=20" -e TOKEN=<admin token> \
  python:3.12-alpine python /load/load.py
```
