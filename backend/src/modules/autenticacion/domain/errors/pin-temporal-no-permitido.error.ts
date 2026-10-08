import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

/** El PIN temporal abriría una cuenta que llega más allá de quien lo pide. */
export class PinTemporalNoPermitido extends ErrorDeDominio {
  readonly codigo = 'PIN_TEMPORAL_NO_PERMITIDO';
  readonly tipo = 'prohibido' as const;

  constructor(mensaje: string) {
    super(mensaje);
  }
}
