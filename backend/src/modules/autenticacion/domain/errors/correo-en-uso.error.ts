import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

export class CorreoEnUso extends ErrorDeDominio {
  readonly codigo = 'CORREO_EN_USO';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Ese correo ya lo usa otra cuenta de VECI.');
  }
}
