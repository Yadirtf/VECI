// Se importa antes que todo en main.ts para que Sentry instrumente NestJS (HU-01-07).
import * as Sentry from '@sentry/nestjs';
import { limpiarDatosPersonales } from '@veci/shared';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  enabled: Boolean(process.env.SENTRY_DSN),
  environment: process.env.VECI_ENTORNO ?? 'desarrollo',
  release: process.env.VECI_VERSION ?? process.env.RENDER_GIT_COMMIT,
  // Sin datos personales (Ley 1581): ni usuario, cookies, cabeceras, cuerpos, consultas,
  // parámetros SQL ni variables locales. limpiarDatosPersonales es la segunda red.
  dataCollection: {
    userInfo: false,
    cookies: false,
    httpHeaders: false,
    httpBodies: [],
    urlQueryParams: false,
    databaseQueryData: false,
    stackFrameVariables: false,
  },
  tracesSampleRate: Number(process.env.SENTRY_TRACES_SAMPLE_RATE ?? 0),
  beforeSend: (evento) => limpiarDatosPersonales(evento),
});
