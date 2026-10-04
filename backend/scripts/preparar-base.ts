// Se ejecuta al arrancar el contenedor, después de `prisma migrate deploy` (HU-01-08):
// 1. Crea o actualiza el usuario veci_api (miembro de veci_app, sujeto a RLS) con la clave
//    de VECI_API_DB_PASSWORD. Así un entorno nuevo no necesita pasos manuales en la base.
// 2. Si VECI_SEMBRAR_DEMO=true (nunca en producción), carga los datos de ejemplo.
// Usa DATABASE_URL, el dueño de los esquemas.
import { Client } from 'pg';
import { sembrarDemo } from '../prisma/semillas/sembrar-demo';

async function asegurarUsuarioApi(cliente: Client, clave: string): Promise<void> {
  const literal = cliente.escapeLiteral(clave);
  const { rowCount } = await cliente.query(`SELECT 1 FROM pg_roles WHERE rolname = 'veci_api'`);
  const orden = rowCount
    ? `ALTER ROLE veci_api LOGIN NOBYPASSRLS PASSWORD ${literal}`
    : `CREATE ROLE veci_api LOGIN NOBYPASSRLS PASSWORD ${literal} IN ROLE veci_app`;
  await cliente.query(orden);
  console.log('✔ Usuario veci_api listo');
}

async function preparar(): Promise<void> {
  const cliente = new Client({ connectionString: process.env.DATABASE_URL });
  await cliente.connect();
  try {
    const clave = process.env.VECI_API_DB_PASSWORD;
    if (clave) await asegurarUsuarioApi(cliente, clave);
    const sembrar = process.env.VECI_SEMBRAR_DEMO === 'true';
    if (sembrar && process.env.VECI_ENTORNO !== 'produccion') await sembrarDemo(cliente);
  } finally {
    await cliente.end();
  }
}

preparar().catch((error: unknown) => {
  console.error(error);
  process.exit(1);
});
