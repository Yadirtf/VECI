import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { ClienteTransaccion } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import {
  AfiliacionHecha,
  ClaveDelComercio,
  NuevaAfiliacion,
} from '../../application/puertos/clientes.repository';
import { QrDeAfiliacionGuardado } from '../../application/puertos/mi-qr.repository';
import { crearPersona, crearUsuario, registrarConsentimiento } from './alta-de-persona';

/** La clave activa del comercio; si es su primer cliente, la crea (ADR-0017). */
async function claveActiva(tx: ClienteTransaccion, clave: ClaveDelComercio): Promise<string> {
  await tx.$executeRaw`
    INSERT INTO tenancy.tenant_signing_keys (tenant_id, key_id, algorithm, public_key, private_key_ref)
    SELECT core.current_tenant_id(), ${clave.keyId}, 'Ed25519', ${Buffer.from(clave.publica)}::bytea,
           ${clave.referencia}
     WHERE NOT EXISTS (SELECT 1 FROM tenancy.tenant_signing_keys WHERE retired_at IS NULL)
    ON CONFLICT DO NOTHING`;
  const [fila] = await tx.$queryRaw<{ id: string }[]>`
    SELECT id::text FROM tenancy.tenant_signing_keys WHERE retired_at IS NULL`;
  return fila.id;
}

/**
 * El QR vigente del cliente en el comercio; si no tiene, emite la versión siguiente
 * firmada con la clave activa. Corre con el comercio fijado (RLS).
 */
export async function asegurarQrDeAfiliacion(
  tx: ClienteTransaccion,
  clienteId: string,
  clave: ClaveDelComercio,
): Promise<QrDeAfiliacionGuardado> {
  const claveId = await claveActiva(tx, clave);
  await tx.$executeRaw`
    INSERT INTO customers.affiliation_qr_codes (tenant_id, affiliation_id, version, signing_key_id)
    SELECT core.current_tenant_id(), ${clienteId}::uuid, coalesce(max(version), 0) + 1, ${claveId}::uuid
      FROM customers.affiliation_qr_codes WHERE affiliation_id = ${clienteId}::uuid
    HAVING count(*) FILTER (WHERE revoked_at IS NULL) = 0`;
  const [qr] = await tx.$queryRaw<{ qr_id: string; version: number; key_id: string }[]>`
    SELECT q.id::text AS qr_id, q.version, k.key_id
      FROM customers.affiliation_qr_codes q
      JOIN tenancy.tenant_signing_keys k ON k.id = q.signing_key_id
     WHERE q.affiliation_id = ${clienteId}::uuid AND q.revoked_at IS NULL`;
  return { qrId: qr.qr_id, version: qr.version, keyId: qr.key_id };
}

/** Persona nueva (y su usuario pendiente si el celular es suyo) del registro asistido. */
async function personaDeLaAfiliacion(
  tx: ClienteTransaccion,
  afiliacion: NuevaAfiliacion,
  ids: GeneradorIds,
): Promise<{ personaId: string; usuarioCreado: string | null }> {
  const nueva = afiliacion.personaNueva;
  if (!nueva) return { personaId: afiliacion.personaId as string, usuarioCreado: null };
  const personaId = ids.siguiente();
  await crearPersona(tx, nueva, personaId);
  if (!nueva.conCuenta) return { personaId, usuarioCreado: null };
  const usuarioId = ids.siguiente();
  await crearUsuario(tx, { usuarioId, personaId, celular: nueva.celular, activo: false });
  return { personaId, usuarioCreado: usuarioId };
}

/**
 * Afiliación con su QR versión 1, firmado con la clave del comercio, desde la sede
 * principal y por la membresía de quien atiende. Idempotente: si ya era cliente,
 * no crea nada (UNIQUE tenant_id, person_id).
 */
export async function afiliar(
  tx: ClienteTransaccion,
  afiliacion: NuevaAfiliacion,
  ids: GeneradorIds,
): Promise<AfiliacionHecha> {
  const { personaId, usuarioCreado } = await personaDeLaAfiliacion(tx, afiliacion, ids);
  if (afiliacion.politicaVersionId) {
    await registrarConsentimiento(tx, {
      personaId,
      politicaVersionId: afiliacion.politicaVersionId,
      canal: 'ASSISTED_BY_CASHIER',
      ip: null,
      porComercio: true,
      actorUsuarioId: afiliacion.actorUsuarioId,
    });
  }
  const clienteId = ids.siguiente();
  const insertadas = await tx.$executeRaw`
    INSERT INTO customers.affiliations (id, tenant_id, person_id, affiliation_status_id,
                                        affiliation_channel_id, branch_id, affiliated_by_membership_id)
    SELECT ${clienteId}::uuid, core.current_tenant_id(), ${personaId}::uuid, st.id, ch.id,
           (SELECT b.id FROM tenancy.branches b WHERE b.is_main LIMIT 1),
           (SELECT m.id FROM tenancy.memberships m WHERE m.user_id = ${afiliacion.actorUsuarioId}::uuid)
      FROM customers.affiliation_statuses st, customers.affiliation_channels ch
     WHERE st.is_initial AND ch.code = ${afiliacion.canal}
    ON CONFLICT (tenant_id, person_id) DO NOTHING`;
  if (insertadas === 0) {
    const [ya] = await tx.$queryRaw<{ id: string }[]>`
      SELECT id::text FROM customers.affiliations WHERE person_id = ${personaId}::uuid`;
    await asegurarQrDeAfiliacion(tx, ya.id, afiliacion.clave);
    return { clienteId: ya.id, personaId, nueva: false, usuarioCreado };
  }
  await asegurarQrDeAfiliacion(tx, clienteId, afiliacion.clave);
  return { clienteId, personaId, nueva: true, usuarioCreado };
}
