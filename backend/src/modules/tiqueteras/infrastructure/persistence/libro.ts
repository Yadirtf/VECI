import { Prisma } from '../../../../../generated/prisma/client';
import { ClienteTransaccion } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { TipoDeEvento } from '../../domain/entities/movimiento';
import { OrigenVenta } from '../../domain/entities/venta';

/** Un hecho del libro (ledger.events) en el comercio fijado. */
export interface Evento {
  readonly id: string;
  readonly tipo: TipoDeEvento;
  readonly origen: OrigenVenta | 'SYSTEM_JOB';
  readonly clienteId: string;
  readonly ocurridoEn: Date;
  readonly actorUsuarioId?: string | null;
  readonly dispositivoId?: string | null;
  readonly corrigeA?: string | null;
  readonly motivo?: string | null;
  readonly nota?: string | null;
  /** Solo la venta lleva sede: la principal del negocio. */
  readonly enSedePrincipal?: boolean;
}

const MEMBRESIA = (usuarioId: string | null | undefined) =>
  usuarioId
    ? Prisma.sql`(SELECT m.id FROM tenancy.memberships m WHERE m.user_id = ${usuarioId}::uuid)`
    : Prisma.sql`NULL::uuid`;

/**
 * Inserta el evento si su id no existe. Devuelve false si ya estaba: el id lo genera
 * la caja y es la llave de idempotencia (ADR-0004).
 */
export async function anotarEvento(tx: ClienteTransaccion, e: Evento): Promise<boolean> {
  const sede = e.enSedePrincipal
    ? Prisma.sql`(SELECT b.id FROM tenancy.branches b WHERE b.is_main)`
    : Prisma.sql`NULL::uuid`;
  const insertados = await tx.$executeRaw`
    INSERT INTO ledger.events (id, tenant_id, event_type_id, event_origin_id, affiliation_id,
                               branch_id, actor_membership_id, device_id, occurred_at,
                               reverses_event_id, event_reason_id, reason_note)
    SELECT ${e.id}::uuid, core.current_tenant_id(), et.id, eo.id, ${e.clienteId}::uuid, ${sede},
           ${MEMBRESIA(e.actorUsuarioId)}, ${e.dispositivoId ?? null}::uuid, ${e.ocurridoEn},
           ${e.corrigeA ?? null}::uuid,
           (SELECT r.id FROM ledger.event_reasons r WHERE r.code = ${e.motivo ?? null}),
           ${e.nota ?? null}
      FROM ledger.event_types et, ledger.event_origins eo
     WHERE et.code = ${e.tipo} AND eo.code = ${e.origen}
    ON CONFLICT (id) DO NOTHING`;
  return insertados === 1;
}

/** Asiento del libro: el trigger mueve la caché de saldo y el estado de la tiquetera. */
export async function anotarAsiento(
  tx: ClienteTransaccion,
  eventoId: string,
  tiqueteraId: string,
  unidades: number,
): Promise<void> {
  await tx.$executeRaw`
    INSERT INTO ledger.movements (tenant_id, event_id, package_id, units_delta)
    VALUES (core.current_tenant_id(), ${eventoId}::uuid, ${tiqueteraId}::uuid, ${unidades})`;
}

/** Cambia el estado de la tiquetera (lo valida la máquina de estados de la base). */
export async function cambiarEstadoTiquetera(
  tx: ClienteTransaccion,
  tiqueteraId: string,
  estado: 'EXPIRED' | 'VOIDED',
): Promise<void> {
  await tx.$executeRaw`
    UPDATE prepaid.packages
       SET package_status_id = (SELECT id FROM prepaid.package_statuses WHERE code = ${estado}),
           status_changed_at = now()
     WHERE id = ${tiqueteraId}::uuid`;
}
