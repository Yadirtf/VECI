import { limpiarDatosPersonales } from './limpiar-datos-personales';
import { entorno } from '../config/entorno';

/**
 * Opciones de Sentry comunes al navegador y al servidor del panel (HU-01-07):
 * versión, entorno y comercio, sin datos personales (Ley 1581).
 */
export function opcionesSentry(dsn: string | undefined) {
  const sinCuerpos: [] = [];
  return {
    dsn,
    enabled: Boolean(dsn),
    environment: process.env.NEXT_PUBLIC_VECI_ENTORNO ?? 'desarrollo',
    release: process.env.NEXT_PUBLIC_VECI_VERSION,
    tracesSampleRate: 0,
    // Hasta EP-02 el panel trabaja con un solo comercio; luego se etiqueta el de la sesión.
    initialScope: { tags: { comercio: entorno.comercioDemoId } },
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
