import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

export class MiembroNoEncontrado extends ErrorDeDominio {
  readonly codigo = 'MIEMBRO_NO_ENCONTRADO';
  readonly tipo = 'no-encontrado' as const;

  constructor() {
    super('Esa persona no está en el equipo de este negocio.');
  }
}

/** El plan del negocio no admite más cajeros (HU-02-04, HU-11-01). */
export class LimiteDeCajeros extends ErrorDeDominio {
  readonly codigo = 'LIMITE_DE_CAJEROS';
  readonly tipo = 'conflicto' as const;

  constructor(limite: number) {
    super(
      `Tu plan permite ${limite} ${limite === 1 ? 'cajero' : 'cajeros'}. ` +
        'Retira a alguien del equipo o mejora tu plan para sumar otro.',
    );
  }
}

export class YaEsDelEquipo extends ErrorDeDominio {
  readonly codigo = 'YA_ES_DEL_EQUIPO';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Esa persona ya está en tu equipo.');
  }
}

/** La cédula ya tiene cuenta VECI con otro celular. */
export class CelularNoCoincide extends ErrorDeDominio {
  readonly codigo = 'CELULAR_NO_COINCIDE';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Esa cédula ya tiene cuenta en VECI con otro celular. Invítala con ese número.');
  }
}

/** Nadie se suspende a sí mismo ni toca al propietario desde la gestión de cajeros. */
export class AccionSobreMiembroNoPermitida extends ErrorDeDominio {
  readonly codigo = 'ACCION_NO_PERMITIDA';
  readonly tipo = 'regla-incumplida' as const;

  constructor(mensaje: string) {
    super(mensaje);
  }
}
