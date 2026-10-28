#!/bin/bash
# Reads the golden signals of Professional Management and Document Generation from Prometheus.
# Usage: golden-signals.sh [prometheus container]   (default: telemed-ia-prometheus)
PROM=${1:-telemed-ia-prometheus}
q() {  # q <PromQL>: prints each series of an instant query
  docker exec "$PROM" wget -qO- "http://localhost:9090/api/v1/query?query=$(python -I -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$1")" \
    | python -I -c 'import sys, json
for r in json.load(sys.stdin)["data"]["result"]:
    labels = ",".join(f"{k}={v}" for k, v in r["metric"].items() if k not in ("__name__", "job", "instance"))
    print("   =>", labels or "-", r["value"][1])'
}
S='application="professional-management-api",uri=~"/api/professionals.*"'
for query in \
  "sum(rate(http_server_requests_seconds_count{$S}[1h]))" \
  "sum(rate(http_server_requests_seconds_count{$S,status=~\"5..\"}[1h])) or vector(0)" \
  "histogram_quantile(0.95, sum by (le) (rate(http_server_requests_seconds_bucket{$S,method=\"GET\"}[1h])))" \
  "max(hikaricp_connections_active{application=\"professional-management-api\"})" \
  "max(hikaricp_connections_max{application=\"professional-management-api\"})" \
  "sum by (outcome) (professional_registrations_total)" \
  "sum(rate(http_server_requests_seconds_count{application=\"document-generation-api\"}[1h]))" \
  "sum by (outcome) (document_generation_attempts_total)"; do
  echo "$query"; q "$query"
done
