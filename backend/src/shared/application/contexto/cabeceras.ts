/**
 * Cabeceras HTTP del contrato entre la API, el panel y la app (HU-01-05).
 * El comercio activo viaja en cada petición; la API comprueba que el usuario
 * trabaja en ese comercio antes de fijarlo como contexto de la base de datos.
 */
export const CABECERA_COMERCIO = 'x-veci-comercio';

/**
 * Solo en desarrollo local y pruebas automáticas: identifica al usuario sin token.
 * Desde EP-02 staging y producción la ignoran; ahí se entra con celular y PIN.
 */
export const CABECERA_USUARIO_DESARROLLO = 'x-veci-usuario';
