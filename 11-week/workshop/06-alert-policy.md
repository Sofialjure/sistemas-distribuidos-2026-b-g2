# Alert Policy — Generate Consultation Document

## Burn Rate Alerts

- **Fast:** a burn rate of 14.4 over a 1-hour window consumes `14.4 × (1 / 720) = 2%` of the 30-day Error Budget. It is confirmed for 5 minutes and has `critical` severity.
- **Slow:** a burn rate of 6 over a 6-hour window consumes `6 × (6 / 720) = 5%` of the 30-day Error Budget. It is confirmed for 30 minutes and has `warning` severity.

The fast alert detects severe degradation that requires an immediate response. The slow alert detects sustained deterioration before it exhausts the budget.

## Cause-Based Alerts We Will Not Create

- **CPU > 80%:** on its own, this does not indicate whether a patient can generate and retrieve a PDF; it may alert without visible impact or fail to alert when a dependency is slow.
- **Memory > 90%:** this percentage alone does not measure the generation result, request duration, or PDF availability.

Alerts will focus on user-outcome SLIs and burn rate. Resource metrics support diagnosis and capacity planning; they do not replace measuring the PDF generation experience.
