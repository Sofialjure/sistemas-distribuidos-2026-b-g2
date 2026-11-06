"""Coverage gate of a portal: line and branch coverage must not drop below the baseline.

Usage: python portal-coverage-gate.py <coverage-summary.json> <baseline.json> <portal> [--record]
"""
import json, math, os, sys

summary_path, baseline_path, portal = sys.argv[1], sys.argv[2], sys.argv[3]
total = json.load(open(summary_path, encoding="utf-8"))["total"]
measured = {k: math.floor(10 * total[k]["pct"]) / 10 for k in ("lines", "branches")}
baseline = json.load(open(baseline_path, encoding="utf-8")) if os.path.exists(baseline_path) else {}
if "--record" in sys.argv:
    baseline[portal] = measured
    json.dump(baseline, open(baseline_path, "w", encoding="utf-8"), indent=2, sort_keys=True)
    print(f"recorded {portal}: {measured}"); sys.exit(0)
floor = baseline.get(portal, {})
failed = [k for k, v in measured.items() if k in floor and v < floor[k]]
for k, v in measured.items():
    print(f"{k}: {v}% (baseline {floor.get(k)}) {'BELOW' if k in failed else 'OK'}")
sys.exit(1 if failed else 0)
