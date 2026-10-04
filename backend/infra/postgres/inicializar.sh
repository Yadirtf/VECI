#!/usr/bin/env bash
# Primer arranque del contenedor de PostgreSQL local: crea los roles de conexión.
set -euo pipefail
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -v clave_api="${VECI_API_DB_PASSWORD:-veci_api}" -f /veci/crear-roles.sql
