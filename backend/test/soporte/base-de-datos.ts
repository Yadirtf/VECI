import { Client } from 'pg';

/** Conexión como dueño de los esquemas: solo para preparar datos de prueba. */
export async function conectarDueno(): Promise<Client> {
  const url = process.env.DATABASE_URL;
  if (!url) throw new Error('Defina DATABASE_URL (dueño) y DATABASE_APP_URL (veci_api)');
  const cliente = new Client({ connectionString: url });
  await cliente.connect();
  return cliente;
}

export function urlApp(): string {
  const url = process.env.DATABASE_APP_URL;
  if (!url) throw new Error('Defina DATABASE_APP_URL (usuario veci_api, con RLS)');
  return url;
}

/** Datos de un comercio creado para una prueba. */
export interface ComercioDePrueba {
  comercioId: string;
  usuarioId: string;
  sedeId: string;
  servicioId: string;
  afiliacionId: string;
}
