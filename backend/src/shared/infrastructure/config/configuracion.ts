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
  /** Acepta la cabecera x-veci-usuario sin token. Solo en desarrollo y pruebas. */
  readonly identidadDesarrollo: boolean;
  /** Secreto HS256 de los tokens de acceso (VECI_TOKENS_SECRETO, 32+ caracteres). */
  readonly secretoTokens: string;
  /** Secreto maestro del que salen las claves Ed25519 de los QR (VECI_QR_SECRETO, ADR-0017). */
  readonly secretoQr: string;
  /** Vida del token de acceso: 15 minutos (HU-02-01). */
  readonly segundosAcceso: number;
  /** Días que dura una sesión sin usarse; cada renovación la extiende (HU-02-06). */
  readonly diasSesion: number;
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

const SECRETO_DESARROLLO = 'secreto-de-desarrollo-solo-para-local-0123456789';
const SECRETO_QR_DESARROLLO = 'secreto-qr-de-desarrollo-solo-para-local-0123456789';

/** Secreto de 32+ caracteres; en staging y producción es obligatorio. */
function leerSecreto(
  variables: Variables,
  entorno: Entorno,
  nombre: string,
  paraQue: string,
): string | undefined {
  const secreto = variables[nombre];
  if (secreto && secreto.length >= 32) return secreto;
  if (entorno === 'staging' || entorno === 'produccion') {
    throw new Error(`Falta ${nombre} (32 caracteres o más) para ${paraQue}.`);
  }
  return undefined;
}

export function leerConfiguracion(variables: Variables = process.env): Configuracion {
  const entorno = leerEntorno(variables.VECI_ENTORNO);
  const esProduccion = entorno === 'produccion';
  const esLocal = entorno === 'desarrollo' || entorno === 'pruebas';
  return {
    entorno,
    puerto: Number(variables.PORT ?? 3000),
    databaseAppUrl: leerUrlBaseDatos(variables, entorno),
    documentacionActiva: !esProduccion && leerBooleano(variables.VECI_DOCS, true),
    identidadDesarrollo: esLocal && leerBooleano(variables.VECI_IDENTIDAD_DESARROLLO, true),
    secretoTokens:
      leerSecreto(variables, entorno, 'VECI_TOKENS_SECRETO', 'firmar las sesiones') ??
      SECRETO_DESARROLLO,
    secretoQr:
      leerSecreto(variables, entorno, 'VECI_QR_SECRETO', 'firmar los QR') ?? SECRETO_QR_DESARROLLO,
    segundosAcceso: Number(variables.VECI_SEGUNDOS_ACCESO ?? 900),
    diasSesion: Number(variables.VECI_DIAS_SESION ?? 30),
    origenesPermitidos: (variables.VECI_ORIGENES ?? 'http://localhost:3001').split(','),
    version: variables.VECI_VERSION ?? variables.RENDER_GIT_COMMIT ?? 'local',
  };
}
