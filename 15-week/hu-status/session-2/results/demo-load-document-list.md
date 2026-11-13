# document-list: http://document-generation-api:8080/api/documents?limit=20  (steps of 90 s, SLO p95 < 500 ms and availability >= 99.5%)
| offered rps | achieved rps | requests | p50 ms | p95 ms | p99 ms | availability % | other non-200 | SLO |
|---|---|---|---|---|---|---|---|---|
| 100 | 89.4 | 9000 | 9893.7 | 18072.5 | 19084.1 | 24.88 | 0 | MISSED |

Highest step within the SLO: None rps; knee: 100
