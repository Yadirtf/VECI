import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

/** El servicio o la sede no existen en el negocio activo. */
export class ReferenciaNoEncontrada extends ErrorDeDominio {
  readonly codigo = 'REFERENCIA_NO_ENCONTRADA';
  readonly tipo = 'no-encontrado' as const;

  constructor(que: 'servicio' | 'sede') {
    super(`No encontramos ese ${que} en tu negocio.`);
  }
}
