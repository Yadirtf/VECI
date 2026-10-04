import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

export class HorarioSeCruza extends ErrorDeDominio {
  readonly codigo = 'HORARIO_SE_CRUZA';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Ese horario se cruza con otro del mismo día en esta sede.');
  }
}
