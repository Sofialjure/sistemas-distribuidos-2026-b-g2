#!/usr/bin/env bash
# Runs the blocking PR gates of a Java service, in the order of the CI workflow, and stops at
# runs every gate even after a failure (in CI they are parallel jobs). Usage: api-gates.sh <repo-dir> <results-dir>
# Integration tests need TEST_DATABASE_URL (and TEST_STORAGE_* / TEST_RABBITMQ_URL for
# Document Generation) exported; in CI they come from service containers.
set -uo pipefail
REPO="$1"; OUT="$2"; HERE="$(cd "$(dirname "$0")/.." && pwd)"
NAME="$(basename "$REPO")"; mkdir -p "$OUT"
LOG="$OUT/$NAME.md"; : > "$LOG"
JACOCO=org.jacoco:jacoco-maven-plugin:0.8.12
CHECKSTYLE=org.apache.maven.plugins:maven-checkstyle-plugin:3.6.0
gate() { # gate <name> <command...>
  local name="$1"; shift; local start=$SECONDS
  if (cd "$REPO" && "$@") > "$OUT/$NAME-$name.log" 2>&1; then
    echo "| $name | PASS | $((SECONDS-start)) s |" >> "$LOG"
  else
    echo "| $name | FAIL | $((SECONDS-start)) s |" >> "$LOG"; FAILED=1
  fi
}
FAILED=0
echo "| Gate | Result | Time |" >> "$LOG"; echo "|---|---|---|" >> "$LOG"
gate build-and-types mvn -B -ntp -DskipTests test-compile
gate lint mvn -B -ntp -q $CHECKSTYLE:check -Dcheckstyle.config.location="$HERE/lint/checkstyle.xml" \
  -Dcheckstyle.includeTestSourceDirectory=true -Dcheckstyle.consoleOutput=true -Dcheckstyle.failOnViolation=true
gate tests-and-coverage mvn -B -ntp $JACOCO:prepare-agent verify $JACOCO:report
gate coverage-threshold python -I "$HERE/scripts/coverage-gate.py" . "$HERE/scripts/coverage-baseline.json"
gate secrets env MSYS_NO_PATHCONV=1 docker run --rm -v "$(cygpath -m "$REPO" 2>/dev/null || echo "$REPO"):/repo:ro" zricethezav/gitleaks:v8.21.2 \
  git /repo --no-banner --redact --exit-code 1
# Scan the packaged jar: it holds exactly the resolved dependencies (scanning pom.xml depends on
# resolving every parent pom over the network and can skip modules silently).
JAR="$(cd "$REPO" && ls *-app/target/*-api.jar | head -1)"
gate dependencies env MSYS_NO_PATHCONV=1 docker run --rm -v "$(cygpath -m "$REPO" 2>/dev/null || echo "$REPO"):/src:ro" -v trivy-cache:/root/.cache aquasec/trivy:0.57.1   rootfs --quiet --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 "/src/$JAR"
if [ "$FAILED" = 0 ]; then echo "All gates passed for $NAME"; else echo "Blocking gate failed for $NAME"; exit 1; fi
