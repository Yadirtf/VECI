/** Permisos de los roles internos de VECI (Administrador, Soporte) de un usuario. */
export interface VerificadorPlataforma {
  permisosDePlataforma(usuarioId: string): Promise<ReadonlySet<string>>;
}

export const VERIFICADOR_PLATAFORMA = Symbol('VerificadorPlataforma');
