import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

/** El paso para crear el PIN nuevo se venció o ya se usó (HU-02-05). */
export class CambioDePinNoValido extends ErrorDeDominio {
  readonly codigo = 'CAMBIO_DE_PIN_NO_VALIDO';
  readonly tipo = 'no-autenticado' as const;

  constructor() {
    super('Este paso se venció. Vuelve a entrar con el PIN temporal, veci.');
  }
}
