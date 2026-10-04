/** Lo que la API responde cuando algo sale mal (RespuestaErrorDto). */
export interface ProblemaApi {
  codigo: string;
  mensaje: string;
}

const SIN_CONEXION: ProblemaApi = {
  codigo: 'SIN_CONEXION',
  mensaje: 'No pudimos conectarnos. Revisa el internet e intenta otra vez.',
};

const INESPERADO: ProblemaApi = {
  codigo: 'INESPERADO',
  mensaje: 'Algo no salió bien de nuestro lado. Intenta otra vez en un momento.',
};

/** Convierte el cuerpo de error de la API en un mensaje que la persona entiende. */
export function leerProblema(error: unknown): ProblemaApi {
  if (!error || typeof error !== 'object') return INESPERADO;
  const { codigo = 'DATOS_INVALIDOS', message } = error as { codigo?: unknown; message?: unknown };
  const mensaje = Array.isArray(message) ? message.join(' ') : message;
  if (typeof codigo === 'string' && typeof mensaje === 'string') return { codigo, mensaje };
  return INESPERADO;
}

export const problemaSinConexion = (): ProblemaApi => SIN_CONEXION;
