#!/usr/bin/env bash
# Regenera packages/veci_api (cliente Dart) desde docs/api/openapi.json (HU-01-06).
# Requiere Node (npx) y Java 17+. Uso (desde mobile/): bash tool/generar_cliente.sh
set -euo pipefail
cd "$(dirname "$0")/.."
npx --yes @openapitools/openapi-generator-cli@2.41.0 generate --generator-key dart
