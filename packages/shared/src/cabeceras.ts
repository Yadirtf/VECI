/**
 * Cabeceras HTTP del contrato entre la API, el panel y la app (HU-01-05).
 * El comercio activo viaja en cada petición; la API comprueba que el usuario
 * trabaja en ese comercio antes de fijarlo como contexto de la base de datos.
 */
export const CABECERA_COMERCIO = 'x-veci-comercio';

/**
 * Solo en desarrollo y staging, mientras llega el inicio de sesión (EP-02):
 * identifica al usuario sin token. En producción la API la ignora.
 */
export const CABECERA_USUARIO_DESARROLLO = 'x-veci-usuario';
