// Carga los datos de ejemplo (HU-01-03): comercio demo, cajero, clienta y tiqueteras.
// Uso: pnpm db:semilla   (usa DATABASE_URL, el dueño de los esquemas). Es idempotente.
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { Client } from 'pg';

const ARCHIVOS = ['demo.sql', 'demo-comercios.sql', 'demo-movimientos.sql', 'demo-acceso.sql'];

/** Carga la semilla en una sola transacción con un cliente ya conectado. */
export async function sembrarDemo(cliente: Client): Promise<void> {
  if (process.env.VECI_ENTORNO === 'produccion') {
    throw new Error('Los datos de ejemplo nunca se cargan en producción.');
  }
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
  }
}

async function principal(): Promise<void> {
  const cliente = new Client({ connectionString: process.env.DATABASE_URL });
  await cliente.connect();
  try {
    await sembrarDemo(cliente);
  } finally {
    await cliente.end();
  }
}

if (require.main === module) {
  principal().catch((error: unknown) => {
    console.error(error);
    process.exit(1);
  });
}
