# Week 11 Status - Delivery 1

**Project:** TeleMed IA
**Critical Journey:** Schedule Appointment

## Summary of Work Completed (CP0 to CP4)
- **CP0:** Setup of the workshop directory and reflection document.
- **CP1:** Mapped the distributed trace for the `Schedule Appointment` journey across `api-gateway`, `appointment-scheduling-api`, `professional-management-api`, and `notification-service`. Documented the trace context propagation.
- **CP2:** Defined the structured JSON log contract with standard and domain-specific fields (e.g., `appointment_id`, `patient_id`), including "never log" rules for PII.
- **CP3:** Implemented Node.js middleware and a structured logger. Added trace context propagation to downstream calls and exposed metrics. Automated test passed.
- **CP4:** Defined the Golden Signals metric catalog and Prometheus queries for `appointment-scheduling-api`, including cardinality rules and latency buckets.

## Commit History
*   CP0 Setup: `<PEGA_AQUI_EL_SHA>` (docs(w11): start observability workshop)
*   CP1 Journey: `<PEGA_AQUI_EL_SHA>` (docs(w11): map critical journey and trace propagation)
*   CP2 Logs: `<PEGA_AQUI_EL_SHA>` (docs(w11): define structured log contract)
*   CP3 Middleware: `<PEGA_AQUI_EL_SHA>` (feat(w11): add trace-context middleware and structured logger)
*   CP3 Propagation: `<PEGA_AQUI_EL_SHA>` (feat(w11): propagate context downstream and expose metrics)
*   CP4 Metrics: `<PEGA_AQUI_EL_SHA>` (docs(w11): define golden signals and metric catalog)

## Next Steps (Delivery 2)
- Define SLOs and Error Budget.
- Implement Burn-rate alerts.
- Write Runbook and Incident Postmortem.