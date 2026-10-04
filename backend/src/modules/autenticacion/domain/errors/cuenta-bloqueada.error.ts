import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

/** Demasiados intentos fallidos: la entrada se pausa unos minutos (HU-02-01). */
export class CuentaBloqueada extends ErrorDeDominio {
  readonly codigo = 'CUENTA_BLOQUEADA';
  readonly tipo = 'no-autenticado' as const;

  constructor(readonly minutos: number) {
    super(
      `Por tu seguridad pausamos la entrada ${minutos === 1 ? '1 minuto' : `${minutos} minutos`}. ` +
        'Después intenta de nuevo con calma.',
    );
  }
}
