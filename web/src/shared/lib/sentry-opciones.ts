import { limpiarDatosPersonales } from './limpiar-datos-personales';

/**
 * Opciones de Sentry comunes al navegador y al servidor del panel (HU-01-07):
 * versión y entorno, sin datos personales (Ley 1581). El comercio activo lo etiqueta
 * la sesión al elegirlo.
 */
export function opcionesSentry(dsn: string | undefined) {
  const sinCuerpos: [] = [];
  return {
    dsn,
    enabled: Boolean(dsn),
    environment: process.env.NEXT_PUBLIC_VECI_ENTORNO ?? 'desarrollo',
    release: process.env.NEXT_PUBLIC_VECI_VERSION,
    tracesSampleRate: 0,
    dataCollection: {
      userInfo: false,
      cookies: false,
      httpHeaders: false,
      httpBodies: sinCuerpos,
      urlQueryParams: false,
    },
    beforeSend: limpiarDatosPersonales,
  };
}
