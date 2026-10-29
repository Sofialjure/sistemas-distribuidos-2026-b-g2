# Week 13 workshop: threat modeling and security backlog

Threat model of one trust boundary of TeleMed IA: the asynchronous call from
`telemed-ia-worker` to `document-generation-api` that turns a finished consultation into a PDF.

<!-- CONFIG-START -->
- FULL_NAME: Sofia Aljure
- GITHUB_USER: Sofialjure
- TEAM: TeleMed IA (Group 2)
- DOCS_REPO: https://github.com/code-corhuila/telemed-ia-docs
- BOUNDARY: telemed-ia-worker → document-generation-api (POST /api/documents/generate, SERVICE token)
- CLAIM_ISSUE: https://github.com/code-corhuila/telemed-ia-docs/issues/141
- REFLECTION_DOC: https://docs.google.com/document/d/1Ba2hON0soqgBYlmok7cQUmLyJmrle24H9ksZInrC6lU/edit
- LIBRARY_BOOK: Tanenbaum, A. S. & van Steen, M. Sistemas distribuidos: principios y paradigmas, 2.a ed., Pearson Prentice Hall, 2008, call number 005.4476 T15D ej. 1
- LIBRARY_RECORD_TIME: 2026-10-29 07:50
- STORIES: https://github.com/code-corhuila/telemed-ia-docs/issues/149, https://github.com/code-corhuila/telemed-ia-docs/issues/150, https://github.com/code-corhuila/telemed-ia-docs/issues/151
<!-- CONFIG-END -->

| File | Checkpoint |
|---|---|
| `README.md` | CP0 |
| `01-attack-surface.md` | CP1 |
| STRIDE: https://github.com/code-corhuila/telemed-ia-docs/pull/144 | CP2 |
| Security stories #149, #150, #151 | CP3 |
| `04-security-ci/` (workflow, negative test, how to run) | CP4 |
