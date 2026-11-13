# Week 15 · Session 2 — files

Release of MVP 3 for Professional Management and Document Generation. The write-up is
[Optional Activity Week 15 - Session 2](../Optional%20Activity%20Week%2015%20-%20Session%202.md).

| Folder | Content |
|---|---|
| [`security/authz-probes.sh`](security/authz-probes.sh) | authentication and authorization probes of both services (gateway and platform network) |
| [`demo/demo-under-stress.sh`](demo/demo-under-stress.sh) | the demo: load on both lists + money path 1 + chaos 2 at the same time |
| [`results/`](results) | probes, gitleaks, the rollback rehearsal, the golden signals and the demo with its load tables |

The rollback rehearsal is `ReleaseRollbackIT` in
[`../session-1/integration-testcontainers`](../session-1/integration-testcontainers), next to the
other Testcontainers tests.

```bash
export ADMIN_EMAIL=... ADMIN_PASSWORD=...          # bootstrap administrator of identity
export NOTIFICATIONS_CLIENT_SECRET=...             # optional: the "another client" probe
bash security/authz-probes.sh
bash demo/demo-under-stress.sh                     # stops and starts document-generation-api
```
