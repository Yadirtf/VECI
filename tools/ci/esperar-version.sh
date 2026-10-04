#!/usr/bin/env bash
# Espera hasta que /salud responda "ok" con la versión (commit) recién desplegada.
# Uso: esperar-version.sh <url-salud> <sha> [minutos]
set -euo pipefail
URL="$1"
SHA="$2"
LIMITE=$(( $(date +%s) + ${3:-15} * 60 ))

while [ "$(date +%s)" -lt "$LIMITE" ]; do
  RESPUESTA="$(curl -fsS --max-time 30 "$URL" 2>/dev/null || true)"
  if echo "$RESPUESTA" | grep -q "\"version\":\"$SHA\"" && echo "$RESPUESTA" | grep -q '"estado":"ok"'; then
    echo "✔ $URL responde con la versión $SHA"
    exit 0
  fi
  echo "… esperando el despliegue ($RESPUESTA)"
  sleep 20
done
echo "::error::La API no respondió con la versión $SHA a tiempo" >&2
exit 1
