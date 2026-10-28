"""Prints the spans of the largest trace of a service, read from the Jaeger query API.

Usage: python trace-summary.py <jaeger url> [service]
  e.g. python trace-summary.py http://localhost:16686 telemed-ia-professional-management-api
"""
import json
import sys
import urllib.parse
import urllib.request

base = sys.argv[1].rstrip("/")
service = sys.argv[2] if len(sys.argv) > 2 else "telemed-ia-professional-management-api"
query = urllib.parse.urlencode({"service": service, "limit": 200, "lookback": "12h"})
with urllib.request.urlopen(f"{base}/api/traces?{query}", timeout=15) as response:
    traces = json.load(response)["data"]

print("traces:", len(traces))
if not traces:
    sys.exit(0)
trace = max(traces, key=lambda t: len(t["spans"]))
root = min(trace["spans"], key=lambda s: s["startTime"])
print("trace", trace["traceID"], "spans", len(trace["spans"]))
for span in sorted(trace["spans"], key=lambda s: s["startTime"]):
    tags = {tag["key"]: tag["value"] for tag in span.get("tags", [])}
    target = tags.get("http.url") or tags.get("uri") or tags.get("http.route") or ""
    offset = (span["startTime"] - root["startTime"]) / 1000
    print(f'  {span["operationName"]:40} {offset:7.1f} ms +{span["duration"] / 1000:7.1f} ms  {target}')
