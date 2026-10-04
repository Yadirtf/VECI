/**
 * Cabeceras HTTP que exige la API (ver docs/api/openapi.json, HU-01-05).
 * El comercio activo viaja en cada petición que trabaja con datos de un negocio.
 */
export const CABECERA_COMERCIO = 'x-veci-comercio';

/** Solo desarrollo y staging, mientras llega el inicio de sesión (EP-02). */
export const CABECERA_USUARIO_DESARROLLO = 'x-veci-usuario';
