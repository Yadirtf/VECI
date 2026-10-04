// Genera los tokens del sistema de diseño VECI para el panel (CSS) y la app (Dart)
// desde tools/disenio/tokens.json, y comprueba el contraste de los colores (HU-01-09).
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { paresSinContraste } from './contraste.mjs';

const RAIZ = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const AVISO = 'Generado por tools/disenio/generar-tokens.mjs desde tokens.json. No editar a mano.';
const tokens = JSON.parse(readFileSync(join(RAIZ, 'tools/disenio/tokens.json'), 'utf8'));

const kebab = (nombre) => nombre.replace(/[A-Z]/g, (letra) => `-${letra.toLowerCase()}`);
const rem = (px) => `${px / 16}rem`;

function generarCss() {
  const lineas = [
    ...Object.entries(tokens.color).map(([n, v]) => `  --color-${kebab(n)}: ${v};`),
    ...Object.entries(tokens.texto).map(([n, v]) => `  --text-${kebab(n)}: ${rem(v)};`),
    ...Object.entries(tokens.peso).map(([n, v]) => `  --font-weight-${kebab(n)}: ${v};`),
    ...Object.entries(tokens.radio).map(([n, v]) => `  --radius-${kebab(n)}: ${v}px;`),
    ...Object.entries(tokens.espacio).map(([n, v]) => `  --spacing-${kebab(n)}: ${rem(v)};`),
    ...Object.entries(tokens.toque).map(([n, v]) => `  --spacing-toque-${kebab(n)}: ${rem(v)};`),
  ];
  return `/* ${AVISO} */\n@theme {\n${lineas.join('\n')}\n}\n`;
}

function claseDart(nombre, tipo, valores, formato) {
  const campos = Object.entries(valores)
    .filter(([n]) => !n.startsWith('$'))
    .map(([n, v]) => `  static const ${tipo} ${n} = ${formato(v)};`);
  return `abstract final class ${nombre} {\n${campos.join('\n')}\n}\n`;
}

function generarDart() {
  const color = (hex) => `Color(0xFF${hex.slice(1).toUpperCase()})`;
  const numero = (v) => `${v}.0`;
  return [
    `// ${AVISO}`,
    `import 'package:flutter/painting.dart';\n`,
    claseDart('VeciColores', 'Color', tokens.color, color),
    claseDart('VeciTexto', 'double', tokens.texto, numero),
    claseDart('VeciPeso', 'FontWeight', tokens.peso, (v) => `FontWeight.w${v}`),
    claseDart('VeciEspacio', 'double', tokens.espacio, numero),
    claseDart('VeciRadio', 'double', tokens.radio, numero),
    claseDart('VeciToque', 'double', tokens.toque, numero),
  ].join('\n');
}

const fallas = paresSinContraste(tokens.color, tokens.contraste.pares);
if (fallas.length > 0) {
  for (const f of fallas) {
    console.error(`✘ ${f.texto} sobre ${f.fondo}: ${f.valor.toFixed(2)} (mínimo ${f.minimo})`);
  }
  process.exit(1);
}
writeFileSync(join(RAIZ, 'apps/web/src/shared/ui/tokens.css'), generarCss());
writeFileSync(join(RAIZ, 'apps/mobile/lib/core/theme/veci_tokens.dart'), generarDart());
console.log(
  `✔ Tokens de diseño generados; ${tokens.contraste.pares.length} pares de contraste cumplen`,
);
