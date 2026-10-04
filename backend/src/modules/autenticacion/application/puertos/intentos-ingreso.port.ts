/** Motivos de identity.login_failure_reasons que usa el inicio de sesión. */
export type MotivoFallo =
  'UNKNOWN_IDENTIFIER' | 'WRONG_SECRET' | 'CREDENTIAL_LOCKED' | 'USER_NOT_ALLOWED';

export interface IntentoIngreso {
  /** Huella del celular o correo: el registro no guarda el dato en claro. */
  huellaIdentificador: string;
  usuarioId: string | null;
  dispositivoId: string | null;
  ip: string | null;
  /** null = el intento fue correcto. */
  motivoFallo: MotivoFallo | null;
}

/** Bitácora de intentos de inicio de sesión (identity.login_attempts). */
export interface IntentosIngreso {
  registrar(intento: IntentoIngreso): Promise<void>;
}

export const INTENTOS_INGRESO = Symbol('IntentosIngreso');
