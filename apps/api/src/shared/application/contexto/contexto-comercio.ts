/** Comercio activo de la petición y el usuario que actúa en él (HU-01-05). */
export interface ContextoComercio {
  readonly comercioId: string;
  readonly usuarioId: string;
}
