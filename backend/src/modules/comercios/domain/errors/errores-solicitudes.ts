import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

export class SolicitudNoEncontrada extends ErrorDeDominio {
  readonly codigo = 'SOLICITUD_NO_ENCONTRADA';
  readonly tipo = 'no-encontrado' as const;

  constructor() {
    super('No encontramos esa solicitud de negocio.');
  }
}

export class SolicitudYaRevisada extends ErrorDeDominio {
  readonly codigo = 'SOLICITUD_YA_REVISADA';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Esa solicitud ya fue revisada.');
  }
}

/** Una persona tiene a lo sumo una solicitud en revisión. */
export class SolicitudEnRevision extends ErrorDeDominio {
  readonly codigo = 'SOLICITUD_EN_REVISION';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Ya tienes una solicitud en revisión. Te avisamos apenas la miremos, veci.');
  }
}

/** VECI aún no opera en ese municipio (core.municipalities.is_served). */
export class MunicipioFueraDeCobertura extends ErrorDeDominio {
  readonly codigo = 'MUNICIPIO_FUERA_DE_COBERTURA';
  readonly tipo = 'regla-incumplida' as const;

  constructor() {
    super(
      'Por ahora VECI atiende negocios en Mocoa. Pronto llegamos a más municipios del Putumayo.',
    );
  }
}
