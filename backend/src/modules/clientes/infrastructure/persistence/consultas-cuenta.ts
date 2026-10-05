import { Prisma } from '../../../../../generated/prisma/client';
import { EstadoCuenta } from '../../domain/entities/cliente';

/**
 * Estado de cuenta de una persona según su usuario: sin usuario (celular compartido),
 * pendiente (la anotaron y no ha creado su PIN) o activa (cualquier otro estado).
 */
export const ESTADO_CUENTA = Prisma.sql`
  CASE WHEN u.id IS NULL THEN 'SIN_CUENTA'
       WHEN us.is_initial THEN 'PENDIENTE'
       ELSE 'ACTIVA' END`;

/** Quién entra con este celular (identity.user_login_identifiers no tiene RLS). */
export function consultaCuentaPorCelular(celular: string): Prisma.Sql {
  return Prisma.sql`
    SELECT ${ESTADO_CUENTA} AS cuenta
      FROM identity.user_login_identifiers i
      JOIN core.contact_types ct ON ct.id = i.contact_type_id AND ct.code = 'MOBILE_PHONE'
      JOIN identity.users u ON u.id = i.user_id
      JOIN identity.user_statuses us ON us.id = u.user_status_id
     WHERE i.value = ${celular} AND i.revoked_at IS NULL`;
}

/** Persona con ese documento en toda la plataforma, solo enmascarada (SECURITY DEFINER). */
export function consultaPersonaPorDocumento(tipo: string, numero: string): Prisma.Sql {
  return Prisma.sql`
    SELECT f.person_id::text AS persona_id, f.masked_name AS nombre,
           f.masked_document AS documento, ${ESTADO_CUENTA} AS cuenta
      FROM customers.find_person_by_document(${tipo}::varchar::core.catalog_code, ${numero}::varchar) f
      LEFT JOIN identity.users u ON u.person_id = f.person_id
      LEFT JOIN identity.user_statuses us ON us.id = u.user_status_id`;
}

export interface FilaPersonaGlobal {
  persona_id: string;
  nombre: string;
  documento: string;
  cuenta: EstadoCuenta;
}
