#!/bin/bash
# Writes probe.env with the tokens the security probes need: valid ones signed with the
# platform's development key, and the negative cases (another key, expired, alg none, tampered).
# Usage: mint-tokens.sh <dev private key> <admin token file> <professional id> <document id> <owner patient id>
# Use only a development key of a local platform. probe.env holds live tokens: keep it out of git.
KEY=$1; ADMIN_FILE=$2; PROF_ID=$3; DOC_ID=$4; PA=$5; W=$(cd "$(dirname "$0")" && pwd)
b64() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }
uuid() { python -I -c 'import uuid; print(uuid.uuid4())'; }
[ -f "$W/other.pem" ] || openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "$W/other.pem" 2>/dev/null
claims() { printf '{"iss":"telemed-ia-identity-and-access","sub":"%s","role":"%s","iat":%d,"exp":%d}' "$1" "$2" "$now" "$3"; }
mint() {  # mint <key> <sub> <role> <exp>
  local h p
  h=$(printf '{"alg":"RS256","typ":"JWT"}' | b64); p=$(claims "$2" "$3" "$4" | b64)
  echo "$h.$p.$(printf '%s.%s' "$h" "$p" | openssl dgst -sha256 -sign "$1" | b64)"
}
now=$(date +%s); later=$((now + 900))
patient_a=$(mint "$KEY" "$PA" PATIENT $later)
{
  echo "ADMIN=$(cat "$ADMIN_FILE")"
  echo "PATIENT_A=$patient_a"
  echo "PATIENT_B=$(mint "$KEY" "$(uuid)" PATIENT $later)"
  echo "PROFESSIONAL=$(mint "$KEY" "$(uuid)" PROFESSIONAL $later)"
  echo "EXPIRED=$(mint "$KEY" admin-probe ADMIN $((now - 60)))"
  echo "FORGED=$(mint "$W/other.pem" admin-probe ADMIN $later)"
  echo "ROGUE_SERVICE=$(mint "$KEY" rogue-client SERVICE $later)"
  echo "NONE=$(printf '{"alg":"none","typ":"JWT"}' | b64).$(printf '{"sub":"x","role":"ADMIN","exp":%d}' $later | b64)."
  # a real patient token whose payload says ADMIN, without signing it again
  echo "TAMPERED=${patient_a%%.*}.$(claims "$PA" ADMIN $later | b64).${patient_a##*.}"
  echo "PROF_ID=$PROF_ID"
  echo "DOC_ID=$DOC_ID"
} > "$W/probe.env"
echo "wrote $W/probe.env ($(wc -l < "$W/probe.env") lines)"
