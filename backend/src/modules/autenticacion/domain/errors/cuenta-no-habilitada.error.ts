import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

/** El usuario está suspendido o cerrado por VECI. */
export class CuentaNoHabilitada extends ErrorDeDominio {
  readonly codigo = 'CUENTA_NO_HABILITADA';
  readonly tipo = 'prohibido' as const;

  constructor() {
    super('Tu cuenta está pausada. Escríbele a soporte VECI y lo revisamos contigo.');
  }
}
