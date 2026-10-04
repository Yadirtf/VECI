import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

export class CuentaNoEncontrada extends ErrorDeDominio {
  readonly codigo = 'CUENTA_NO_ENCONTRADA';
  readonly tipo = 'no-encontrado' as const;

  constructor() {
    super('No hay una cuenta VECI con ese celular.');
  }
}

/** El documento que dice la persona no es el de la cuenta: no se restablece nada. */
export class DocumentoNoCoincide extends ErrorDeDominio {
  readonly codigo = 'DOCUMENTO_NO_COINCIDE';
  readonly tipo = 'regla-incumplida' as const;

  constructor() {
    super('El documento no coincide con el de esa cuenta. No se cambió nada.');
  }
}
