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
- LIBRARY_BOOK:
- LIBRARY_RECORD_TIME:
- STORIES:
<!-- CONFIG-END -->

| File | Checkpoint |
|---|---|
| `README.md` | CP0 |
| `01-attack-surface.md` | CP1 |
