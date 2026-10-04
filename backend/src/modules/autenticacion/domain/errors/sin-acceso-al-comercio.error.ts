import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

/** El comercio elegido no está entre los espacios del usuario (HU-02-03). */
export class SinAccesoAlComercio extends ErrorDeDominio {
  readonly codigo = 'SIN_ACCESO_AL_COMERCIO';
  readonly tipo = 'prohibido' as const;

  constructor() {
    super('No tienes acceso a este negocio.');
  }
}
