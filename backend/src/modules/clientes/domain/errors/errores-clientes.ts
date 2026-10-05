import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

export class ClienteNoEncontrado extends ErrorDeDominio {
  readonly codigo = 'CLIENTE_NO_ENCONTRADO';
  readonly tipo = 'no-encontrado' as const;

  constructor() {
    super('Ese cliente no está en este negocio.');
  }
}

/**
 * Auto-registro con un celular o documento que ya tiene cuenta (HU-04-01). No dice
 * en qué negocios está la persona: solo cómo entrar.
 */
export class YaTieneCuenta extends ErrorDeDominio {
  readonly codigo = 'YA_TIENE_CUENTA';
  readonly tipo = 'conflicto' as const;

  constructor(dato: 'celular' | 'documento') {
    super(`Ese ${dato} ya está en VECI. Si es tuyo, entra con tu celular y tu PIN.`);
  }
}

/** Un negocio la registró (asistido) y aún no activa su app. */
export class YaTeAnotaron extends ErrorDeDominio {
  readonly codigo = 'YA_TE_ANOTARON';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super(
      'Ya te anotaron en un negocio. Entra con tu celular y el PIN de bienvenida que te dieron.',
    );
  }
}

/** La persona existe sin cuenta propia (celular compartido): activa en el negocio. */
export class DocumentoSinCuenta extends ErrorDeDominio {
  readonly codigo = 'DOCUMENTO_SIN_CUENTA';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Ese documento ya está en VECI. Pide en tu negocio que te ayuden a activar tu app.');
  }
}

/** Registro asistido con un celular que es la entrada de otra cuenta (HU-04-04). */
export class CelularEnUso extends ErrorDeDominio {
  readonly codigo = 'CELULAR_EN_USO';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super(
      'Ese celular ya es de otra cuenta VECI. Si lo comparten en la familia, regístralo como ' +
        'celular de contacto.',
    );
  }
}

export class FaltanDatosDeRegistro extends ErrorDeDominio {
  readonly codigo = 'FALTAN_DATOS';
  readonly tipo = 'regla-incumplida' as const;

  constructor() {
    super('Para registrarlo faltan el nombre y el celular, veci.');
  }
}

/** El cajero debe confirmar que el cliente aceptó la política de datos (RF-CLI-05). */
export class PoliticaNoAceptada extends ErrorDeDominio {
  readonly codigo = 'POLITICA_NO_ACEPTADA';
  readonly tipo = 'regla-incumplida' as const;

  constructor() {
    super('Sin aceptar la política de datos no podemos registrarlo.');
  }
}

/** Se aceptó una versión de la política que ya no es la vigente. */
export class PoliticaDesactualizada extends ErrorDeDominio {
  readonly codigo = 'POLITICA_DESACTUALIZADA';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('La política de datos cambió. Léela de nuevo antes de aceptar.');
  }
}

/** El QR no sirve para afiliar: es de otro tipo, no es de VECI o ya fue cambiado. */
export class QrNoSirve extends ErrorDeDominio {
  readonly codigo = 'QR_NO_SIRVE';
  readonly tipo = 'regla-incumplida' as const;

  constructor(mensaje: string) {
    super(mensaje);
  }
}

/** El PIN de bienvenida es solo para quien aún no activa su app. */
export class YaActivoSuApp extends ErrorDeDominio {
  readonly codigo = 'YA_ACTIVO_SU_APP';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Ya activó su app con su propio PIN. Si lo olvidó, soporte VECI se lo restablece.');
  }
}

/** Registrado con un celular compartido: no tiene con qué entrar a la app todavía. */
export class SinCuentaPropia extends ErrorDeDominio {
  readonly codigo = 'SIN_CUENTA_PROPIA';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Su celular es compartido, así que aún no tiene cuenta para la app.');
  }
}
