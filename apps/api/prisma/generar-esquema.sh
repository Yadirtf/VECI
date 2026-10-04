#!/usr/bin/env bash
# Regenera prisma/schema.prisma introspectando una base ya migrada (DATABASE_URL).
# Con --verificar no escribe: falla si el esquema guardado quedó desactualizado.
set -euo pipefail
cd "$(dirname "$0")/.."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cp prisma/base.prisma "$TMP/schema.prisma"
npx prisma db pull --schema "$TMP/schema.prisma" --print > "$TMP/introspectado.prisma" 2> "$TMP/avisos.txt" || { cat "$TMP/avisos.txt" >&2; exit 1; }
node prisma/ajustar-esquema.mjs "$TMP/introspectado.prisma" "$TMP/final.prisma"

if [ "${1:-}" = "--verificar" ]; then
  if ! diff -u prisma/schema.prisma "$TMP/final.prisma"; then
    echo "prisma/schema.prisma no coincide con las migraciones. Ejecute: pnpm --filter @veci/api db:esquema" >&2
    exit 1
  fi
  echo "✔ prisma/schema.prisma coincide con las migraciones"
else
  cp "$TMP/final.prisma" prisma/schema.prisma
  echo "✔ prisma/schema.prisma regenerado"
fi
