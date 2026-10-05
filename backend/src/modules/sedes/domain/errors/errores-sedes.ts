import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

/** Varias sedes es una función del plan Pro (HU-03-03). */
export class SedesSoloEnPro extends ErrorDeDominio {
  readonly codigo = 'SEDES_SOLO_EN_PRO';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Para abrir otra sede necesitas el plan Pro. Escríbenos y te ayudamos a cambiarlo.');
  }
}

export class LimiteDeSedes extends ErrorDeDominio {
  readonly codigo = 'LIMITE_DE_SEDES';
  readonly tipo = 'conflicto' as const;

  constructor(limite: number) {
    super(`Tu plan permite ${limite} ${limite === 1 ? 'sede' : 'sedes'}.`);
  }
}

export class SedeNoEncontrada extends ErrorDeDominio {
  readonly codigo = 'SEDE_NO_ENCONTRADA';
  readonly tipo = 'no-encontrado' as const;

  constructor() {
    super('No encontramos esa sede en tu negocio.');
  }
}

export class CambioDeSedeNoPermitido extends ErrorDeDominio {
  readonly codigo = 'CAMBIO_DE_SEDE_NO_PERMITIDO';
  readonly tipo = 'regla-incumplida' as const;

  constructor(mensaje: string) {
    super(mensaje);
  }
}

export class NombreDeSedeRepetido extends ErrorDeDominio {
  readonly codigo = 'NOMBRE_DE_SEDE_REPETIDO';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Ya tienes una sede con ese nombre.');
  }
}
