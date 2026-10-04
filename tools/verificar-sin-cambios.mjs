#!/usr/bin/env node
// Falla si algún archivo generado (contrato OpenAPI, clientes, tokens, esquema Prisma)
// quedó distinto de lo que hay en el repositorio. Se ejecuta después de `pnpm generar`.
import { execFileSync } from 'node:child_process';

const GENERADOS = [
  'packages/api-client/openapi.json',
  'packages/api-client/src/esquema.ts',
  'apps/mobile/packages/veci_api',
  'apps/web/src/shared/ui/tokens.css',
  'apps/mobile/lib/core/theme/veci_tokens.dart',
  'apps/api/prisma/schema.prisma',
];

const salida = execFileSync('git', ['status', '--porcelain', '--', ...GENERADOS], {
  encoding: 'utf8',
}).trim();

if (salida) {
  console.error('Hay código generado desactualizado:\n' + salida);
  console.error('\nEjecute `pnpm generar` y suba los cambios.');
  execFileSync('git', ['--no-pager', 'diff', '--stat', '--', ...GENERADOS], { stdio: 'inherit' });
  process.exit(1);
}
console.log('✔ El código generado está al día con el contrato y los tokens.');
