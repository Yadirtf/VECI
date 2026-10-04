#!/usr/bin/env bash
# Comprueba que las migraciones de Prisma producen exactamente la base del DDL de referencia
# (docs/arquitectura/modelo-datos/sql) y que la prueba de humo pasa sobre la base migrada.
# Uso: bash prisma/verificar-migraciones.sh   (PostgreSQL 16+ en PATH o PG_BIN; no correr como root)
set -euo pipefail

API="$(cd "$(dirname "$0")/.." && pwd)"
REF="$API/../docs/arquitectura/modelo-datos/sql"
PG_BIN="${PG_BIN:-$(dirname "$(command -v initdb 2>/dev/null || ls /usr/lib/postgresql/*/bin/initdb | tail -1)")}"
PORT="${PORT:-54330}"
DATA="$(mktemp -d)"
trap '"$PG_BIN/pg_ctl" -D "$DATA" -m immediate stop >/dev/null 2>&1 || true; rm -rf "$DATA"' EXIT

if [ "$(id -u)" = "0" ]; then
  echo "Ejecute este script con un usuario distinto de root (PostgreSQL no arranca como root)." >&2
  exit 1
fi

"$PG_BIN/initdb" -D "$DATA" -U postgres -A trust >/dev/null
"$PG_BIN/pg_ctl" -D "$DATA" -o "-p $PORT -k $DATA -c listen_addresses=''" -l "$DATA/log" -w start >/dev/null
PSQL=(psql -X -q -v ON_ERROR_STOP=1 -h "$DATA" -p "$PORT" -U postgres)
"${PSQL[@]}" -d postgres -c "CREATE DATABASE referencia" -c "CREATE DATABASE migrada"

echo "→ DDL de referencia"
for f in "$REF"/[0-9][0-9]_*.sql; do
  case "$(basename "$f")" in 9*) continue ;; esac
  "${PSQL[@]}" -d referencia -f "$f" >/dev/null
done

echo "→ migraciones de Prisma"
for f in "$API"/prisma/migrations/*/migration.sql; do
  echo "  $(basename "$(dirname "$f")")"
  "${PSQL[@]}" -d migrada -f "$f" >/dev/null
done

echo "→ comparando estructura y catálogos"
volcar() { "$PG_BIN/pg_dump" -h "$DATA" -p "$PORT" -U postgres --no-owner -d "$1"; }
# Se ignoran los valores que cambian en cada ejecución: ids UUID v7 y fechas de creación.
normalizar() {
  grep -v -e '^-- Dumped' -e '^\\restrict' -e '^\\unrestrict' \
    | sed -E -e 's/[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}/<uuid>/g' \
             -e 's/[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9.]+\+00/<fecha>/g'
}
volcar referencia | normalizar > "$DATA/referencia.sql"
volcar migrada | normalizar > "$DATA/migrada.sql"
if ! diff -u "$DATA/referencia.sql" "$DATA/migrada.sql" > "$DATA/diferencias.txt"; then
  head -80 "$DATA/diferencias.txt"
  echo "✘ Las migraciones y el DDL de referencia ya no producen la misma base." >&2
  echo "  Actualice ambos: una migración nueva y el archivo del módulo en docs/arquitectura/modelo-datos/sql." >&2
  exit 1
fi

echo "→ prueba de humo sobre la base migrada"
"${PSQL[@]}" -d migrada -f "$REF/90_prueba_de_humo.sql" >/dev/null
echo "✔ Migraciones equivalentes al modelo de referencia y prueba de humo en verde"
