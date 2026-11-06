#!/usr/bin/env bash
# Runs the blocking PR gates of an Angular portal, in the order of the CI workflow; every gate
# runs even after a failure (in CI they are parallel jobs). Usage: portal-gates.sh <repo-dir> <results-dir>
set -uo pipefail
REPO="$1"; OUT="$2"; HERE="$(cd "$(dirname "$0")/.." && pwd)"
NAME="$(basename "$REPO")"; mkdir -p "$OUT"; LOG="$OUT/$NAME.md"; FAILED=0
gate() {
  local name="$1"; shift; local start=$SECONDS
  if (cd "$REPO" && "$@") > "$OUT/$NAME-$name.log" 2>&1; then echo "| $name | PASS | $((SECONDS-start)) s |" >> "$LOG"
  else echo "| $name | FAIL | $((SECONDS-start)) s |" >> "$LOG"; FAILED=1; fi
}
printf '| Gate | Result | Time |\n|---|---|---|\n' > "$LOG"
gate install npm ci --no-audit --no-fund
# Gate tools that the portal does not declare yet, installed only for this run.
gate gate-tools npm install --no-save --no-audit --no-fund eslint@9 typescript-eslint@8 angular-eslint@21 @vitest/coverage-v8@4
cp "$HERE/lint/eslint.config.mjs" "$REPO/eslint.config.mjs"
gate types sh -c 'npx tsc -p tsconfig.app.json --noEmit && npx tsc -p tsconfig.spec.json --noEmit'
gate lint npx eslint "src/**/*.ts" "src/**/*.html"
gate tests-and-coverage npx ng test --watch=false --coverage --coverage-reporters=json-summary --coverage-reporters=text-summary
gate build npm run build
gate dependencies npm audit --omit=dev --audit-level=high
gate secrets env MSYS_NO_PATHCONV=1 docker run --rm -v "$(cygpath -m "$REPO" 2>/dev/null || echo "$REPO"):/repo:ro" zricethezav/gitleaks:v8.21.2 \
  git /repo --no-banner --redact --exit-code 1
rm -f "$REPO/eslint.config.mjs"
if [ "$FAILED" = 0 ]; then echo "All gates passed for $NAME"; else echo "Blocking gate failed for $NAME"; exit 1; fi
