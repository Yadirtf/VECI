// Genera los tokens del sistema de diseño VECI para el panel (variables de Tailwind)
// desde docs/diseno/tokens.json, y comprueba el contraste de los colores (HU-01-09).
// La app móvil tiene su propio generador (mobile/tool/generar_tokens.dart).
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { paresSinContraste } from './contraste.mjs';

const WEB = join(dirname(fileURLToPath(import.meta.url)), '..');
const AVISO =
  'Generado por scripts/generar-tokens.mjs desde docs/diseno/tokens.json. No editar a mano.';
const tokens = JSON.parse(readFileSync(join(WEB, '..', 'docs', 'diseno', 'tokens.json'), 'utf8'));

const kebab = (nombre) => nombre.replace(/[A-Z]/g, (letra) => `-${letra.toLowerCase()}`);
const rem = (px) => `${px / 16}rem`;
const valores = (grupo) => Object.entries(grupo).filter(([n]) => !n.startsWith('$'));

function generarCss() {
  const lineas = [
    ...Object.entries(tokens.color).map(([n, v]) => `  --color-${kebab(n)}: ${v};`),
    ...Object.entries(tokens.texto).map(([n, v]) => `  --text-${kebab(n)}: ${rem(v)};`),
    ...Object.entries(tokens.peso).map(([n, v]) => `  --font-weight-${kebab(n)}: ${v};`),
    ...Object.entries(tokens.radio).map(([n, v]) => `  --radius-${kebab(n)}: ${v}px;`),
    ...Object.entries(tokens.espacio).map(([n, v]) => `  --spacing-${kebab(n)}: ${rem(v)};`),
    ...Object.entries(tokens.toque).map(([n, v]) => `  --spacing-toque-${kebab(n)}: ${rem(v)};`),
    ...valores(tokens.forma).map(([n, v]) => `  --forma-${kebab(n)}: ${v}px;`),
  ];
  return `/* ${AVISO} */\n@theme {\n${lineas.join('\n')}\n}\n`;
}

const fallas = paresSinContraste(tokens.color, tokens.contraste.pares);
if (fallas.length > 0) {
  for (const f of fallas) {
    console.error(`✘ ${f.texto} sobre ${f.fondo}: ${f.valor.toFixed(2)} (mínimo ${f.minimo})`);
  }
  process.exit(1);
}
writeFileSync(join(WEB, 'src', 'shared', 'ui', 'tokens.css'), generarCss());
console.log(
  `✔ Tokens de diseño generados; ${tokens.contraste.pares.length} pares de contraste cumplen`,
);
