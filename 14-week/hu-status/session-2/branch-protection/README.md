# Branch protection of `develop`, `qa` and `main`

## Current state (read with `gh api repos/code-corhuila/<repo>/branches/<branch>/protection`, 2026-11-06)

The six repositories I own (`professional-management-db|api|portal`,
`document-generation-db|api|portal`) have the same rules:

| Rule | `develop` | `qa` | `main` |
|---|---|---|---|
| Pull request required | yes | yes | yes |
| Approvals | **0** | **0** | 1 |
| Dismiss stale approvals | no | no | yes |
| Code owner review | no | no | yes |
| Required status checks | **none** | **none** | **none** |
| Conversations resolved | yes | yes | yes |
| Admins included | yes | yes | yes |
| Force push / deletion | blocked | blocked | blocked |
| Linear history | no | no | no |

Without required status checks a red pipeline does not block a merge, and with 0 approvals a
PR to `develop` can be merged without any review (it happened with docs #163 and #164).

## Proposal

| Rule | `develop` ([json](develop.json)) | `qa` ([json](qa.json)) | `main` ([json](main.json)) |
|---|---|---|---|
| Required status check | `gates`, branch up to date | `gates`, branch up to date | `gates`, branch up to date |
| Approvals | 1, stale ones dismissed | 1, stale ones dismissed | **3** (teacher + 2 members, DoD), code owners, approval after the last push |
| Linear history | no (merge commits allowed) | **yes** (promotions with rebase keep each `cherry picked from`) | **yes** |
| Conversations, admins, force push, deletion | unchanged | unchanged | unchanged |

For the `-db` repositories the required check is `Reconstruction check` (`db-ci.yml`)
instead of `gates`.

## Applying it

[`apply.sh`](apply.sh) prints what it would send (dry run). Changing branch protection is not
mine to do: it is applied by an organization administrator with
`apply.sh --apply code-corhuila/telemed-ia-<repo> ...` once CICD-01 has put the `gates`
workflow in each repository (a required check that never runs would block every PR).
