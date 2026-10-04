/** Estados de una membresía (catálogo tenancy.membership_statuses). */
export type EstadoMembresia = 'INVITED' | 'ACTIVE' | 'SUSPENDED' | 'REMOVED';

/** Una persona del equipo del negocio: propietario o cajero (HU-02-04). */
export interface Miembro {
  readonly membresiaId: string;
  readonly usuarioId: string;
  readonly nombre: string;
  readonly celular: string | null;
  readonly estado: EstadoMembresia;
  readonly roles: readonly string[];
}

export function esPropietario(miembro: Miembro): boolean {
  return miembro.roles.includes('OWNER');
}
