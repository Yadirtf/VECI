import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

export class NegocioSinHorarios extends ErrorDeDominio {
  readonly codigo = 'NEGOCIO_SIN_HORARIOS';
  readonly tipo = 'regla-incumplida' as const;

  constructor() {
    super('Antes de abrir, cuéntanos cuándo atiendes: crea al menos un horario.');
  }
}

export class NegocioYaAbierto extends ErrorDeDominio {
  readonly codigo = 'NEGOCIO_YA_ABIERTO';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Tu negocio ya está abierto, veci.');
  }
}

export class TipoDeNegocioDesconocido extends ErrorDeDominio {
  readonly codigo = 'TIPO_DE_NEGOCIO_DESCONOCIDO';
  readonly tipo = 'regla-incumplida' as const;

  constructor() {
    super('Escoge el tipo de negocio de la lista, veci.');
  }
}
