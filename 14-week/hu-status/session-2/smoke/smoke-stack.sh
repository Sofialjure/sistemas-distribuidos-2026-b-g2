#!/usr/bin/env bash
# Starts an image with the minimum it needs (PostgreSQL with the domain migrations) on a
# throwaway network, mints a token with a throwaway key pair and runs smoke-test.sh against it.
# Usage: smoke-stack.sh <image> <db-repo-dir> <app-user> <changelog-table> <protected-path> <metric-prefix> <token-role>
set -euo pipefail
IMAGE="$1"; DBREPO="$2"; APP_USER="$3"; TABLE="$4"; PROTECTED="$5"; METRIC="$6"; ROLE="$7"
HERE="$(cd "$(dirname "$0")" && pwd)"; NET="smoke-$$"; DOMAIN="${APP_USER%_app}"; WORK="$(mktemp -d)"
cleanup() { docker rm -f "$NET-app" "$NET-pg" >/dev/null 2>&1 || true; docker network rm "$NET" >/dev/null 2>&1 || true; rm -rf "$WORK"; }
trap cleanup EXIT
docker network create "$NET" >/dev/null
docker run -d --name "$NET-pg" --network "$NET" --network-alias postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=telemed_ia postgres:16-alpine >/dev/null
until docker exec "$NET-pg" pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done; sleep 2
PW=$(openssl rand -hex 16)
docker exec -i "$NET-pg" psql -q -U postgres -d telemed_ia -v ON_ERROR_STOP=1 <<SQL
CREATE ROLE ${APP_USER} LOGIN PASSWORD '${PW}';
CREATE ROLE ${DOMAIN}_reader NOLOGIN; CREATE ROLE ${DOMAIN}_writer NOLOGIN;
GRANT ${DOMAIN}_reader, ${DOMAIN}_writer TO ${APP_USER} WITH ADMIN OPTION;
GRANT CREATE ON DATABASE telemed_ia TO ${APP_USER};
CREATE SCHEMA ${DOMAIN} AUTHORIZATION ${APP_USER};
ALTER ROLE ${APP_USER} SET search_path = ${DOMAIN};
SQL
MSYS_NO_PATHCONV=1 docker run --rm --network "$NET" -v "$DBREPO:/liquibase/changelog-root" -w /liquibase/changelog-root liquibase/liquibase:4.31 \
  --url=jdbc:postgresql://postgres:5432/telemed_ia --username="$APP_USER" --password="$PW" \
  --changelog-file=changelog/changelog-master.yaml --database-changelog-table-name="$TABLE" \
  --database-changelog-lock-table-name="${TABLE/databasechangelog/databasechangeloglock}" update >/dev/null
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "$WORK/key.pem" 2>/dev/null
openssl pkey -in "$WORK/key.pem" -pubout -out "$WORK/pub.pem"
PUB=$(awk 'NF {printf "%s\n", $0}' "$WORK/pub.pem")
b64() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }
NOW=$(date +%s); H=$(printf '{"alg":"RS256","typ":"JWT"}' | b64)
P=$(printf '{"iss":"telemed-ia-identity-and-access","sub":"b0000000-0000-4000-8000-000000000001","role":"%s","iat":%d,"exp":%d}' "$ROLE" "$NOW" $((NOW+600)) | b64)
TOKEN="$H.$P.$(printf '%s.%s' "$H" "$P" | openssl dgst -sha256 -sign "$WORK/key.pem" | b64)"
docker run -d --name "$NET-app" --network "$NET" -p 127.0.0.1::8080 -p 127.0.0.1::9081 \
  -e JWT_PUBLIC_KEY="$PUB" -e DB_URL=jdbc:postgresql://postgres:5432/telemed_ia \
  -e DB_USER="$APP_USER" -e DB_USERNAME="$APP_USER" -e DB_PASSWORD="$PW" -e MANAGEMENT_PORT=9081 \
  -e STORAGE_ENDPOINT=http://object-storage:9000 -e IDENTITY_URL=http://identity-api:8081 -e CONSULTATION_BASE_URL=http://medical-consultation-api:8080 -e STORAGE_ACCESS_KEY=smoke -e STORAGE_SECRET_KEY=smoke-secret -e RABBITMQ_PASSWORD=smoke \
  -e GENERATION_BACKGROUND_ENABLED=false -e EVENTS_PUBLISHING_ENABLED=false \
  -e MANAGEMENT_OTLP_TRACING_EXPORT_ENABLED=false "$IMAGE" >/dev/null
APP=$(docker port "$NET-app" 8080 | head -1); MGMT=$(docker port "$NET-app" 9081 | head -1)
bash "$HERE/smoke-test.sh" "http://$APP" "http://$MGMT" "$PROTECTED" "$METRIC" "$TOKEN" \
  || { echo "--- last lines of the application log"; docker logs --tail 40 "$NET-app" 2>&1; exit 1; }
