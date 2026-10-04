/** Usuario que intenta entrar, con lo mínimo para decidir (HU-02-01). */
export interface Cuenta {
  readonly usuarioId: string;
  readonly personaId: string;
  readonly nombre: string;
  /** El estado del usuario permite iniciar sesión (identity.user_statuses.allows_login). */
  readonly puedeEntrar: boolean;
  /** Invitado que aún no define su PIN (estado inicial del usuario). */
  readonly pendienteDeActivar: boolean;
}
