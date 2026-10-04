import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

/**
 * Mismo mensaje si el celular no existe o el PIN no coincide: así nadie averigua
 * quién tiene cuenta en VECI.
 */
export class CredencialesIncorrectas extends ErrorDeDominio {
  readonly codigo = 'CREDENCIALES_INCORRECTAS';
  readonly tipo = 'no-autenticado' as const;

  constructor(mensaje = 'El celular o el PIN no coinciden, veci. Revisa e intenta otra vez.') {
    super(mensaje);
  }
}
