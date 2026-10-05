import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';
import { ClienteTransaccion } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { CelularNoCoincide } from '../../domain/errors/errores-personal';
import { Invitacion, PersonaNueva } from '../../application/puertos/personal.repository';

/** SQLSTATE dentro de un error de Prisma con el adaptador pg. */
function codigoPostgres(error: unknown): string | undefined {
  const meta = (error as { meta?: { driverAdapterError?: { cause?: { originalCode?: unknown } } } })
    ?.meta;
  const codigo = meta?.driverAdapterError?.cause?.originalCode;
  return typeof codigo === 'string' ? codigo : undefined;
}

/** Únicos violados → la persona ya existe con otros datos; transición inválida → regla. */
export function mapearErrorDeAlta(error: unknown): unknown {
  if (error instanceof ErrorDeDominio) return error;
  const codigo = codigoPostgres(error);
  if (codigo === '23505') return new CelularNoCoincide();
  if (codigo === '23514') return new DatoInvalido('Ese cambio de estado no se permite.');
  return error;
}

/**
 * Persona nueva con su celular. El documento se valida con la expresión del
 * catálogo core.document_types (ADR-0006): si no cumple, no se inserta nada.
 * Sin RETURNING: RLS no deja leer a la persona hasta que tenga membresía.
 */
async function crearPersona(
  tx: ClienteTransaccion,
  persona: PersonaNueva,
  id: string,
): Promise<void> {
  const insertadas = await tx.$executeRaw`
    INSERT INTO identity.people (id, document_type_id, document_number, given_names, family_names, person_status_id)
    SELECT ${id}::uuid, dt.id, ${persona.numeroDocumento}, ${persona.nombres}, ${persona.apellidos}, ps.id
      FROM core.document_types dt, identity.person_statuses ps
     WHERE dt.code = ${persona.tipoDocumento} AND dt.for_natural_person AND ps.is_initial
       AND ${persona.numeroDocumento} ~ coalesce(dt.validation_regex, '^.+$')`;
  if (insertadas === 0) throw new DatoInvalido('Revisa el tipo y el número de documento, veci.');
  await tx.$executeRaw`
    INSERT INTO identity.person_contacts (person_id, contact_type_id, value, is_primary)
    SELECT ${id}::uuid, ct.id, ${persona.celular}, true FROM core.contact_types ct
     WHERE ct.code = 'MOBILE_PHONE'`;
}

/** Usuario pendiente de activar con su celular para entrar (HU-02-04). */
async function crearUsuario(
  tx: ClienteTransaccion,
  invitacion: Invitacion,
  ids: GeneradorIds,
): Promise<string> {
  const personaId = invitacion.personaExistenteId ?? ids.siguiente();
  if (!invitacion.personaExistenteId) await crearPersona(tx, invitacion.persona, personaId);
  const usuarioId = ids.siguiente();
  await tx.$executeRaw`
    INSERT INTO identity.users (id, person_id, user_status_id)
    SELECT ${usuarioId}::uuid, ${personaId}::uuid, id FROM identity.user_statuses WHERE is_initial`;
  await tx.$executeRaw`
    INSERT INTO identity.user_login_identifiers (user_id, contact_type_id, value)
    SELECT ${usuarioId}::uuid, ct.id, ${invitacion.persona.celular} FROM core.contact_types ct
     WHERE ct.code = 'MOBILE_PHONE'`;
  return usuarioId;
}

/** Membresía invitada (nueva o reinvitada desde Retirado) con el rol de la invitación. */
export async function crearMembresia(
  tx: ClienteTransaccion,
  invitacion: Invitacion,
  ids: GeneradorIds,
): Promise<{ membresiaId: string; usuarioId: string }> {
  const usuarioId = invitacion.usuarioId ?? (await crearUsuario(tx, invitacion, ids));
  const membresiaId = invitacion.membresiaRetirada ?? ids.siguiente();
  if (invitacion.membresiaRetirada) {
    await tx.$executeRaw`
      UPDATE tenancy.memberships
         SET membership_status_id = (SELECT id FROM tenancy.membership_statuses WHERE is_initial),
             invited_by_user_id = ${invitacion.invitadoPor}::uuid, invited_at = now(), joined_at = NULL
       WHERE id = ${membresiaId}::uuid`;
  } else {
    await tx.$executeRaw`
      INSERT INTO tenancy.memberships (id, tenant_id, user_id, membership_status_id, invited_by_user_id)
      SELECT ${membresiaId}::uuid, core.current_tenant_id(), ${usuarioId}::uuid, id,
             ${invitacion.invitadoPor}::uuid
        FROM tenancy.membership_statuses WHERE is_initial`;
  }
  await tx.$executeRaw`
    INSERT INTO tenancy.membership_roles (tenant_id, membership_id, role_id, granted_by_user_id)
    SELECT core.current_tenant_id(), ${membresiaId}::uuid, r.id, ${invitacion.invitadoPor}::uuid
      FROM identity.roles r WHERE r.code = ${invitacion.rol}`;
  return { membresiaId, usuarioId };
}
