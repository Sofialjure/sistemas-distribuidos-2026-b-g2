<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.
     Your weekly grade is read AUTOMATICALLY from this file:
       16-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 16

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->
- FULL_NAME: María Sofía Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Close MVP 3 for the final presentation: publish and tag `v3.0.0` in my six repositories, fix the findings of the week 15 tests (authorization before validation, a circuit breaker on the names lookup, the Spring Boot patch upgrade) and open release 3.1.0 with them, organize the shared documentation for the final deliverables with a system changelog, and record the promotional video of the platform and the video that explains its deployment.
<!-- CONFIG-END -->

## 1. User stories worked this week
| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| HU-05 | User and Healthcare Professional Management (professional profiles, onboarding saga) | done | Release 3.0.0 merged and tagged `v3.0.0`: [db #37](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/37), [api #56](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/56), [portal #20](https://github.com/code-corhuila/telemed-ia-professional-management-portal/pull/20); fixes [#57](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/57), [#58](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/58), [#59](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/59), promotion [#60](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/60), release 3.1.0 [#61](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/61) |
| HU-16 | Download Consultation Summary as PDF | done | Release 3.0.0 merged and tagged `v3.0.0`: [db #15](https://github.com/code-corhuila/telemed-ia-document-generation-db/pull/15), [api #63](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/63), [portal #20](https://github.com/code-corhuila/telemed-ia-document-generation-portal/pull/20); fixes [#64](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/64), [#65](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/65), promotion [#66](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/66), release 3.1.0 [#67](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/67) |

## 2. My individual contribution
- Individual work:
  - **MVP 3 published in my six repositories** (2026-11-14): the six `release/3.0.0` PRs opened in week 15 were approved and merged to `main`, and each repository has its annotated tag `v3.0.0` — professional-management db #37, api #56, portal #20 and document-generation db #15, api #63, portal #20.
  - **Findings of the week 15 tests fixed** (2026-11-14/15, each one with its test first, merged to `develop` and promoted to `qa`):
    - **authorization before validation** in both APIs (professional-management-api #57, document-generation-api #64): a caller without permission now gets `403` whatever the body, instead of `400` with the list of required fields; found by the security probes of weeks 13 and 15;
    - **circuit breaker on the account names lookup** (professional-management-api #58, decision DEC-017 in docs #218): after 3 consecutive identity failures the professional lists answer without names for 30 s without calling identity, so the 1.5 s per read measured in the week 15 chaos run no longer breaks the latency SLO; the identity drill in the docs now links to the breaker;
    - **Spring Boot 3.5.6 → 3.5.16** in both APIs (#59, #65), the dependency finding of week 15, with no code change;
    - **contract copies refreshed** from `telemed-ia-docs` `main` in both contract suites;
    - promotion to `qa`: professional-management-api #60 (part 21 of 21) and document-generation-api #66 (part 22 of 22).
  - **Release 3.1.0 opened** in both APIs (professional-management-api #61, document-generation-api #67): `release/3.1.0` cut from `main` with `cherry-pick -x` of the commits validated in `qa`, with scope, deployment and rollback plan; waiting for the professor's approval to merge and tag `v3.1.0`.
  - **Shared documentation organized for the final deliverables** (docs #219): a system `CHANGELOG.md` for the 31 repositories (Keep a Changelog + SemVer) with the release state of MVP 3 per repository, every tag and date checked against the repositories, linked from the docs README and the project-control change log.
  - **Two videos for the final presentation**: the promotional video of TeleMed IA and the video that explains how the platform is deployed.
- Team work this week:
  - **Juliana (@JulianaFerro1428):** the 3.0.0 releases of the PostgreSQL and MongoDB infrastructure (infra-postgres #44, infra-mongo #17) and the notifications database 2.0.0 (#10), and the `release/3.0.0` PRs of identity and access, intelligent agent, notifications, workflow, the API gateway and the front shell.
  - **José Miguel (@BondrewdXD):** the `qa → main` promotions of appointment scheduling, medical consultation, patient management and the worker (ten PRs).

## 3. Blockers and risks
- The release 3.1.0 PRs (professional-management-api #61, document-generation-api #67) and the changelog (docs #219) need approval before merging; `v3.1.0` cannot be tagged until then.
- Several teammates' release PRs to `main` are still open, so the platform is not yet fully tagged at MVP 3; the changelog shows which ones.
- GitHub Actions still cannot run in the organization (billing limit): the gates were run locally with the commands of each job.

## 4. Plan for next week
- Final presentation and defence on Thursday 2026-11-19: the promotional video, the deployment video and the live demo of the platform.
- Merge and tag `v3.1.0` in both APIs as soon as the release PRs are approved, and update the changelog rows.
- Oral defence of the corte 3 certification design note.

## 5. Compliance self-check
- [x] Conventional Commits - `type(scope): summary`
- [x] Per-environment HU branch + PR to that environment (hu-xxx-dev -> develop, ...)
- [x] Testable acceptance criteria
- [x] Tests added/updated (unit / integration)
- [x] DDD / hexagonal boundaries respected (domain has no I/O)
- [x] No secrets; config via environment variables

## 6. Evidence links
- Release 3.0.0 merged and tagged: https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/37, https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/56, https://github.com/code-corhuila/telemed-ia-professional-management-portal/pull/20, https://github.com/code-corhuila/telemed-ia-document-generation-db/pull/15, https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/63 and https://github.com/code-corhuila/telemed-ia-document-generation-portal/pull/20
- Tags: https://github.com/code-corhuila/telemed-ia-professional-management-api/tags and https://github.com/code-corhuila/telemed-ia-document-generation-api/tags
- Week 15 findings fixed: https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/57, https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/58, https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/59, https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/64, https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/65 and https://github.com/code-corhuila/telemed-ia-docs/pull/218
- Promotion to `qa`: https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/60 and https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/66
- Release 3.1.0: https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/61 and https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/67
- Changelog: https://github.com/code-corhuila/telemed-ia-docs/pull/219
- Team work: https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/44, https://github.com/code-corhuila/telemed-ia-infra-mongo/pull/17, https://github.com/code-corhuila/telemed-ia-appointment-scheduling-api/pull/37
