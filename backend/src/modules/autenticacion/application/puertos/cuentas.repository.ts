import { Cuenta } from '../../domain/entities/cuenta';

/** Celular o correo con el que se entra (catálogo core.contact_types). */
export type TipoIdentificador = 'MOBILE_PHONE' | 'EMAIL';

/** Usuarios de VECI (identity.users) y sus identificadores de ingreso. */
export interface CuentasRepository {
  buscarPorIdentificador(tipo: TipoIdentificador, valor: string): Promise<Cuenta | null>;
  buscarPorId(usuarioId: string): Promise<Cuenta | null>;
  /** Pasa al usuario invitado a activo cuando define su PIN. */
  activar(usuarioId: string): Promise<void>;
  registrarIngreso(usuarioId: string): Promise<void>;
  /** Reemplaza el correo de ingreso. Lanza CorreoEnUso si es de otra cuenta. */
  asignarCorreo(usuarioId: string, correo: string): Promise<void>;
}

export const CUENTAS_REPOSITORY = Symbol('CuentasRepository');
