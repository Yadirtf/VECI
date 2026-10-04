import * as Sentry from '@sentry/nestjs';
import { Observabilidad } from '../../application/puertos/observabilidad.port';

/** Etiqueta los errores de la petición con el comercio (un id, no un dato personal). */
export class SentryObservabilidad implements Observabilidad {
  etiquetarComercio(comercioId: string): void {
    Sentry.getIsolationScope().setTag('comercio', comercioId);
  }
}
