// Carga los datos de ejemplo (HU-01-03): comercio demo, cajero, clienta y tiqueteras.
// Uso: pnpm --filter @veci/api db:semilla   (usa DATABASE_URL, el dueño de los esquemas)
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { Client } from 'pg';

const ARCHIVOS = ['demo.sql', 'demo-comercios.sql', 'demo-movimientos.sql'];

async function sembrar(): Promise<void> {
  if (process.env.VECI_ENTORNO === 'produccion') {
    throw new Error('Los datos de ejemplo nunca se cargan en producción.');
  }
  const cliente = new Client({ connectionString: process.env.DATABASE_URL });
  await cliente.connect();
  try {
    await cliente.query('BEGIN');
    for (const archivo of ARCHIVOS) {
      await cliente.query(readFileSync(join(__dirname, archivo), 'utf8'));
    }
    await cliente.query('COMMIT');
    console.log('✔ Datos de ejemplo listos: Restaurante La Vecina y Panadería El Trigal');
  } catch (error) {
    await cliente.query('ROLLBACK');
    throw error;
  } finally {
    await cliente.end();
  }
}

sembrar().catch((error: unknown) => {
  console.error(error);
  process.exit(1);
});
