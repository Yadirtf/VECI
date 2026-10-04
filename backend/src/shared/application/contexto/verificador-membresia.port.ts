/** Responde si un usuario trabaja hoy (membresía activa) en un comercio. */
export interface VerificadorMembresia {
  esMiembroActivo(usuarioId: string, comercioId: string): Promise<boolean>;
}

export const VERIFICADOR_MEMBRESIA = Symbol('VerificadorMembresia');
