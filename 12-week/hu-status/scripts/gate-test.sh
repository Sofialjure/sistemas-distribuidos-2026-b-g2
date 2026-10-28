#!/bin/bash
# The switch must refuse a color whose readiness check fails, and leave traffic where it was.
W=$(dirname "$0"); LB=http://127.0.0.1:28090
cp "$W/lb/green.inc" "$W/lb/green-broken.inc"; sed -i 's/pm-green:8080/pm-green-broken:8080/; s/green eeb08c7/green-broken eeb08c7/' "$W/lb/green-broken.inc"
color=green-broken
before=$(curl -s -D - -o /dev/null "$LB/health" | grep -i x-served-by | tr -d '\r')
if [ "$(docker inspect -f '{{.State.Health.Status}}' pm-$color)" != healthy ]; then
  echo "ABORT: pm-$color is $(docker inspect -f '{{.State.Health.Status}}' pm-$color); no switch"
else
  cp "$W/lb/$color.inc" "$W/lb/active.inc"; docker exec pm-lb nginx -s reload
fi
after=$(curl -s -D - -o /dev/null "$LB/health" | grep -i x-served-by | tr -d '\r')
echo "before: $before | after: $after"
