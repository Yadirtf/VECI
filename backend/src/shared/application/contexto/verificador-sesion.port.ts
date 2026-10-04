/** Estado de una sesión en la base: cerrarla a distancia corta el acceso al instante (HU-02-06). */
export type EstadoSesion = 'activa' | 'cerrada' | 'vencida';

export interface VerificadorSesion {
  estado(sesionId: string, usuarioId: string): Promise<EstadoSesion>;
}

export const VERIFICADOR_SESION = Symbol('VerificadorSesion');
