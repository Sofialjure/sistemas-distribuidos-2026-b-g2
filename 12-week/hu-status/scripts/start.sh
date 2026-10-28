#!/bin/bash
# Starts blue, green, a green whose database is unreachable, and the nginx front door.
# Usage: start.sh <network> <env file> <JWT public key file> <blue image> <green image>
#   e.g. start.sh telemed-platform pm.env jwt.pem professional-management-api:2848b52 professional-management-api:eeb08c7
# The env file holds the service configuration (DB_URL, DB_USERNAME, DB_PASSWORD, IDENTITY_URL,
# SERVICE_CLIENT_ID, SERVICE_CLIENT_SECRET); keep it out of git.
NET=$1; ENV_FILE=$2; KEY=$3; BLUE=$4; GREEN=$5; W=$(cd "$(dirname "$0")" && pwd)
HC='curl -fsS http://localhost:9081/actuator/health || exit 1'   # readiness: includes the database
run() {  # run <color> <image> [extra docker args]
  local color=$1 image=$2; shift 2
  docker rm -f "pm-$color" >/dev/null 2>&1
  MSYS_NO_PATHCONV=1 docker run -d --name "pm-$color" --network "$NET" --env-file "$ENV_FILE" "$@" \
    -e JWT_PUBLIC_KEY="$(cat "$KEY")" --health-cmd "$HC" --health-interval 3s --health-retries 3 \
    --health-start-period 30s "$image" >/dev/null
}
run blue "$BLUE"
run green "$GREEN"
run green-broken "$GREEN" -e DB_URL=jdbc:postgresql://nowhere:5432/telemed_ia

cp "$W/lb/blue.inc" "$W/lb/active.inc"
docker rm -f pm-lb >/dev/null 2>&1
MSYS_NO_PATHCONV=1 docker run -d --name pm-lb --network "$NET" -p 127.0.0.1:28090:80 \
  -v "$(cygpath -m "$W/lb" 2>/dev/null || echo "$W/lb"):/etc/nginx/conf.d" nginx:1.27-alpine >/dev/null

until [ "$(docker inspect -f '{{.State.Health.Status}}' pm-blue)" = healthy ] \
   && [ "$(docker inspect -f '{{.State.Health.Status}}' pm-green)" = healthy ]; do sleep 3; done
sleep 30
for c in blue green green-broken; do echo "pm-$c: $(docker inspect -f '{{.State.Health.Status}}' "pm-$c")"; done
curl -s -i http://127.0.0.1:28090/health | grep -iE '^HTTP|X-Served-By'
