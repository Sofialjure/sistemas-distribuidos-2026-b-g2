# OPTIONAL ACTIVITY — Week 11 · Session 2

## Planning — SLIs, SLOs, error budgets and alerting

> **Task of the week:** define 2–3 SLOs (availability, latency, freshness) with windows, an
> error-budget policy, a symptom-based alert with owner + runbook, and one runbook for a likely
> incident. Slice these as observability stories with testable acceptance criteria.

This plan covers the two services I own in TeleMed IA. It is not only on paper: the SLOs are
computed by Prometheus, the alerts are loaded and unit-tested, the runbook sections are linked
from each alert, and the main alert was fired on purpose in a drill (section 6).

---

## 1. SLIs and SLOs (window: 30 days, rolling)

### Professional Management (who the professionals are; every role reads it)

| SLO | SLI (what is measured) | Objective |
|---|---|---|
| **Availability** | share of requests to `/api/professionals*` that do **not** answer 5xx. A `503` because identity could not create the account counts; a `4xx` is the caller's mistake and does not | **99.5%** |
| **Read latency** | share of reads (list and detail) answered within **500 ms** | **95%** |

### Document Generation (the patient's consultation PDF, generated in the background)

| SLO | SLI | Objective |
|---|---|---|
| **Availability** | share of requested documents that end `AVAILABLE` (not `ERROR`) | **99.5%** |
| **Latency** | share of generation attempts that finish within **2 s** | **95%** |
| **Freshness** | share of PDFs available within **60 s** of being requested (asynchronous flow) | **95%** |

Why these and not others: they are what a user feels. A patient feels "my PDF is not there"
(availability), "it took long" (freshness); an administrator feels "I cannot register" or "the
list is slow". CPU, memory or pod count are causes, not symptoms, so they have no SLO.

---

## 2. Error budget

```text
Professional Management, at ~5,000 requests/day:
  150,000 requests/month × 0.5%  = 750 failed requests/month
  as a full outage: 30 × 24 × 60 × 0.5% = 216 minutes/month

Document Generation, at ~1,000 documents/day:
  30,000 documents/month × 0.5% = 150 documents/month may end in ERROR
```

### Error budget policy (same for both services)

| Budget consumed | Action |
|---|---|
| 50% | New feature work pauses; the next sprint prioritises the causes of the failures |
| 75% | Functional changes freeze; only fixes and reliability work are merged |
| 100% | The whole team works on resilience until the budget recovers within the window |

The budget is a decision tool: while it is healthy we ship; when it burns we stabilise.

---

## 3. Alerting policy: symptoms, severity, owner, runbook

Burn rate = how many times faster than "allowed" the budget is being spent. Multi-window rules
page only when the burn is fast **and** sustained, which removes the noise of a single 500.

| Alert | Trigger (symptom) | Severity → route | Owner | Runbook |
|---|---|---|---|---|
| `ProfessionalManagementFastBurn` | burn rate > 14.4 over 1h, for 5 min (2% of the monthly budget per hour) | critical → `page` | `sofialjure` | `04-professional-service/runbook.md#alert-professionalmanagementfastburn` |
| `ProfessionalManagementSlowBurn` | burn rate > 6 over 6h, for 30 min (5% of the budget in 6 h) | warning → `ticket` | `sofialjure` | `…#alert-professionalmanagementslowburn` |
| `ProfessionalManagementSlowReads` | reads within 500 ms below 95% over 1h, for 15 min | warning → `ticket` | `sofialjure` | `…#alert-professionalmanagementslowreads` |
| `DocumentGenerationFastBurn` | burn rate > 14.4 over 1h, for 5 min | critical → `page` | `sofialjure` | `09-document-service/runbook.md` |
| `DocumentGenerationSlowBurn` | burn rate > 6 over 6h, for 30 min | warning → `ticket` | `sofialjure` | `09-document-service/runbook.md` |
| `DocumentGenerationSlowPdfs` | freshness below objective | warning → `ticket` | `sofialjure` | `09-document-service/runbook.md` |

Alertmanager groups by alert and team, routes `critical` to `page` and `warning` to `ticket`, and
**inhibits** the slow burn while the fast burn is firing (one incident, one page).

**No alert without an action:** every rule has `severity`, `owner`, `team` and `runbook_url`
labels, and a validation script fails the build if any of them is missing.

---

## 4. Runbook for the likely incident: "identity is down, registrations fail"

Short version of the section the `FastBurn` alert links to:

1. **Symptoms:** administrators get `503` when registering; the shell shows the portal error with
   its `traceId`.
2. **Confirm** (PromQL):
   ```promql
   sum by (status, uri) (rate(http_server_requests_seconds_count{application="professional-management-api",status=~"5.."}[5m]))
   sum by (outcome) (rate(professional_registrations_total{application="professional-management-api"}[5m]))
   ```
   `503` on `/admin/register` with `outcome="unavailable"` → identity. `500` or
   `outcome="failed"` → our bug: open the `traceId` in Jaeger.
3. **Mitigate, lowest risk first:** check `identity-api` and its service clients; reads keep
   working without names, registrations recover by themselves (the administrator retries with
   the same `Idempotency-Key`). Database errors → check PostgreSQL and the pool. Recent deploy →
   roll back (week 12).
4. **Escalate:** to the identity owner when identity is the cause; to the Tech Lead after
   30 minutes firing.
5. **Verify recovery:** 5xx back to zero for 15 minutes and the 1h burn rate below 1.

---

## 5. Observability stories with testable acceptance criteria

| Story | Acceptance criteria (Given / When / Then) | Status |
|---|---|---|
| **OBS-PM-01** Golden signals | Given any request, when it ends, then `http_server_requests_seconds` counts it with its status and duration (0.1–5 s buckets). Given Prometheus, when it scrapes the management port without a token, then it gets metrics; the public port does not serve them | Done (API #48) |
| **OBS-PM-02** One trace across services | Given a request with `traceparent`, then the service continues the trace and its log lines carry `traceId`/`spanId`; given a registration, the calls to identity carry the same trace | Done (API #48) |
| **OBS-PM-03** Domain events in the logs | Given a registration, then one line has `event` `professional.registration.*`; given any of those lines, then no name, e-mail, document, password or key appears; outcomes are counted by `outcome` | Done (API #50) |
| **OBS-PM-04** Burn-rate alerts with owner and runbook | Given 10% of requests answering 503 for an hour, then `FastBurn` fires after 5 min and `SlowBurn` after 30; given only 4xx, no burn alert fires; given < 95% fast reads for 15 min, `SlowReads` fires | Done (infra #30, `promtool test rules`) |
| **OBS-PM-05** Dashboard and runbook | Given Grafana, the `professional-management` dashboard shows availability, read latency, budget left, burn rate and outcomes, using the datasource variable; each alert opens its runbook section | Done (infra #30, docs #124/#125) |
| **OBS-DG-01..06** Document Generation | golden signals, trace, domain events, alerts, runbook, pause switch | Done (API #26–#29, infra #22–#25, docs #102–#105) |

The alert criteria are executable: `tests/prometheus/professional-management.test.yml` feeds
synthetic series to `promtool test rules` (outage → fires, only 4xx → silent, slow reads →
fires, fast reads → silent).

---

## 6. Drill: the alert was fired for real

On 2026-10-27, on the production-like platform, identity was stopped for 2.5 minutes while an
administrator kept registering professionals.

| Signal | Observed |
|---|---|
| Registrations | 642 answered `503`; nothing was stored (account and profile go together) |
| Reads | kept answering `200`, without names (graceful degradation) |
| 1h burn rate | reached **168** (page threshold 14.4) |
| `ProfessionalManagementFastBurn` | pending → **firing after 5 minutes** |
| Alertmanager | routed it to `page` |

**Lesson recorded:** a burst shorter than one scrape interval does not move the burn rate (a
counter seen for the first time already at its final value has no increase). The alerts are for
sustained failures; a short burst is visible in the logs and the counter.

---

## 7. Evidence

| What | Where |
|---|---|
| Script of the drill | [scripts/identity-down-drill.sh](scripts/identity-down-drill.sh) |
| SLOs, budget policy, alerts, stories and drill (Professional Management) | [telemed-ia-docs #125](https://github.com/code-corhuila/telemed-ia-docs/pull/125) |
| Runbook with one section per alert | [telemed-ia-docs #124](https://github.com/code-corhuila/telemed-ia-docs/pull/124), [#125](https://github.com/code-corhuila/telemed-ia-docs/pull/125) |
| Alert rules, `promtool` tests and dashboard | [infra-postgres #30](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/30) |
| Document Generation SLOs, alerts, Alertmanager, dashboard | [docs #102](https://github.com/code-corhuila/telemed-ia-docs/pull/102), [infra-postgres #22](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/22), [#24](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/24), [#25](https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/25) |

---

## 8. Self-check

| # | Question | Answer |
|---|---|---|
| 1 | An SLO is… | The target for an SLI (e.g. 99.5% success over 30 days) |
| 2 | The error budget is… | 100% − SLO: the allowed unreliability to spend on shipping |
| 3 | You should alert primarily on… | User-facing symptoms (error rate, p99 latency, SLO burn) |
| 4 | Every alert needs… | Trigger, severity, owner, and a runbook |
| 5 | A runbook provides… | A checklist to confirm, mitigate, escalate and verify an incident |
| 6 | Fifty low-value pages a night cause… | Alert fatigue → real incidents get missed |
