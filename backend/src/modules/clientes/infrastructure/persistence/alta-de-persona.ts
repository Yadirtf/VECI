import { Prisma } from '../../../../../generated/prisma/client';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { ClienteTransaccion } from '../../../../shared/infrastructure/prisma/transaccion-comercio';

/** Persona con su celular, como la escribe la app o el cajero. */
export interface DatosPersona {
  nombres: string;
  apellidos: string | null;
  tipoDocumento: string;
  numeroDocumento: string;
  celular: string;
}

/** SQLSTATE dentro de un error de Prisma con el adaptador pg. */
export function codigoPostgres(error: unknown): string | undefined {
  const meta = (error as { meta?: { driverAdapterError?: { cause?: { originalCode?: unknown } } } })
    ?.meta;
  const codigo = meta?.driverAdapterError?.cause?.originalCode;
  return typeof codigo === 'string' ? codigo : undefined;
}

export const VIOLACION_UNICA = '23505';

/**
 * Persona nueva con su celular de contacto. El documento se valida con la expresión
 * del catálogo core.document_types (ADR-0006): si no cumple, no se inserta nada.
 * Sin RETURNING: RLS no deja leer a la persona hasta que tenga afiliación o sea uno mismo.
 */
export async function crearPersona(
  tx: ClienteTransaccion,
  persona: DatosPersona,
  id: string,
): Promise<void> {
  const insertadas = await tx.$executeRaw`
    INSERT INTO identity.people (id, document_type_id, document_number, given_names, family_names, person_status_id)
    SELECT ${id}::uuid, dt.id, ${persona.numeroDocumento}, ${persona.nombres}, ${persona.apellidos}, ps.id
      FROM core.document_types dt, identity.person_statuses ps
     WHERE dt.code = ${persona.tipoDocumento} AND dt.for_natural_person AND dt.is_active AND ps.is_initial
       AND ${persona.numeroDocumento} ~ coalesce(dt.validation_regex, '^.+$')`;
  if (insertadas === 0) throw new DatoInvalido('Revisa el tipo y el número de documento, veci.');
  await tx.$executeRaw`
    INSERT INTO identity.person_contacts (person_id, contact_type_id, value, is_primary)
    SELECT ${id}::uuid, ct.id, ${persona.celular}, true FROM core.contact_types ct
     WHERE ct.code = 'MOBILE_PHONE'`;
}

/** Usuario que entra con su celular: activo (se registró solo) o pendiente (lo anotó la caja). */
export async function crearUsuario(
  tx: ClienteTransaccion,
  usuario: { usuarioId: string; personaId: string; celular: string; activo: boolean },
): Promise<void> {
  const estado = usuario.activo ? 'ACTIVE' : 'PENDING_ACTIVATION';
  const activado = usuario.activo ? Prisma.sql`now()` : Prisma.sql`NULL`;
  await tx.$executeRaw`
    INSERT INTO identity.users (id, person_id, user_status_id, activated_at)
    SELECT ${usuario.usuarioId}::uuid, ${usuario.personaId}::uuid, id, ${activado}
      FROM identity.user_statuses WHERE code = ${estado}`;
  await tx.$executeRaw`
    INSERT INTO identity.user_login_identifiers (user_id, contact_type_id, value)
    SELECT ${usuario.usuarioId}::uuid, ct.id, ${usuario.celular} FROM core.contact_types ct
     WHERE ct.code = 'MOBILE_PHONE'`;
}

/** Quién aceptó qué versión de la política y por qué canal (RF-CLI-05, RNF-LEG-01). */
export async function registrarConsentimiento(
  tx: ClienteTransaccion,
  consentimiento: {
    personaId: string;
    politicaVersionId: string;
    canal: 'SELF_APP' | 'ASSISTED_BY_CASHIER';
    ip: string | null;
    porComercio: boolean;
    actorUsuarioId: string | null;
  },
): Promise<void> {
  const c = consentimiento;
  const comercio = c.porComercio ? Prisma.sql`core.current_tenant_id()` : Prisma.sql`NULL`;
  await tx.$executeRaw`
    INSERT INTO compliance.consents (person_id, policy_version_id, consent_channel_id, ip_address,
                                     captured_by_tenant_id, captured_by_membership_id)
    SELECT ${c.personaId}::uuid, ${c.politicaVersionId}::uuid, ch.id, ${c.ip}::inet, ${comercio},
           (SELECT m.id FROM tenancy.memberships m WHERE m.user_id = ${c.actorUsuarioId}::uuid)
      FROM compliance.consent_channels ch WHERE ch.code = ${c.canal}
    ON CONFLICT (person_id, policy_version_id) DO NOTHING`;
}

/** Versión siguiente del QR personal (la 1 si nunca tuvo). */
export async function emitirQrPersonal(
  tx: ClienteTransaccion,
  personaId: string,
): Promise<{ qr_id: string; version: number; emitido_en: Date }> {
  const [fila] = await tx.$queryRaw<{ qr_id: string; version: number; emitido_en: Date }[]>`
    INSERT INTO customers.personal_qr_codes (person_id, version)
    SELECT ${personaId}::uuid, coalesce(max(q.version), 0) + 1
      FROM customers.personal_qr_codes q WHERE q.person_id = ${personaId}::uuid
    RETURNING id::text AS qr_id, version, issued_at AS emitido_en`;
  return fila;
}
