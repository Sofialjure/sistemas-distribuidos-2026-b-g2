<!-- HU-STATUS TEMPLATE - do NOT remove the <!-- ... --> markers or the table headers.
     Your weekly grade is read AUTOMATICALLY from this file:
       16-week/hu-status/README.md  (inside YOUR fork). English. -->

# Weekly Status - Week 16

<!-- CONFIG-START - must match your profile repo (username/username) CONFIG -->
- FULL_NAME: María Sofía Aljure Herrera
- GITHUB_USER: Sofialjure
- TEAM: Telemed - Group 2 / AI Telemedicine Chatbot
- SPRINT_GOAL: Close MVP 3 for the final presentation: publish and tag `v3.0.0` in my six repositories, fix the findings of the week 15 tests (authorization before validation, a circuit breaker on the names lookup, the Spring Boot patch upgrade) and release them as 3.1.0, organize the shared documentation for the final deliverables with a system changelog, and record the promotional video of the platform and the video that explains its deployment.
<!-- CONFIG-END -->

## 1. User stories worked this week
| HU ID | Title | Status (todo/doing/done) | Evidence (PR or commit URL) |
|---|---|---|---|
| HU-05 | User and Healthcare Professional Management (professional profiles, onboarding saga) | done | Release 3.0.0 merged and tagged `v3.0.0`: [db #37](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/37), [api #56](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/56), [portal #20](https://github.com/code-corhuila/telemed-ia-professional-management-portal/pull/20); fixes [#57](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/57), [#58](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/58), [#59](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/59), promotion [#60](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/60), release 3.1.0 merged and tagged `v3.1.0` [#61](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/61) |
| HU-16 | Download Consultation Summary as PDF | done | Release 3.0.0 merged and tagged `v3.0.0`: [db #15](https://github.com/code-corhuila/telemed-ia-document-generation-db/pull/15), [api #63](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/63), [portal #20](https://github.com/code-corhuila/telemed-ia-document-generation-portal/pull/20); fixes [#64](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/64), [#65](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/65), promotion [#66](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/66), release 3.1.0 merged and tagged `v3.1.0` [#67](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/67) |

## 2. My individual contribution
- Individual work:
  - **MVP 3 published in my six repositories** (2026-11-14): the six `release/3.0.0` PRs opened in week 15 were approved and merged to `main`, and each repository has its annotated tag `v3.0.0` — professional-management db #37, api #56, portal #20 and document-generation db #15, api #63, portal #20.
  - **Findings of the week 15 tests fixed** (2026-11-14/15, each one with its test first, merged to `develop` and promoted to `qa`):
    - **authorization before validation** in both APIs (professional-management-api #57, document-generation-api #64): a caller without permission now gets `403` whatever the body, instead of `400` with the list of required fields; found by the security probes of weeks 13 and 15;
    - **circuit breaker on the account names lookup** (professional-management-api #58, decision DEC-017 in docs #218): after 3 consecutive identity failures the professional lists answer without names for 30 s without calling identity, so the 1.5 s per read measured in the week 15 chaos run no longer breaks the latency SLO; the identity drill in the docs now links to the breaker;
    - **Spring Boot 3.5.6 → 3.5.16** in both APIs (#59, #65), the dependency finding of week 15, with no code change;
    - **contract copies refreshed** from `telemed-ia-docs` `main` in both contract suites;
    - promotion to `qa`: professional-management-api #60 (part 21 of 21) and document-generation-api #66 (part 22 of 22).
  - **Release 3.1.0 published** in both APIs (professional-management-api #61, document-generation-api #67, 2026-11-15): `release/3.1.0` cut from `main` with `cherry-pick -x` of the commits validated in `qa`, with scope, deployment and rollback plan; approved by the professor, merged, and tagged `v3.1.0` on `main` (tree equal to `qa`).
  - **Release PRs of the platform merged** (2026-11-15): after the professor approved them, I merged the 21 MVP 3 release PRs of the other repositories to `main` (rebase, or a merge commit where GitHub refused to rebase), so every code repository reached `main` for the final deliverable.
  - **Shared documentation organized for the final deliverables** (docs #219–#223):
    - a system `CHANGELOG.md` for the 31 repositories (Keep a Changelog + SemVer) with the final tag and tag date of every repository and the `[3.1.0]` and `[Unreleased]` sections (#219, #220, #223);
    - the identity, appointment and consultation ER diagrams redrawn, and new patient, notification and workflow ER diagrams, all read from a database migrated from scratch, plus the sequence diagram of the professional onboarding saga and the workflow in the container diagram (#221);
    - `06-data/models.md` and the modeling conventions rewritten from the migrated schemas (UUID keys, `CHECK` constraints, exclusion constraints against double booking) (#221);
    - an `observability.md` for the six services that had none (gateway, patient, appointment, consultation, worker, workflow), with the signals each one exposes and what is not in place yet (#222);
    - the release state of every environment, the evidence of four non-functional requirements and the MVP 3 tags in the service catalog, READMEs and runbooks (#220, #223).
  - **Findings in the platform fixed for the team** (2026-11-15, PRs to `develop`, each verified by running the service from its own `deploy/compose.yml` in an isolated network): the default database password removed from the patient API (patient-management-api #36), and a container healthcheck for the patient API (#37), appointment API (#40), consultation API (#34) and API gateway (#24); the patient API turns `unhealthy` while its database is down and recovers by itself.
  - **Two videos for the final presentation**: the promotional video of TeleMed IA and the video that explains how the platform is deployed ([folder with both videos](https://drive.google.com/drive/folders/1mk0eBnivnoNO80U8w_EzH3xVMZ8d2sE9?usp=sharing)).
- Team work this week:
  - **Juliana (@JulianaFerro1428):** the 3.0.0 releases of the PostgreSQL and MongoDB infrastructure (infra-postgres #44, infra-mongo #17) and the notifications database 2.0.0 (#10), the `release/3.0.0` PRs of identity and access, intelligent agent, notifications, workflow, the API gateway and the front shell, the annotated `v3.0.0` tags of the platform repositories, the restored CI workflow and PR template of the appointment portal on `qa` (#37), the clean-up of the files the 2.0 merge had left on `main` in the appointment and patient APIs (#39, #35), so `main` equals `qa` everywhere, and the review of every PR listed above.
  - **José Miguel (@BondrewdXD):** the `qa → main` promotions of appointment scheduling, medical consultation, patient management and the worker (ten PRs).

## 3. Blockers and risks
- None open for the deliverable: every code repository is tagged on `main` (28 `v3.0.0`, my two APIs `v3.1.0`) and `main` equals `qa` in all 30.
- The fixes merged on 2026-11-15 (patient password, four healthchecks) are on `develop` only; they reach `qa` and `main` in a later promotion.
- GitHub Actions still cannot run in the organization (billing limit): the gates were run locally with the commands of each job.

## 4. Plan for next week
- Final presentation and defence on Thursday 2026-11-19: the promotional video, the deployment video and the live demo of the platform.
- Promote the healthchecks and the patient API fix from `develop` to `qa` with the team.
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
- Release 3.1.0 merged and tagged: https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/61 and https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/67
- Documentation: https://github.com/code-corhuila/telemed-ia-docs/pull/219, https://github.com/code-corhuila/telemed-ia-docs/pull/220, https://github.com/code-corhuila/telemed-ia-docs/pull/221, https://github.com/code-corhuila/telemed-ia-docs/pull/222 and https://github.com/code-corhuila/telemed-ia-docs/pull/223
- Platform fixes: https://github.com/code-corhuila/telemed-ia-patient-management-api/pull/36, https://github.com/code-corhuila/telemed-ia-patient-management-api/pull/37, https://github.com/code-corhuila/telemed-ia-appointment-scheduling-api/pull/40, https://github.com/code-corhuila/telemed-ia-medical-consultation-api/pull/34 and https://github.com/code-corhuila/telemed-ia-api-gateway/pull/24
- Videos (promotional and deployment explanation): https://drive.google.com/drive/folders/1mk0eBnivnoNO80U8w_EzH3xVMZ8d2sE9?usp=sharing
- Team work: https://github.com/code-corhuila/telemed-ia-infra-postgres/pull/44, https://github.com/code-corhuila/telemed-ia-infra-mongo/pull/17, https://github.com/code-corhuila/telemed-ia-appointment-scheduling-api/pull/38, https://github.com/code-corhuila/telemed-ia-appointment-scheduling-portal/pull/37 and https://github.com/code-corhuila/telemed-ia-appointment-scheduling-api/pull/39
