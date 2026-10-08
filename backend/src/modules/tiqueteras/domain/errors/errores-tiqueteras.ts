import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

export class TipoNoEncontrado extends ErrorDeDominio {
  readonly codigo = 'TIPO_NO_ENCONTRADO';
  readonly tipo = 'no-encontrado' as const;

  constructor() {
    super('Esa tiquetera no está en la pizarra de tu negocio.');
  }
}

export class NombreDeTipoRepetido extends ErrorDeDominio {
  readonly codigo = 'NOMBRE_REPETIDO';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Ya tienes una tiquetera con ese nombre. Ponle otro para no confundirlas.');
  }
}

/** Un tipo desactivado no se vende en línea (HU-05-01). */
export class TipoNoSeVende extends ErrorDeDominio {
  readonly codigo = 'TIPO_NO_SE_VENDE';
  readonly tipo = 'regla-incumplida' as const;

  constructor() {
    super('Esa tiquetera está guardada y ya no se vende. Actívala en la pizarra si la quieres.');
  }
}

/** La caja cobró un precio que ya no es el de la pizarra (venta en línea). */
export class PrecioCambio extends ErrorDeDominio {
  readonly codigo = 'PRECIO_CAMBIO';
  readonly tipo = 'conflicto' as const;

  constructor(precioActual: string) {
    super(`El precio de esta tiquetera cambió a ${precioActual}. Revísalo con el cliente.`);
  }
}

export class ClienteNoPuedeComprar extends ErrorDeDominio {
  readonly codigo = 'CLIENTE_NO_PUEDE_COMPRAR';
  readonly tipo = 'regla-incumplida' as const;

  constructor() {
    super('Este cliente está bloqueado o ya no está en tu negocio. No se le puede vender.');
  }
}

export class ClienteNoEncontrado extends ErrorDeDominio {
  readonly codigo = 'CLIENTE_NO_ENCONTRADO';
  readonly tipo = 'no-encontrado' as const;

  constructor() {
    super('Ese cliente no está en este negocio.');
  }
}

/** El mismo id de venta llegó dos veces con datos distintos: no es un reintento. */
export class VentaDistinta extends ErrorDeDominio {
  readonly codigo = 'VENTA_DISTINTA';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Ya hay otra venta con ese número. Vuelve a intentarlo desde la caja.');
  }
}

export class PagoInvalido extends ErrorDeDominio {
  readonly codigo = 'PAGO_INVALIDO';
  readonly tipo = 'regla-incumplida' as const;

  constructor(mensaje: string) {
    super(mensaje);
  }
}

export class VentaNoEncontrada extends ErrorDeDominio {
  readonly codigo = 'VENTA_NO_ENCONTRADA';
  readonly tipo = 'no-encontrado' as const;

  constructor() {
    super('Esa venta no está en tu negocio.');
  }
}

export class VentaYaAnulada extends ErrorDeDominio {
  readonly codigo = 'VENTA_YA_ANULADA';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Esa venta ya estaba anulada. Puedes verla en la historia del cliente.');
  }
}

export class TiqueteraNoEncontrada extends ErrorDeDominio {
  readonly codigo = 'TIQUETERA_NO_ENCONTRADA';
  readonly tipo = 'no-encontrado' as const;

  constructor() {
    super('Esa tiquetera no está en tu negocio.');
  }
}

/** Solo se ajusta una tiquetera vigente: activa o agotada y sin vencer. */
export class TiqueteraNoSeAjusta extends ErrorDeDominio {
  readonly codigo = 'TIQUETERA_NO_SE_AJUSTA';
  readonly tipo = 'regla-incumplida' as const;

  constructor(porque: 'vencida' | 'anulada') {
    super(
      porque === 'vencida'
        ? 'Esa tiquetera ya venció. Si le debes algo al cliente, véndele una nueva de cortesía.'
        : 'Esa tiquetera está anulada: ya no se le pueden sumar ni quitar unidades.',
    );
  }
}

export class SaldoInsuficiente extends ErrorDeDominio {
  readonly codigo = 'SALDO_INSUFICIENTE';
  readonly tipo = 'regla-incumplida' as const;

  constructor(disponibles: number) {
    super(
      disponibles > 0
        ? `Solo le quedan ${disponibles}. No puede quedar en negativo.`
        : 'No le quedan unidades por quitar.',
    );
  }
}

/** Anular o ajustar exige un motivo del catálogo (RF-TIQ-06). */
export class MotivoObligatorio extends ErrorDeDominio {
  readonly codigo = 'MOTIVO_OBLIGATORIO';
  readonly tipo = 'regla-incumplida' as const;

  constructor(mensaje = 'Cuéntanos el motivo: así la corrección queda clara para todos.') {
    super(mensaje);
  }
}

/** Con tiqueteras vendidas, la cantidad y la unidad de un tipo ya no cambian. */
export class CantidadYaVendida extends ErrorDeDominio {
  readonly codigo = 'CANTIDAD_YA_VENDIDA';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super(
      'Ya vendiste tiqueteras de este tipo, así que su cantidad no cambia. Para otra ' +
        'cantidad crea un tipo nuevo y guarda este.',
    );
  }
}
