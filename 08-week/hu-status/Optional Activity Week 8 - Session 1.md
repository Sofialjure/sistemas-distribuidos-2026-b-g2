# Optional Activity — Week 08 — Session 1

## Sprint Execution: Agile and DevOps for TeleMed IA

### Evidence basis and scope

This is an evidence-based reconstruction of the documented Week 08 work, not a claim that
the activities below were planned in a formal sprint or discussed in actual daily stand-ups.
The Week 08 status identifies **HU-005 — Professional Management** as `doing`. Its DB and
API changes were delivered through the linked pull requests (PRs). The same status says
that the broader HU remains in progress.

Acceptance criteria below are written for this activity from the documented change scope;
they do not replace the authoritative HU acceptance criteria. The proposed WIP limit is a
recommendation, not a documented team rule.

### 1. Sprint backlog

| Priority | HU / Story | Description | Acceptance Criteria (testable) | Status | PR / Evidence |
|---|---|---|---|---|---|
| 1 | HU-005 — Professional Management: DB foundation | Create the Professional Management schema and reference specialty catalog. | On a fresh PostgreSQL database, Liquibase creates the `professionals` and `specialties` tables, the `professionals.specialty_id` foreign key, and seven seeded specialties; the schema validation tests pass. | Done as a PR increment; HU-005 remains `doing`. | [DB PR #1 — schema, seed, tests](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/1) |
| 2 | HU-005 — DB rollback and seed safety | Make schema and reference-data changes safely reversible. | Applying all four changesets, rolling them back, and reapplying them completes successfully. In collision tests, specialty rows that existed before a seed changeset remain unchanged after rollback. | Done as PR increments; HU-005 remains `doing`. | [DB PR #2 — Liquibase rollbacks](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/2); [DB PR #3 — safe specialty seed rollbacks](https://github.com/code-corhuila/telemed-ia-professional-management-db/pull/3) |
| 3 | HU-005 — API foundation, domain, persistence, and REST | Build the Professional Management API in separate hexagonal layers. | The API exposes the documented professional and specialty endpoints; domain/application tests run independently of Spring/JPA; persistence adapters sit behind application ports; a missing specialty and database integrity conflict are translated to the documented domain/API error handling. | Done as PR increments; HU-005 remains `doing`. | [API PR #2 — foundation](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/2); [#3 — domain/application](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/3); [#4 — persistence](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/4); [#5 — REST](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/5) |
| 4 | HU-005 — API tests | Verify application and persistence behavior. | Application-service tests cover professional and specialty use cases; persistence integration tests exercise both repositories against the test database and pass. | Done as PR increments; HU-005 remains `doing`. | [API PR #6 — application tests](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/6); [#7 — persistence integration tests](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/7) |
| 5 | HU-005 — API documentation | Document how to configure, run, and use the API. | A developer can find service setup/configuration, architecture information, and the endpoint documentation in the API repository README/docs. | Done as a PR increment; HU-005 remains `doing`. | [API PR #9 — service and endpoint documentation](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/9) |

All ten linked DB/API PRs above are merged. The items are implementation slices of the real
HU-005, not additional user stories.

### 2. Prioritization

The schema and reference data come first because the API's persistence layer consumes them.
The domain/application boundary is established before persistence and REST adapters, keeping
business rules independent of I/O. Tests then verify both the rules and database constraints;
documentation makes the resulting service usable by the team. The later DB rollback fixes
address a concrete data-safety risk discovered while validating seed ownership. These priorities
are derived from the change dependencies and the PR sequence, not from a separately recorded
Sprint Planning decision.

### 3. WIP limit

**Proposal (not a documented team limit): maximum 2 active story cards across the team.**
“Active” includes implementation and PR review; a card leaves WIP only after its acceptance
checks pass and its PR is merged, or it is explicitly marked blocked with an owner and next
action. The team should finish/review existing work before pulling another story. This limits
context switching across the separate DB, API, and Portal repositories and surfaces review or
integration bottlenecks sooner.

The Week 08 record does not report actual concurrent WIP, so this activity does not claim that
the proposed limit was observed. It also does not treat the separate, still-open [ADR-012
follow-up PR #44](https://github.com/code-corhuila/telemed-ia-docs/pull/44) as a completed HU-005
change.

### 4. PR traceability

Every implementation slice in this reconstructed backlog maps to real PR evidence above.
The DB changes are in the `telemed-ia-professional-management-db` repository; the service
foundation, domain/application, persistence, REST, tests, and documentation are in the
`telemed-ia-professional-management-api` repository. The PR descriptions report their scope
and validation; no PR number is inferred or invented.

### 5. Daily synchronization

**Reconstructed/proposed synchronization only.** There are no documented stand-up notes in the
Week 08 evidence. “What was done” below is supported by dated commits/PRs; “What was next” and
the risks are proposed coordination prompts based on the documented work and plan.

| Day / evidence window | What was done (documented) | What was next (proposed) | Blocker / risk |
|---|---|---|---|
| Sep 23, 2026 | DB schema, specialty seed, schema validation, and repository documentation were recorded; DB PR #1 was opened. | Confirm the schema/seed contract, then continue the API foundation and domain work. | Keep DB schema constraints aligned with the API domain model. |
| Sep 24–26, 2026 | API foundation, domain, persistence, REST, application/persistence tests, and documentation were delivered in API PRs #2–#7 and #9; the PRs were merged during this window. | Exercise the full DB/API path and complete the pending DB rollback/specialty-seed safety work. | Persistence constraints, error mapping, and rollback ownership require tests across layers. |
| Sep 27, 2026 | DB PRs #2 and #3 completed Liquibase rollback and specialty seed rollback-safety work; PR #3 includes collision-safety integration tests. | Continue HU-005 beyond these merged increments, including the planned Portal/integration work and remaining validation. | HU-005 is still reported as `doing`; merged increments do not prove the whole story is complete. |

### 6. Performance tracking

| Measure | Evidence-backed result |
|---|---|
| Completed implementation PRs | **10 merged PRs** for HU-005: DB #1–#3 and API #2–#7 plus #9. |
| Completed user stories | **0 verified as complete in the Week 08 status**; HU-005 is explicitly `doing`. |
| Work in progress | One HU-005 remains `doing`. A proposed WIP limit is given above, but actual concurrent WIP was not recorded. |
| Story points / velocity | No HU-005 estimate, completed story-point total, or reliable historical velocity was found in the reviewed Week 08 evidence. |
| Progress window | The linked DB work starts on Sep 23 and the last linked DB PR merged on Sep 27: a **4-calendar-day elapsed evidence window** (Sep 23 to Sep 27), not a per-story cycle-time measurement. |
| Planned vs. completed | The documented Week 08 goal was to advance HU-005. Ten DB/API PR increments merged, while the parent HU remained in progress. The evidence does not provide an approved sprint commitment or a point-based completion percentage. |

The **18 Story Points** recorded in the Week 04 status are Planning Poker estimates for the five
MVP 1 stories, not completed story points or measured velocity. They are therefore not used as
Week 08 throughput.

### 7. Session 1 conclusion

The documented HU-005 work is traceable through small, merged PRs across the DB and API
repositories, with schema, domain, persistence, REST, tests, and documentation delivered as
separate increments. Testable acceptance checks and a proposed WIP limit make the workflow
reviewable; the reconstructed sync makes clear what is evidence and what is a coordination
proposal. Performance can be measured by merged PRs and the HU's actual `doing` status, but
story-point velocity and real stand-up activity cannot be claimed from the available records.

### Sources

- [Week 08 status and PR evidence](README.md)
- [TeleMed IA user-story and requirement catalog](https://github.com/code-corhuila/telemed-ia-docs/blob/main/04-requirements/user-stories.md)
- [Professional Management DB repository](https://github.com/code-corhuila/telemed-ia-professional-management-db)
- [Professional Management API repository](https://github.com/code-corhuila/telemed-ia-professional-management-api)
