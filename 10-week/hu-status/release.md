# Release Registry — Cut 2

Registry of the versions (tags) published in the repositories of the
TeleMed IA project (Group G2, CORHUILA, Distributed Systems 2026-B).

**Cut-off date:** 2026-10-13
**Current release versions:** 19 (one per repository with a current tag)
**Published tag records listed:** 21 (includes 2 superseded tags below)
**Repositories with at least one published release:** 19
**Repositories pending a first published tag:** 11

---

## Cross-cutting

| Repository | Tag | Commit SHA |
|---|---|---|
| telemed-ia-api-gateway | v2.0.0 | 8c146f77e0a4136d71af3b9c6aca860b4fd9a008 |
| telemed-ia-front | v2.0.0 | b4a55a203227f01b03ba2704fe7387745c3bac17 |
| telemed-ia-infra-mongo | v2.0.0 | b68ea036712b292c64595cd1065eec9c681c99d1 |
| telemed-ia-infra-postgres | v2.1.0 | 23afaa076b3f3ce6f822ae2acc8a42a675648610 |

---

## Domains

| Repository | Tag | Commit SHA |
|---|---|---|
| telemed-ia-appointment-scheduling-api | v2.0.0 | a13c7511568bb066069c755640340c9f3d5b29c9 |
| telemed-ia-appointment-scheduling-db | v2.0.0 | faff89dcf70486838c4c140249c96bb76babb8d0 |
| telemed-ia-appointment-scheduling-portal | v2.0.1 | 37c06ea9071ede3d4602d0afb08fae2536830824 |
| telemed-ia-document-generation-db | v2.0.0 | b165e89f2493a89e0df151a07d57149784324601 |
| telemed-ia-document-generation-portal | v2.0.0 | 23552e430d99574ed0569504594e0638e568d111 |
| telemed-ia-identity-and-access-db | v2.0.0 | fa9c51cb1ef60623c26eebcc4f5df0f90c92d2f6 |
| telemed-ia-intelligent-agent-db | v2.0.0 | 6df4011587b5bd4edda70dffc52ec1771d7f93e7 |
| telemed-ia-intelligent-agent-portal | v2.0.0 | f07b3b008e751dc67528c4fca7bcfe4ba731e5c2 |
| telemed-ia-medical-consultation-api | v2.0.0 | f9f0f00641ca8875fd8ebb46b0ad8fd58e88aa24 |
| telemed-ia-medical-consultation-db | v2.0.0 | 9cc6b65323a8d2eb7afe4fa390c8cf8ac3bd2577 |
| telemed-ia-medical-consultation-portal | v2.0.0 | b213468b89d7f8b68c673403b595e8c64bfe28af |
| telemed-ia-patient-management-api | v2.0.0 | 42de57ccac34d6d2649a8d961d1048306655f030 |
| telemed-ia-patient-management-db | v2.0.0 | 4700209af4292bc7f44a7ed4af74aef8caf63751 |
| telemed-ia-professional-management-db | v2.0.0 | cc6a415eb8a913ff31a76e77e405891e3ebcd005 |
| telemed-ia-patient-management-portal | v2.0.0 | 00729ac5ee57d3ba0149205f2b14db7cdf4bcb3e |

---

## Historical and superseded tags

These tags remain part of the published release history but are not the current version for their repository in this cut.

| Repository | Tag | Commit SHA | Status |
|---|---|---|---|
| telemed-ia-appointment-scheduling-portal | v2.0.0 | 5912cc1787b0d89ec9c20e96ecf089fd7a69e0b3 | Superseded by v2.0.1 |
| telemed-ia-infra-postgres | v2.0.0 | 7720c82a06c31488415159511bea54e0cdb01219 | Superseded by v2.1.0 |

## Notes

- **telemed-ia-appointment-scheduling-portal** publishes `v2.0.1`, which
  replaces `v2.0.0` as the current version for this cut.
- **telemed-ia-infra-postgres** publishes `v2.1.0`, which adds the
  `medical-consultation` domain to the shared instance. `v2.0.0` remains
  as the previous version.
- **telemed-ia-patient-management-portal** has a current `v2.0.0` tag in
  the Domains table and is therefore excluded from the no-tag list below.
- The Appointment Scheduling Portal `v2.0.0` and PostgreSQL infrastructure
  `v2.0.0` targets above were checked against public tag refs on 2026-10-13.
  The listed commit SHAs are the peeled commit targets.
- The following repositories exist in the organization but have **no
  published tag** as of the close of the cut: `telemed-ia-worker`,
  `telemed-ia-workflow`, `telemed-ia-identity-and-access-api`,
  `telemed-ia-identity-and-access-portal`,
  `telemed-ia-professional-management-api`,
  `telemed-ia-professional-management-portal`,
  `telemed-ia-intelligent-agent-api`,
  `telemed-ia-document-generation-api`, `telemed-ia-notifications-db`,
  `telemed-ia-notifications-api`, `telemed-ia-notifications-portal`.
- Pending for cut 3: complete the repositories without a tag and
  publish their versions once the domain is closed.

---

## References

- Repository Standard — section 11 (Release) and section 11.5 (Tagging
  with semantic versioning).
- Annex J — single-instance-per-engine architecture.
- Governance repository: `code-corhuila/telemed-ia-docs`.
