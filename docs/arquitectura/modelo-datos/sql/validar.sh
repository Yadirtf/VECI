#!/usr/bin/env bash
# Valida el modelo de referencia en un PostgreSQL desechable:
# crea un clúster temporal, aplica todos los .sql en orden y corre la prueba de humo.
# Uso: ./validar.sh            (requiere binarios de PostgreSQL 16+ en PATH o PG_BIN)
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PG_BIN="${PG_BIN:-$(dirname "$(command -v initdb 2>/dev/null || ls /usr/lib/postgresql/*/bin/initdb | tail -1)")}"
PORT="${PORT:-54329}"
DATA="$(mktemp -d)"
trap '"$PG_BIN/pg_ctl" -D "$DATA" -m immediate stop >/dev/null 2>&1 || true; rm -rf "$DATA"' EXIT

if [ "$(id -u)" = "0" ]; then
  echo "Ejecute este script con un usuario distinto de root (PostgreSQL no arranca como root)." >&2
  exit 1
fi

"$PG_BIN/initdb" -D "$DATA" -U postgres -A trust >/dev/null
"$PG_BIN/pg_ctl" -D "$DATA" -o "-p $PORT -k $DATA -c listen_addresses=''" -l "$DATA/log" -w start >/dev/null

PSQL=(psql -X -q -v ON_ERROR_STOP=1 -h "$DATA" -p "$PORT" -U postgres)
"${PSQL[@]}" -d postgres -c "CREATE DATABASE veci"

for f in "$DIR"/[0-9][0-9]_*.sql; do
  case "$(basename "$f")" in 9*) continue ;; esac
  echo "→ $(basename "$f")"
  "${PSQL[@]}" -d veci -f "$f"
done

echo "→ pruebas de humo"
"${PSQL[@]}" -d veci -f "$DIR/90_prueba_de_humo.sql"
echo "✔ Modelo válido"
