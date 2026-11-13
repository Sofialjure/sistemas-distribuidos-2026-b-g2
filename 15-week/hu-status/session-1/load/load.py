"""Open-loop stepped load test against the read SLO of my two services.

SLO (professional-service observability.md, the same objective for the document list):
  - availability: at least 99.5% of requests answer without a 5xx or a timeout;
  - latency: 95% of reads answer in under 500 ms.

Each step sends a fixed number of requests per second for STEP_SECONDS, whatever the service
does (open loop). Latency is measured from the moment the request was *scheduled*, so a slow
service cannot hide its queueing (coordinated omission). The knee is the first step where the
service misses the SLO or cannot keep up with the offered rate.

Usage (inside the platform network, so the gateway's per-IP limit does not cap the test):
  docker run --rm --network <net> -v <this dir>:/load -e TARGET=... -e TOKEN=... \
      python:3.12-alpine python /load/load.py
"""
import json
import os
import threading
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor

TARGET = os.environ["TARGET"]
TOKEN = os.environ["TOKEN"]
NAME = os.environ.get("NAME", TARGET)
STEPS = [int(x) for x in os.environ.get("STEPS", "10,25,50,100,150,200,300").split(",")]
STEP_SECONDS = int(os.environ.get("STEP_SECONDS", "20"))
TIMEOUT = float(os.environ.get("TIMEOUT", "5"))
SLO_P95_MS = 500
SLO_AVAILABILITY = 99.5


def one(scheduled, results, lock):
    request = urllib.request.Request(TARGET, headers={"Authorization": "Bearer " + TOKEN,
                                                      "X-Correlation-Id": "load-test"})
    status = 0
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            response.read()
            status = response.status
    except urllib.error.HTTPError as e:
        status = e.code
    except Exception:
        status = 0  # timeout or connection error
    elapsed = (time.perf_counter() - scheduled) * 1000
    with lock:
        results.append((status, elapsed))


def percentile(values, p):
    if not values:
        return float("nan")
    values = sorted(values)
    k = max(0, min(len(values) - 1, int(round(p / 100 * len(values) + 0.5)) - 1))
    return values[k]


def step(rate):
    results, lock = [], threading.Lock()
    total = rate * STEP_SECONDS
    interval = 1.0 / rate
    start = time.perf_counter()
    with ThreadPoolExecutor(max_workers=min(400, rate * 4)) as pool:
        for i in range(total):
            scheduled = start + i * interval
            delay = scheduled - time.perf_counter()
            if delay > 0:
                time.sleep(delay)
            pool.submit(one, scheduled, results, lock)
    duration = time.perf_counter() - start
    latencies = [ms for _, ms in results]
    failed = sum(1 for s, _ in results if s == 0 or s >= 500)
    other = sum(1 for s, _ in results if 0 < s < 500 and s != 200)
    availability = 100.0 * (len(results) - failed) / len(results)
    row = {
        "offered_rps": rate,
        "achieved_rps": round(len(results) / duration, 1),
        "requests": len(results),
        "p50_ms": round(percentile(latencies, 50), 1),
        "p95_ms": round(percentile(latencies, 95), 1),
        "p99_ms": round(percentile(latencies, 99), 1),
        "availability_pct": round(availability, 2),
        "non_200_below_500": other,
    }
    # any 4xx means the test itself is wrong (token, URL): the step is not valid evidence
    row["slo_met"] = other == 0 and row["p95_ms"] < SLO_P95_MS and availability >= SLO_AVAILABILITY
    return row


def other_invalid(row):
    return row["non_200_below_500"] > 0


def main():
    print(f"# {NAME}: {TARGET}  (steps of {STEP_SECONDS} s, SLO p95 < {SLO_P95_MS} ms and availability >= {SLO_AVAILABILITY}%)")
    print("| offered rps | achieved rps | requests | p50 ms | p95 ms | p99 ms | availability % | other non-200 | SLO |")
    print("|---|---|---|---|---|---|---|---|---|")
    rows, knee = [], None
    for rate in STEPS:
        row = step(rate)
        rows.append(row)
        print(f"| {row['offered_rps']} | {row['achieved_rps']} | {row['requests']} | {row['p50_ms']} | {row['p95_ms']} | "
              f"{row['p99_ms']} | {row['availability_pct']} | {row['non_200_below_500']} | {'met' if row['slo_met'] else ('INVALID' if row['non_200_below_500'] else 'MISSED')} |",
              flush=True)
        if other_invalid(row):
            raise SystemExit("4xx answers: fix the token or the URL before reading this run")
        if knee is None and not row["slo_met"]:
            knee = rate
            break  # past the knee the service only queues more
        time.sleep(3)
    last_ok = max((r["offered_rps"] for r in rows if r["slo_met"]), default=None)
    print(f"\nHighest step within the SLO: {last_ok} rps; knee: {knee if knee else 'not reached'}")
    with open(f"/load/results-{NAME}.json", "w") as f:
        json.dump({"target": TARGET, "rows": rows, "highest_within_slo": last_ok, "knee": knee}, f, indent=1)


if __name__ == "__main__":
    main()
