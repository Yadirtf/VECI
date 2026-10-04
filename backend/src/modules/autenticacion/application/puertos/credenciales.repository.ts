import { Credencial, TipoCredencial } from '../../domain/entities/credencial.entity';

/** Por qué se reemplaza una credencial (identity.credential_revocation_reasons). */
export type MotivoReemplazo = 'CHANGED_BY_USER' | 'RESET_BY_OWNER' | 'RESET_BY_SUPPORT';

export interface NuevaCredencial {
  usuarioId: string;
  tipo: TipoCredencial;
  hash: string;
  debeCambiar: boolean;
  motivo: MotivoReemplazo;
  creadaPor: string | null;
}

/** PIN y contraseñas (identity.user_credentials). Restablecer = revocar y crear otra. */
export interface CredencialesRepository {
  vigente(usuarioId: string, tipo: TipoCredencial): Promise<Credencial | null>;
  guardarIntentos(credencial: Credencial): Promise<void>;
  /** Revoca la vigente del mismo tipo (si hay) y crea la nueva. Devuelve su id. */
  reemplazar(nueva: NuevaCredencial): Promise<string>;
}

export const CREDENCIALES_REPOSITORY = Symbol('CredencialesRepository');
