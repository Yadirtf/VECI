/** Responde si un usuario trabaja hoy (membresía activa) en un comercio y qué puede hacer. */
export interface VerificadorMembresia {
  esMiembroActivo(usuarioId: string, comercioId: string): Promise<boolean>;
  /** Códigos de permiso (identity.permissions) que le dan sus roles vigentes en el comercio. */
  permisosEn(usuarioId: string, comercioId: string): Promise<ReadonlySet<string>>;
}

export const VERIFICADOR_MEMBRESIA = Symbol('VerificadorMembresia');
