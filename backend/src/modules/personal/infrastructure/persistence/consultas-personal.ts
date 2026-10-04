import { Prisma } from '../../../../../generated/prisma/client';
import { EstadoMembresia, Miembro } from '../../domain/entities/miembro';

export interface FilaMiembro {
  membresia_id: string;
  usuario_id: string;
  nombre: string;
  celular: string | null;
  estado: EstadoMembresia;
  roles: string[];
}

export function aMiembro(fila: FilaMiembro): Miembro {
  return {
    membresiaId: fila.membresia_id,
    usuarioId: fila.usuario_id,
    nombre: fila.nombre,
    celular: fila.celular,
    estado: fila.estado,
    roles: fila.roles,
  };
}

/** Equipo del comercio fijado: RLS deja ver solo sus membresías y a sus personas. */
export function consultaMiembros(filtro: Prisma.Sql): Prisma.Sql {
  return Prisma.sql`
    SELECT m.id::text AS membresia_id, m.user_id::text AS usuario_id,
           p.given_names || coalesce(' ' || p.family_names, '') AS nombre,
           (SELECT i.value FROM identity.user_login_identifiers i
              JOIN core.contact_types ct ON ct.id = i.contact_type_id AND ct.code = 'MOBILE_PHONE'
             WHERE i.user_id = m.user_id AND i.revoked_at IS NULL LIMIT 1) AS celular,
           ms.code AS estado,
           coalesce(array_agg(r.code ORDER BY r.code) FILTER (WHERE r.code IS NOT NULL), '{}') AS roles
      FROM tenancy.memberships m
      JOIN tenancy.membership_statuses ms ON ms.id = m.membership_status_id
      JOIN identity.users u ON u.id = m.user_id
      JOIN identity.people p ON p.id = u.person_id
      LEFT JOIN tenancy.membership_roles mr ON mr.membership_id = m.id AND mr.revoked_at IS NULL
      LEFT JOIN identity.roles r ON r.id = mr.role_id
     WHERE ${filtro}
     GROUP BY m.id, m.user_id, p.given_names, p.family_names, ms.code, ms.sort_order
     ORDER BY ms.sort_order, nombre`;
}

/** Cajeros que ocupan cupo (activos, invitados) y el límite del plan vigente o, sin plan, el de prueba. */
export const CONSULTA_CUPO = Prisma.sql`
  SELECT (SELECT count(DISTINCT m.id)::int
            FROM tenancy.memberships m
            JOIN tenancy.membership_statuses ms ON ms.id = m.membership_status_id
                                               AND (ms.allows_login OR ms.is_initial)
            JOIN tenancy.membership_roles mr ON mr.membership_id = m.id AND mr.revoked_at IS NULL
            JOIN identity.roles r ON r.id = mr.role_id AND r.code = 'CASHIER') AS ocupados,
         (SELECT pl.max_value
            FROM billing.plans pl0
            LEFT JOIN billing.subscriptions s ON s.plan_id = pl0.id AND s.ended_at IS NULL
            JOIN billing.limit_types lt ON lt.code = 'CASHIERS'
            LEFT JOIN billing.plan_limits pl ON pl.plan_id = pl0.id AND pl.limit_type_id = lt.id
           WHERE s.id IS NOT NULL
              OR (pl0.code = 'TRIAL' AND NOT EXISTS (SELECT 1 FROM billing.subscriptions
                                                     WHERE ended_at IS NULL))
           ORDER BY s.id IS NULL
           LIMIT 1) AS limite`;
