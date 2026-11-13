# Load test results - 2026-11-13 00:31 -0500

Machine: one laptop, 8 logical CPUs, every service of the platform running at the same time (Docker Desktop). Generator: load.py in python:3.12-alpine on the platform network, one process.

# professional-list: http://professional-management-api:8080/api/professionals?limit=20  (steps of 20 s, SLO p95 < 500 ms and availability >= 99.5%)
| offered rps | achieved rps | requests | p50 ms | p95 ms | p99 ms | availability % | other non-200 | SLO |
|---|---|---|---|---|---|---|---|---|
| 10 | 10.0 | 200 | 24.8 | 54.3 | 71.5 | 100.0 | 0 | met |
| 25 | 25.0 | 500 | 15.5 | 25.2 | 43.6 | 100.0 | 0 | met |
| 50 | 50.0 | 1000 | 11.2 | 19.7 | 31.0 | 100.0 | 0 | met |
| 100 | 100.0 | 2000 | 11.2 | 32.3 | 69.3 | 100.0 | 0 | met |
| 150 | 149.9 | 3000 | 9.7 | 30.7 | 58.5 | 100.0 | 0 | met |
| 200 | 199.8 | 4000 | 8.7 | 74.4 | 189.9 | 100.0 | 0 | met |
| 300 | 299.0 | 6000 | 10.9 | 102.5 | 163.8 | 100.0 | 0 | met |

Highest step within the SLO: 300 rps; knee: not reached

# professional-list-high: http://professional-management-api:8080/api/professionals?limit=20  (steps of 20 s, SLO p95 < 500 ms and availability >= 99.5%)
| offered rps | achieved rps | requests | p50 ms | p95 ms | p99 ms | availability % | other non-200 | SLO |
|---|---|---|---|---|---|---|---|---|
| 400 | 398.8 | 8000 | 1037.6 | 1548.8 | 1736.2 | 100.0 | 0 | MISSED |

Highest step within the SLO: None rps; knee: 400

# professional-list-knee: http://professional-management-api:8080/api/professionals?limit=20  (steps of 20 s, SLO p95 < 500 ms and availability >= 99.5%)
| offered rps | achieved rps | requests | p50 ms | p95 ms | p99 ms | availability % | other non-200 | SLO |
|---|---|---|---|---|---|---|---|---|
| 350 | 349.4 | 7000 | 11.7 | 490.3 | 644.8 | 100.0 | 0 | met |
| 400 | 398.3 | 8000 | 19.6 | 255.4 | 366.7 | 100.0 | 0 | met |

Highest step within the SLO: 400 rps; knee: not reached

# document-list: http://document-generation-api:8080/api/documents?limit=20  (steps of 20 s, SLO p95 < 500 ms and availability >= 99.5%)
| offered rps | achieved rps | requests | p50 ms | p95 ms | p99 ms | availability % | other non-200 | SLO |
|---|---|---|---|---|---|---|---|---|
| 10 | 10.0 | 200 | 5.3 | 9.8 | 28.0 | 100.0 | 0 | met |
| 50 | 50.0 | 1000 | 4.2 | 7.2 | 16.4 | 100.0 | 0 | met |
| 100 | 100.0 | 2000 | 3.4 | 5.4 | 9.4 | 100.0 | 0 | met |
| 200 | 199.9 | 4000 | 3.3 | 14.6 | 33.6 | 100.0 | 0 | met |
| 300 | 299.6 | 6000 | 3.0 | 6.2 | 17.1 | 100.0 | 0 | met |
| 400 | 399.2 | 8000 | 3.1 | 7.4 | 24.2 | 100.0 | 0 | met |
| 500 | 499.0 | 10000 | 3.4 | 31.2 | 58.5 | 100.0 | 0 | met |
Traceback (most recent call last):
  File "/load/load.py", line 119, in <module>
    main()
  File "/load/load.py", line 104, in main
    f"{row['p99_ms']} | {row['availability_pct']} | {row['non_200_below_500']} | {'met' if row['slo_met'] else ('INVALID' if other else 'MISSED')} |",
                                                                                                                             ^^^^^
NameError: name 'other' is not defined. Did you mean: 'iter'?

# document-list-high: http://document-generation-api:8080/api/documents?limit=20  (steps of 20 s, SLO p95 < 500 ms and availability >= 99.5%)
| offered rps | achieved rps | requests | p50 ms | p95 ms | p99 ms | availability % | other non-200 | SLO |
|---|---|---|---|---|---|---|---|---|
| 700 | 251.7 | 14000 | 27852.2 | 35762.3 | 36145.1 | 99.86 | 0 | MISSED |

Highest step within the SLO: None rps; knee: 700

## CPU during the knee steps of the professional list (docker stats, 3 samples)
```
s2-load 81.91%
s2-telemed-ia-professional-management-api-professional-management-api-1 129.79%
s2-telemed-ia-identity-and-access-api-identity-api-1 112.48%
s2-telemed-ia-postgres 54.33%
--
s2-load 71.71%
s2-telemed-ia-professional-management-api-professional-management-api-1 106.88%
s2-telemed-ia-identity-and-access-api-identity-api-1 83.70%
s2-telemed-ia-postgres 45.61%
--
s2-load 105.29%
s2-telemed-ia-professional-management-api-professional-management-api-1 153.70%
s2-telemed-ia-identity-and-access-api-identity-api-1 103.64%
s2-telemed-ia-postgres 70.79%
--
```

## Gateway per-IP limit (limit_req 20 r/s, burst 20)
through the gateway from one IP, 15 rps for 10 s: 200: 150
through the gateway from one IP, 60 rps for 10 s: 200: 219, 429: 381
