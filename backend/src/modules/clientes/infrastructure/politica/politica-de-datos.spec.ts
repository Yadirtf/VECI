import { createHash } from 'node:crypto';
import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { TEXTOS_POLITICA } from './prisma-politica.repository';

/** La huella que la migración publicó para cada versión. */
function huellasPublicadas(): Map<string, string> {
  const migraciones = join(__dirname, '../../../../../prisma/migrations');
  const huellas = new Map<string, string>();
  for (const carpeta of readdirSync(migraciones)) {
    if (carpeta.endsWith('.toml')) continue;
    const sql = readFileSync(join(migraciones, carpeta, 'migration.sql'), 'utf8');
    for (const [, version, huella] of sql.matchAll(
      /'([\d.]+)', '\/politica-de-datos',\s*'\\x([0-9a-f]{64})'/g,
    )) {
      huellas.set(version, huella);
    }
  }
  return huellas;
}

describe('Política de tratamiento de datos (HU-12-01)', () => {
  it('el texto de cada versión coincide con la huella publicada en la base', () => {
    const publicadas = huellasPublicadas();
    expect(publicadas.size).toBeGreaterThan(0);
    for (const [version, huella] of publicadas) {
      const texto = TEXTOS_POLITICA[version];
      expect(texto).toBeDefined();
      expect(createHash('sha256').update(JSON.stringify(texto)).digest('hex')).toBe(huella);
    }
  });

  it('cada sección trae su explicación en palabras de vecino', () => {
    for (const texto of Object.values(TEXTOS_POLITICA)) {
      expect(texto.enCorto.nuncaHacemos.length).toBeGreaterThan(0);
      for (const seccion of texto.secciones) {
        expect(seccion.enPalabrasDeVecino.length).toBeLessThan(seccion.texto.length);
      }
    }
  });
});
