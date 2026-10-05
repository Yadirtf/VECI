import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

/** El PIN de bienvenida o temporal se entregó hace más de una semana (EP-04). */
export class PinTemporalVencido extends ErrorDeDominio {
  readonly codigo = 'PIN_TEMPORAL_VENCIDO';
  readonly tipo = 'no-autenticado' as const;

  constructor() {
    super('Ese PIN de bienvenida ya venció, veci. Pide uno nuevo en el negocio.');
  }
}
