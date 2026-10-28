# OPTIONAL ACTIVITY — Week 12 · Session 1

## Cloud deployment — models, strategies and zero-downtime

> **Task of the week:** deploy your system to a cloud environment (or a production-like host)
> using the tagged image, with a zero-downtime strategy (rolling or blue-green) and health checks.

The project has no cloud account (GitHub Actions and any paid resource are blocked by the
organization's billing limit), so the deployment was done on a **production-like host**: the
whole TeleMed IA platform running in containers on one Docker network (gateway, identity,
PostgreSQL, RabbitMQ, observability stack and the 28 repositories). On it I released a new
version of **`professional-management-api`** with a **blue-green** strategy, under continuous
authenticated traffic, and rehearsed the rollback. Everything below was executed on 2026-10-27.

---

## 1. Deployment model chosen and why

| Model | Fit for TeleMed IA |
|---|---|
| IaaS (bare VM) | Possible, but we would manage the OS, Java and the restart scripts by hand |
| **Containers on an orchestrator / container host** | **Chosen.** Every service already ships a `deploy/Dockerfile` and a `deploy/compose.yml`; the platform is declared in `telemed-ia-infra-postgres/compose.yml` |
| PaaS | Would hide the multi-service network (RabbitMQ, internal management ports) that we need |
| Serverless | The services are long-running (background PDF generation, outbox relays, consumers) |

---

## 2. Build once, deploy the artifact

| Version | Image | Built from |
|---|---|---|
| **blue** (live) | `professional-management-api:2848b52-blue` (image id `2848b525a73c`) | the image already running on the platform |
| **green** (new) | `professional-management-api:eeb08c7` (image id `4f5f9170f3af`) | `develop` at commit `eeb08c7`, built **once** with `deploy/Dockerfile` |

The tag is the commit, so the image that runs is traceable to the code that was reviewed. The
same image runs with different configuration per environment (`DB_URL`, `IDENTITY_URL`,
`JWT_PUBLIC_KEY`, service client credentials), injected at run time, never baked in.

---

## 3. Blue-green on the host

```
                      ┌─────────────── pm-lb (nginx, :28090) ───────────────┐
 continuous traffic → │ upstream professional_management → active.inc        │
 (admin token,        │ add_header X-Served-By <color> <image>                │
  GET every 50 ms)    └──────────────┬──────────────────────────┬────────────┘
                                     │                          │
                         pm-blue (2848b52)            pm-green (eeb08c7)
                         readiness: :9081/actuator/health (checks PostgreSQL)
                                     └──────── same PostgreSQL, identity ───────┘
```

- Both colors run side by side, with the same configuration, on the platform network.
- The front door is nginx. The active color is one include file (`active.inc`); switching is
  "copy `green.inc` over `active.inc`, `nginx -t`, `nginx -s reload`". A reload is graceful:
  old workers finish their in-flight requests, new workers use the new upstream.
- Every response carries `X-Served-By`, so each request records which version answered it.

### Health gate

The switch script refuses to move traffic unless the target color's container health is
`healthy`. Checking this gate found a real problem:

| Probe | With a wrong `DB_URL` |
|---|---|
| `GET /health` (public port) | `200 {"status":"UP"}`: only says the process is alive |
| `GET /actuator/health` (management port 9081) | `503 {"status":"DOWN"}`: includes the PostgreSQL check |

A gate on `/health` would have sent users to a version that cannot reach its database. The
**readiness** gate therefore uses `:9081/actuator/health`; `/health` stays the liveness check.

Negative test (a green started on purpose with an unreachable database):

```text
ABORT: pm-green-broken is unhealthy; no switch
before: X-Served-By: blue 2848b52 | after: X-Served-By: blue 2848b52
```

---

## 4. Release under traffic, and rollback rehearsal

Script `rollout.sh`: 15 s of traffic on blue → health gate → switch to green → 20 s → rollback
to blue → 15 s. The traffic is an authenticated `GET /api/professionals` every 50 ms with a real
administrator token issued by identity.

| Run | Requests | Non-200 | Served by blue / green | Switch to green | Rollback to blue | Latency p50 / p95 / max |
|---|---:|---:|---|---:|---:|---|
| 1 (liveness gate) | 239 | **0** | 143 / 96 | — | — | 0.045 / 0.079 / 0.847 s |
| 2 (liveness gate) | 230 | **0** | 145 / 85 | 2.31 s | 1.96 s | 0.035 / 0.097 / 0.304 s |
| 3 (readiness gate) | 277 | **0** | 167 / 110 | **1.61 s** | **1.35 s** | 0.030 / 0.051 / 0.561 s |

The switch time is measured from the start of the gate check until the front door answers
with the new color; it includes the `docker exec` round trips of the host.

**Result:** 746 requests across three releases and three rollbacks, **zero failed requests**.
The old version stayed running the whole time, so the rollback is the same one-file switch.

---

## 5. Scale out and expect failure

- The services are **stateless**: state lives in PostgreSQL (profiles, idempotency keys,
  outbox) and RustFS (PDFs), so more instances can run behind the same upstream.
- Idempotency keys are stored in the database, not in memory, so a retried `POST` that lands
  on another instance still returns the first result.
- The outbox relay of Document Generation claims rows with `FOR UPDATE SKIP LOCKED`, so two
  instances never publish the same event twice.
- A failed instance is detected by its health check and replaced; with the readiness gate it
  never receives traffic until it can reach its database.

---

## 6. Common mistakes avoided

| Mistake | Here |
|---|---|
| Rebuilding a different artifact for prod | One image per commit; the same image is promoted, only configuration changes |
| Stop-old-then-start-new | Blue keeps serving until green is ready; 0 failed requests |
| Manual, non-reproducible deploys | Containers, compose files and the rollout script are versioned and repeatable |
| Health check that lies | Readiness on the actuator (with the database), not on the liveness endpoint |

---

## 7. Evidence

| What | Where |
|---|---|
| Scripts and nginx configuration of the release | [scripts](scripts/README.md): `start.sh`, `rollout.sh`, `gate-test.sh`, `lb/` |
| Dockerfile and compose of the service | [professional-management-api #18](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/18), [#22](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/22), [#45](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/45) |
| Management port with health and metrics | [professional-management-api #48](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/48) |
| Released commit | [`eeb08c7`](https://github.com/code-corhuila/telemed-ia-professional-management-api/commit/eeb08c7) |
| Platform declared as code | [`telemed-ia-infra-postgres/compose.yml`](https://github.com/code-corhuila/telemed-ia-infra-postgres/blob/develop/compose.yml) |

### Appendix: the switch

```bash
switch() {  # health gate, then atomic swap of the active upstream and a graceful reload
  local color=$1
  [ "$(docker inspect -f '{{.State.Health.Status}}' pm-$color)" = healthy ] \
    || { echo "ABORT: pm-$color is not healthy"; return 1; }
  cp "lb/$color.inc" "lb/active.inc" && docker exec pm-lb nginx -t -q && docker exec pm-lb nginx -s reload
  until curl -s -D - -o /dev/null "$LB/health" | grep -q "X-Served-By: $color"; do sleep 0.05; done
}
```

```nginx
# green.inc — the only difference with blue.inc is the container and the label
upstream professional_management { server pm-green:8080; keepalive 16; }
map $host $served_by { default "green eeb08c7"; }
```

The containers run with
`--health-cmd "curl -fsS http://localhost:9081/actuator/health || exit 1" --health-interval 3s --health-retries 3`.

---

## 8. Self-check

| # | Question | Answer |
|---|---|---|
| 1 | Moving from IaaS toward serverless gives you… | More convenience, less control |
| 2 | "Build once, deploy the artifact" means… | Build the image in CI and run that same image in every environment |
| 3 | Blue-green deployment lets you… | Switch traffic to the new version and roll back instantly to the old |
| 4 | To handle load and failure you should… | Scale out (more instances) behind a load balancer with health checks |
| 5 | A manual SSH git pull deploy is problematic because… | It's not repeatable/reproducible and causes downtime/mistakes |
| 6 | Zero-downtime deployment strategies include… | Rolling, blue-green, canary |
