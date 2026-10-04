import { ErrorDeDominio } from './error-de-dominio';

/** El usuario está en el comercio, pero su rol no permite esta acción (HU-02-03). */
export class PermisoDenegado extends ErrorDeDominio {
  readonly codigo = 'PERMISO_DENEGADO';
  readonly tipo = 'prohibido' as const;

  constructor(mensaje = 'Tu rol en este negocio no permite hacer esto, veci.') {
    super(mensaje);
  }
}
