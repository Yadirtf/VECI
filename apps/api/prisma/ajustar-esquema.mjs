// Ajusta el esquema que produce `prisma db pull` para que Prisma lo acepte (HU-01-04).
// Las relaciones cuya llave es un índice único parcial (vigente mientras revoked_at IS NULL)
// o una llave compuesta (tenant_id, id) se declaran como listas: la base guarda la historia
// y Prisma no admite uno a uno sobre esas llaves. No cambia la base de datos.
// Uso: node prisma/ajustar-esquema.mjs <entrada> <salida>
import { readFileSync, writeFileSync } from 'node:fs';

const RELACIONES_COMO_LISTA = [
  ['affiliations', 'affiliation_qr_codes'],
  ['affiliations', 'balance_links'],
  ['people', 'personal_qr_codes'],
  ['consumptions', 'consumption_overrides'],
  ['events', 'other_events'],
];

const ENCABEZADO = `// Generado con \`pnpm --filter @veci/api db:esquema\` desde la base migrada.
// No editar a mano: la fuente es prisma/migrations (y el DDL de docs/arquitectura/modelo-datos/sql).
`;

function convertirEnLista(esquema, modelo, campo) {
  const bloque = new RegExp(`(model ${modelo} \\{[\\s\\S]*?\\n\\})`);
  const coincidencia = esquema.match(bloque);
  if (!coincidencia) throw new Error(`No existe el modelo ${modelo}`);
  const campoOpcional = new RegExp(`(\\n  ${campo}\\s+)(\\w+)\\?`);
  if (!campoOpcional.test(coincidencia[1])) throw new Error(`No existe ${modelo}.${campo}?`);
  const ajustado = coincidencia[1].replace(campoOpcional, '$1$2[]');
  return esquema.replace(coincidencia[1], ajustado);
}

const [entrada, salida] = process.argv.slice(2);
let esquema = readFileSync(entrada, 'utf8');
for (const [modelo, campo] of RELACIONES_COMO_LISTA) {
  esquema = convertirEnLista(esquema, modelo, campo);
}
writeFileSync(salida, ENCABEZADO + esquema.replace(/\s+$/, '') + '\n');
