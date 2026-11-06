#!/usr/bin/env bash
# Applies develop.json, qa.json and main.json to the given repositories through the GitHub API.
# Dry run by default: it prints what it would send. Only an organization administrator should run
# it with --apply. For the -db repositories, replace the context "gates" with "Reconstruction check".
# Usage: apply.sh [--apply] <owner/repo>...
set -euo pipefail
APPLY=false; [ "${1:-}" = "--apply" ] && { APPLY=true; shift; }
HERE="$(cd "$(dirname "$0")" && pwd)"
for repo in "$@"; do
  for branch in develop qa main; do
    if $APPLY; then
      gh api -X PUT "repos/$repo/branches/$branch/protection" --input "$HERE/$branch.json" >/dev/null
      echo "applied $branch protection to $repo"
    else
      echo "would PUT repos/$repo/branches/$branch/protection with $branch.json"
    fi
  done
done
