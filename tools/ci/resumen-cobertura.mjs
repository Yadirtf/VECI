#!/usr/bin/env node
// Escribe la cobertura de pruebas como tabla en el resumen del CI (HU-01-02).
// Uso: node tools/ci/resumen-cobertura.mjs "Nombre=ruta/coverage-summary.json|ruta/lcov.info" ...
// Acepta resúmenes JSON de Jest/Vitest o archivos lcov (Flutter). Falla si el núcleo baja del 70 %.
import { appendFileSync, existsSync, readFileSync } from 'node:fs';

const META = 70;

function desdeJson(ruta) {
  const { total } = JSON.parse(readFileSync(ruta, 'utf8'));
  return { lineas: total.lines.pct, ramas: total.branches.pct, funciones: total.functions.pct };
}

function desdeLcov(ruta) {
  const contar = (prefijo) =>
    readFileSync(ruta, 'utf8')
      .split('\n')
      .filter((l) => l.startsWith(prefijo))
      .reduce((suma, l) => suma + Number(l.slice(prefijo.length)), 0);
  const pct = (hechas, total) => (total ? Math.round((hechas / total) * 10000) / 100 : 100);
  return {
    lineas: pct(contar('LH:'), contar('LF:')),
    ramas: pct(contar('BRH:'), contar('BRF:')),
    funciones: pct(contar('FNH:'), contar('FNF:')),
  };
}

const filas = [];
let bajoMeta = false;
for (const argumento of process.argv.slice(2)) {
  const [nombre, ruta] = argumento.split('=');
  if (!existsSync(ruta)) {
    filas.push(`| ${nombre} | sin datos | | | |`);
    continue;
  }
  const c = ruta.endsWith('.json') ? desdeJson(ruta) : desdeLcov(ruta);
  const nucleo = nombre.includes('(núcleo)');
  const ok = c.lineas >= META;
  if (nucleo && !ok) bajoMeta = true;
  filas.push(
    `| ${nombre} | ${c.lineas} % | ${c.ramas} % | ${c.funciones} % | ${ok ? '✅' : '⚠️'} |`,
  );
}

const tabla = [
  '### Cobertura de pruebas',
  '',
  `Meta del núcleo: ${META} % de líneas (RNF-MAN-01).`,
  '',
  '| Proyecto | Líneas | Ramas | Funciones | Meta |',
  '| --- | --- | --- | --- | --- |',
  ...filas,
  '',
].join('\n');

console.log(tabla);
if (process.env.GITHUB_STEP_SUMMARY) appendFileSync(process.env.GITHUB_STEP_SUMMARY, tabla);
if (bajoMeta) {
  console.error(`La cobertura del núcleo bajó del ${META} %.`);
  process.exit(1);
}
