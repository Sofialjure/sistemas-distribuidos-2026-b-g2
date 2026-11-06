"""Coverage gate: line coverage of each Maven module must not drop below its baseline.

Usage: python coverage-gate.py <repo-dir> <baseline.json> [--record]
Reads <module>/target/site/jacoco/jacoco.csv of every module. With --record it writes the
measured values (rounded down to one decimal) as the new baseline instead of checking.
"""
import csv, glob, json, math, os, sys

repo, baseline_path = sys.argv[1], sys.argv[2]
record = "--record" in sys.argv
name = os.path.basename(os.path.abspath(repo))
measured = {}
for path in sorted(glob.glob(os.path.join(repo, "*", "target", "site", "jacoco", "jacoco.csv"))):
    module = path.split(os.sep)[-5] if os.sep in path else path.split("/")[-5]
    covered = missed = 0
    with open(path, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            covered += int(row["LINE_COVERED"]); missed += int(row["LINE_MISSED"])
    if covered + missed:
        measured[module] = math.floor(1000 * covered / (covered + missed)) / 10
if not measured:
    sys.exit("no jacoco.csv found: run the tests with the JaCoCo agent first")
baseline = json.load(open(baseline_path, encoding="utf-8")) if os.path.exists(baseline_path) else {}
if record:
    baseline[name] = measured
    json.dump(baseline, open(baseline_path, "w", encoding="utf-8"), indent=2, sort_keys=True)
    print(f"recorded {name}: {measured}"); sys.exit(0)
failed = False
for module, value in measured.items():
    floor = baseline.get(name, {}).get(module)
    status = "no baseline" if floor is None else ("OK" if value >= floor else "BELOW")
    failed |= status == "BELOW"
    print(f"{module}: {value}% line coverage (baseline {floor}) {status}")
sys.exit(1 if failed else 0)
