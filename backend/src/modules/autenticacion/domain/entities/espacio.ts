/** Un rol de un usuario en un comercio, tal como sale de la base. */
export interface RolEnComercio {
  readonly comercioId: string;
  readonly nombre: string;
  readonly tipoNegocio: string;
  readonly rol: string;
  readonly esInvitacion: boolean;
}

/**
 * Comercio donde el usuario puede actuar y con qué roles (HU-02-03): la misma
 * persona puede ser cliente en un negocio y cajera en otro.
 */
export interface Espacio {
  readonly comercioId: string;
  readonly nombre: string;
  readonly tipoNegocio: string;
  readonly roles: readonly string[];
  readonly invitacionPendiente: boolean;
}

/** Roles del personal; el de cliente llega por la afiliación. */
export const ROLES_DE_PERSONAL: readonly string[] = ['OWNER', 'CASHIER'];

/** Agrupa los roles por comercio, ordenados por nombre del comercio. */
export function agruparEspacios(filas: readonly RolEnComercio[]): Espacio[] {
  const porComercio = new Map<string, Espacio>();
  for (const fila of filas) {
    const actual = porComercio.get(fila.comercioId);
    const roles = actual ? [...actual.roles, fila.rol] : [fila.rol];
    porComercio.set(fila.comercioId, {
      comercioId: fila.comercioId,
      nombre: fila.nombre,
      tipoNegocio: fila.tipoNegocio,
      roles: [...new Set(roles)],
      invitacionPendiente: (actual?.invitacionPendiente ?? false) || fila.esInvitacion,
    });
  }
  return [...porComercio.values()].sort((a, b) => a.nombre.localeCompare(b.nombre, 'es'));
}

export function esPersonal(espacio: Espacio): boolean {
  return espacio.roles.some((rol) => ROLES_DE_PERSONAL.includes(rol));
}
