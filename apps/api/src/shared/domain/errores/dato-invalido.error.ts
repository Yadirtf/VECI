import { ErrorDeDominio } from './error-de-dominio';

/** Un valor no cumple el formato o el rango que exige el negocio. */
export class DatoInvalido extends ErrorDeDominio {
  readonly codigo = 'DATO_INVALIDO';
  readonly tipo = 'regla-incumplida' as const;

  constructor(mensaje: string) {
    super(mensaje);
  }
}
