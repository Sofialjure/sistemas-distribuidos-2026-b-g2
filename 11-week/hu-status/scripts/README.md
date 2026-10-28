# Week 11 optional activities: scripts

The scripts used to collect the evidence of
[Session 1](../Optional%20Activity%20Week%2011%20-%20Session%201.md) and
[Session 2](../Optional%20Activity%20Week%2011%20-%20Session%202.md). They run against the
TeleMed IA platform started from `telemed-ia-infra-postgres` (Prometheus, Jaeger, gateway,
identity and both APIs in containers). No token, password or key is stored here: credentials
come from environment variables.

| Script | What it does | Used in |
|---|---|---|
| [`golden-signals.sh`](golden-signals.sh) | Instant PromQL queries for traffic, errors, p95 latency and saturation of both services | Session 1, section 2 |
| [`trace-summary.py`](trace-summary.py) | Reads the largest trace of a service from Jaeger and prints each span with its offset and duration | Session 1, section 3 |
| [`identity-down-drill.sh`](identity-down-drill.sh) | Stops identity for 150 s under registration traffic, then prints the 1h burn rate and the firing alerts | Session 2, drill |

```bash
./golden-signals.sh telemed-ia-prometheus
python trace-summary.py http://localhost:16686 telemed-ia-professional-management-api
ADMIN_EMAIL=admin@example.test ADMIN_PASSWORD=... ./identity-down-drill.sh http://127.0.0.1:8000
```

The drill stops a container on purpose: run it only on a local or throwaway platform.
