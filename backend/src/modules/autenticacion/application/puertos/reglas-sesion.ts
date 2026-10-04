/** Duraciones de la sesión, leídas de la configuración. */
export interface ReglasSesion {
  segundosAcceso: number;
  diasSesion: number;
}

export const REGLAS_SESION = Symbol('ReglasSesion');

/** El paso de crear PIN nuevo dura 10 minutos. */
export const SEGUNDOS_CAMBIO_DE_PIN = 600;

/** Tipos de token que firma este módulo. */
export const TOKEN_ACCESO = 'acceso';
export const TOKEN_CAMBIO_DE_PIN = 'cambio-pin';
