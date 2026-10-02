# OPTIONAL ACTIVITY — Week 09 · Session 1

## Objective

This practical activity demonstrates secure environment configuration, startup
validation, pre-commit secret scanning, and a feature flag in the **Professional
Management** context. It prepares discussion for Week 09 Session 2 without claiming
to modify or deploy the separate Professional Management API or database repositories.

The activity repository contains course material and evidence, not the API runtime.
Accordingly, the Python file beside this document is a small, runnable demonstration
of the pattern; it is not production service code and does not introduce a new service
architecture.

## Professional Management context

Week 08 documents HU-005's professional and specialty catalog schema, API foundation,
and tests. The added capability is a proposed export of the **specialty reference
catalog** to CSV. It is an administrative/reference-data operation, contains no patient
or consultation data, and does not diagnose or recommend medication. This capability
is new for this activity; the existing microservice is not claimed to implement it.

## Environment configuration and `.env.example`

The template at [`.env.example`](.env.example) records the names
found in the course's TeleMed IA configuration material:

| Variable | Use in this demonstration |
|---|---|
| `DB_URL` | Required database connection setting. |
| `DB_USERNAME` | Required database username. |
| `DB_PASSWORD` | Required secret, injected at runtime. |
| `JWT_SECRET` | Required signing secret, injected at runtime. |
| `CORS_ORIGINS` | Required allowed-origin setting. |
| `PORT` | Required listening port; must be an integer from 1 to 65535. |
| `PROFESSIONAL_SPECIALTY_CATALOG_EXPORT_ENABLED` | Optional feature flag; defaults to `false`. |

The names are grounded in the Week 6 configuration matrix and activity. Their exact
required/optional status and binding to the Professional Management API must be confirmed
in that API repository before adopting this example there. In particular, Week 6 also
documents the Compose-side `POSTGRES_*` names and their mapping to application settings.
This repository does not establish the API's authoritative runtime contract.

`.env.example` is a template only. Copy it for a local environment if needed, fill
secrets locally from a safe source, and never commit the resulting `.env` file. The
template intentionally leaves settings blank rather than shipping working credentials.
The feature flag is explicitly `false`.

## Startup validation demonstration

`optional activity session 1 - config and feature flag demo.py` validates the six
configuration entries above before reporting the demo ready. It fails on the first
missing value, rejects a non-numeric/out-of-range `PORT`, and accepts only `true` or
`false` for the feature flag. Errors identify the setting but do not echo its value.
Secret-bearing fields are excluded from the configuration object's representation.

Run its tests and validation example with Python 3:

```powershell
python "09-week/hu-status/optional activity session 1 - config and feature flag demo.py"
$env:DB_URL = "jdbc:postgresql://localhost:5432/example"
$env:DB_USERNAME = "test-user"
$env:DB_PASSWORD = "fake-test-password"
$env:JWT_SECRET = "fake-test-jwt-secret"
$env:CORS_ORIGINS = "http://localhost:4200"
$env:PORT = "8080"
python "09-week/hu-status/optional activity session 1 - config and feature flag demo.py" --validate
```

The values above are disposable examples for the demonstration, not project credentials.
The first command runs isolated unit tests with fake values. The second command shows
the expected configuration validation invocation; do not use the sample values as
production secrets.

This demonstrates a fail-fast pattern only. Actual API startup validation belongs in
the API's existing configuration/bootstrap layer and is not changed by this activity.

## Secrets and Git protection

Expected flow:

```text
Secret Store / Runtime Environment
                ↓
       Environment Variables
                ↓
          Application
                ↓
 Professional Management API
```

No production secret manager is configured by this course evidence repository. For
local development, inject values through an untracked local environment file or shell
environment; for a deployment, use the secret store/runtime injection mechanism selected
for that environment. Do not bake secrets into an image or committed configuration, put
real values in `.env.example`, hardcode credentials, or print secret values in logs.
The demonstration emits only safe configuration status/errors.

The root `.gitignore` excludes `.env`, dotenv variants, and `.envrc`, while explicitly
allowing `.env.example`. Verify the policy with:

```powershell
git check-ignore -v .env .env.local .env.production .envrc
git check-ignore .env.example
```

The first command should list ignore rules; the second should return no ignore match
because the safe template is intended to be tracked.

## Pre-commit secret scan

This repository had no active pre-commit framework or custom Git hook. The activity
adds `.pre-commit-config.yaml` using the upstream **Gitleaks** hook pinned to `v8.30.1`.
It scans staged changes in the hook's native pre-commit mode, redacts findings, and
blocks the commit when a finding is reported. Gitleaks uses its maintained
secret-detection rules; the activity does not substitute a word-list scanner.

Install the pre-commit framework and install the repository hook:

```powershell
python -m pip install --user pre-commit
python -m pre_commit install
```

The Gitleaks hook builds its pinned scanner with Go when pre-commit initializes it.
Go must be installed and available on `PATH`. Check and run the hook with:

```powershell
python -m pre_commit run --all-files
```

If a potential secret is found, Gitleaks returns a failure and Git aborts the commit.
Review the finding and remove/rotate any exposed credential; do not suppress a finding
without verifying it. A safe fake-token scanner fixture is used only in a temporary
directory during validation and is not stored in this repository.

## Feature flag

- **Name:** `PROFESSIONAL_SPECIALTY_CATALOG_EXPORT_ENABLED`
- **Default:** `false` (missing or explicitly false keeps export unavailable).
- **Capability:** export specialty reference names as CSV.
- **OFF:** the demonstration rejects the export request with a feature-disabled result.
- **ON:** setting the flag to `true` enables CSV generation for the specialty catalog.
- **Safety:** this feature does not use patient/consultation data and does not provide
  diagnosis or medication recommendations.

The demo implements the guard and tests both states. The API endpoint, authorization,
audit policy, ownership, rollout audience, monitoring, and operational rollback remain
design work for the actual API and Week 09 Session 2; the flag is not represented as a
live production toggle here. An API implementation can read the flag from runtime
configuration and turn it off without a code change if that deployment supports
runtime configuration refresh; otherwise changing an environment variable may require
a restart/redeployment.

## Validation and evidence

The executable checks cover valid configuration, a missing required setting, malformed
port handling without echoing supplied values, secret-safe object representation, and
the feature's OFF/ON behavior. Run:

```powershell
python "09-week/hu-status/optional activity session 1 - config and feature flag demo.py"
```

Validation executed for this activity:

- The seven Python unit tests pass, including valid configuration, missing `DB_URL`,
  missing `JWT_SECRET`, invalid port without echoing the input, and feature flag OFF/ON.
- Running the startup demonstration with safe sample configuration reports that
  configuration is valid and export is disabled. An invalid port exits non-zero and
  reports the variable name without printing the supplied value.
- Gitleaks scanned the working tree and reported no leaks.
- Gitleaks detected a known-fake GitHub-token pattern in a temporary staged fixture
  and returned non-zero; the fixture was removed and was never committed.
- `python -m pre_commit run --all-files` passes with the pinned Gitleaks hook.
- `git check-ignore` confirms `.env`, `.env.local`, `.env.production`, and `.envrc`
  are ignored, while `.env.example` remains trackable.

Never add a real or fake credential fixture to source files or commit it.

## Relation to Week 09 · Session 2

This Session 1 activity supplies concrete configuration names, a fail-fast validation
example, an OFF-by-default flag, and a pre-commit control for Session 2 planning. Session
2 can decide who owns and rotates secrets, who owns and removes the flag, which rollout
stages/canary signals to use, and the rollback procedure for MVP 2. Those decisions are
not made here; the API's true configuration contract and deployment capabilities must
be confirmed with the owning team first.
