#!/bin/bash
# Secret scan of the full git history of each repository (gitleaks), with a positive control,
# and a dependency scan of one image (trivy, HIGH and CRITICAL only).
# Usage: security-scans.sh <image> <repository folder>...
#   e.g. security-scans.sh professional-management-api:eeb08c7 ../telemed-ia-*-management-* ../telemed-ia-document-generation-*
IMAGE=$1; shift
host() { cygpath -m "$1" 2>/dev/null || echo "$1"; }
gitleaks() {  # gitleaks <repo>: prints the number of findings
  MSYS_NO_PATHCONV=1 docker run --rm -v "$(host "$1"):/repo:ro" zricethezav/gitleaks:v8.21.2 \
    git /repo --no-banner --redact --exit-code 0 2>&1 | grep -E 'commits scanned|leaks found|no leaks found'
}

echo "## Positive control: a throwaway repository with a committed private key"
control=$(mktemp -d)
git -C "$control" init -q
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:1024 -out "$control/leaked.pem" 2>/dev/null
git -C "$control" add . && git -C "$control" -c user.name=control -c user.email=control@example.test commit -qm control
gitleaks "$control"
rm -rf "$control"

for repo in "$@"; do
  echo "## gitleaks $(basename "$repo")"
  gitleaks "$repo"
done

echo "## trivy $IMAGE"
MSYS_NO_PATHCONV=1 docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.57.1 \
  image --quiet --severity HIGH,CRITICAL --format table "$IMAGE"
