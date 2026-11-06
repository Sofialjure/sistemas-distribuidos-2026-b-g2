#!/usr/bin/env bash
# Local rehearsal of release-image.yml: build the image of a tag, scan it, push it to a local
# registry (instead of GHCR), deploy it by digest and smoke test it.
# Usage: deploy-tagged-image.sh <repo-dir> <version> <registry> <docker-network> <env-file> [--scan-report-only]
set -uo pipefail
REPO="$1"; VERSION="$2"; REGISTRY="$3"; NET="$4"; ENVFILE="$5"; MODE="${6:-}"
HERE="$(cd "$(dirname "$0")/../.." && pwd)"; NAME="$(basename "$REPO")"
IMAGE="$REGISTRY/code-corhuila/$NAME"; SHA="$(git -C "$REPO" rev-parse --short=7 HEAD)"
echo "== 1. build $IMAGE:$VERSION (sha-$SHA)"
docker build -q -f "$REPO/deploy/Dockerfile" -t "$IMAGE:$VERSION" -t "$IMAGE:sha-$SHA" "$REPO" || exit 1
echo "== 2. image scan (HIGH/CRITICAL with a fix)"
if MSYS_NO_PATHCONV=1 docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache \
     aquasec/trivy:0.57.1 image --quiet --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 --format json \
     -o /dev/null "$IMAGE:$VERSION"; then echo "scan: PASS"
else
  echo "scan: FAIL - the release job stops here"
  [ "$MODE" = "--scan-report-only" ] || exit 1
  echo "(--scan-report-only: continuing to rehearse the remaining steps)"
fi
echo "== 3. push"
docker push -q "$IMAGE:$VERSION" >/dev/null && docker push -q "$IMAGE:sha-$SHA" >/dev/null || exit 1
DIGEST="$(docker inspect --format '{{index .RepoDigests 0}}' "$IMAGE:$VERSION")"; echo "digest: $DIGEST"
echo "== 4. deploy by digest"
docker rmi -f "$IMAGE:$VERSION" "$IMAGE:sha-$SHA" >/dev/null; docker pull -q "$DIGEST" >/dev/null || exit 1
docker rm -f "release-$NAME" >/dev/null 2>&1
docker run -d --name "release-$NAME" --network "$NET" --env-file "$ENVFILE" -p "127.0.0.1:${HOST_PORT:-18080}:8080" -p "127.0.0.1:${MGMT_HOST_PORT:-19081}:9081" "$DIGEST" >/dev/null || exit 1
echo "== 5. smoke test"
bash "$HERE/session-2/smoke/smoke-test.sh" "http://127.0.0.1:${HOST_PORT:-18080}" "http://127.0.0.1:${MGMT_HOST_PORT:-19081}" "${PROTECTED_PATH:-/api/documents}" "${METRIC_PREFIX:-document_generation_}" "${SMOKE_TOKEN:-}"
