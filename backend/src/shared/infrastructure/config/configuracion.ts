/** Entornos en los que corre la API. */
export type Entorno = 'desarrollo' | 'pruebas' | 'staging' | 'produccion';

const ENTORNOS: readonly Entorno[] = ['desarrollo', 'pruebas', 'staging', 'produccion'];

/** Configuración de la API, leída una sola vez de las variables de entorno. */
export interface Configuracion {
  readonly entorno: Entorno;
  readonly puerto: number;
  /** Conexión con el usuario veci_api (miembro de veci_app, sujeto a RLS). */
  readonly databaseAppUrl: string;
  /** Publica el contrato OpenAPI en /docs (dev y staging, HU-01-06). */
  readonly documentacionActiva: boolean;
  /** Acepta la cabecera de usuario de desarrollo mientras llega EP-02. Nunca en producción. */
  readonly identidadDesarrollo: boolean;
  readonly origenesPermitidos: readonly string[];
  readonly version: string;
}

export const CONFIGURACION = Symbol('Configuracion');

type Variables = Readonly<Record<string, string | undefined>>;

function leerEntorno(valor: string | undefined): Entorno {
  const entorno = (valor ?? 'desarrollo') as Entorno;
  if (!ENTORNOS.includes(entorno)) {
    throw new Error(`VECI_ENTORNO inválido: "${valor}". Use ${ENTORNOS.join(', ')}.`);
  }
  return entorno;
}

function leerBooleano(valor: string | undefined, porDefecto: boolean): boolean {
  return valor === undefined ? porDefecto : valor === 'true';
}

/** Usuario de la API: miembro de veci_app y sujeto a RLS (HU-01-05). */
export const USUARIO_API = 'veci_api';

/**
 * Sin DATABASE_APP_URL, la arma con la base de DATABASE_URL y la clave de veci_api
 * (VECI_API_DB_PASSWORD), que es como la entrega el blueprint de Render.
 */
function urlDesdeDueno(variables: Variables): string | undefined {
  const { DATABASE_URL: dueno, VECI_API_DB_PASSWORD: clave } = variables;
  if (!dueno || !clave) return undefined;
  const url = new URL(dueno);
  url.username = USUARIO_API;
  url.password = clave;
  return url.toString();
}

function leerUrlBaseDatos(variables: Variables, entorno: Entorno): string {
  const url = variables.DATABASE_APP_URL ?? urlDesdeDueno(variables);
  if (url) return url;
  if (entorno === 'staging' || entorno === 'produccion') {
    throw new Error('Falta DATABASE_APP_URL o VECI_API_DB_PASSWORD (usuario veci_api).');
  }
  return 'postgresql://veci_api:veci_api@localhost:5432/veci';
}

export function leerConfiguracion(variables: Variables = process.env): Configuracion {
  const entorno = leerEntorno(variables.VECI_ENTORNO);
  const esProduccion = entorno === 'produccion';
  return {
    entorno,
    puerto: Number(variables.PORT ?? 3000),
    databaseAppUrl: leerUrlBaseDatos(variables, entorno),
    documentacionActiva: !esProduccion && leerBooleano(variables.VECI_DOCS, true),
    identidadDesarrollo: !esProduccion && leerBooleano(variables.VECI_IDENTIDAD_DESARROLLO, true),
    origenesPermitidos: (variables.VECI_ORIGENES ?? 'http://localhost:3001').split(','),
    version: variables.VECI_VERSION ?? variables.RENDER_GIT_COMMIT ?? 'local',
  };
}
