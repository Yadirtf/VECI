#!/usr/bin/env node
// Falla si alguno de los archivos generados que se pasan como argumento quedó distinto
// de lo que hay en el repositorio. Se ejecuta en CI después de regenerarlos.
// Uso: node .github/scripts/verificar-sin-cambios.mjs <ruta> [<ruta>...]
import { execFileSync } from 'node:child_process';

const rutas = process.argv.slice(2);
if (rutas.length === 0) {
  console.error('Indique las rutas generadas que se deben comprobar.');
  process.exit(2);
}

const salida = execFileSync('git', ['status', '--porcelain', '--', ...rutas], {
  encoding: 'utf8',
}).trim();

if (salida) {
  console.error('Hay código generado desactualizado:\n' + salida);
  console.error('\nRegenérelo (ver el README de la carpeta) y suba los cambios.');
  execFileSync('git', ['--no-pager', 'diff', '--stat', '--', ...rutas], { stdio: 'inherit' });
  process.exit(1);
}
console.log('✔ El código generado está al día: ' + rutas.join(', '));
