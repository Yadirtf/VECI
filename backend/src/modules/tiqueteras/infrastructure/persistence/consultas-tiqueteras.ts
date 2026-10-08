import { Prisma } from '../../../../../generated/prisma/client';
import { Movimiento, TipoDeEvento } from '../../domain/entities/movimiento';
import { EstadoTiquetera, Tiquetera } from '../../domain/entities/tiquetera';

export interface FilaTiquetera {
  tiquetera_id: string;
  cliente_id: string;
  venta_id: string;
  tipo_id: string;
  nombre: string;
  unidad_codigo: string;
  singular: string;
  plural: string;
  compradas: number;
  saldo: number;
  estado: EstadoTiquetera;
  comprada_en: Date;
  vence_en: Date;
  precio: number | null;
}

export const aTiquetera = (f: FilaTiquetera): Tiquetera => ({
  tiqueteraId: f.tiquetera_id,
  clienteId: f.cliente_id,
  ventaId: f.venta_id,
  tipoId: f.tipo_id,
  nombre: f.nombre,
  unidad: { codigo: f.unidad_codigo, singular: f.singular, plural: f.plural },
  compradas: f.compradas,
  saldo: f.saldo,
  estado: f.estado,
  compradaEn: f.comprada_en,
  venceEn: f.vence_en,
  precio: f.precio,
});

/**
 * Columnas de una tiquetera (alias p). Sirve con el comercio fijado y con la persona
 * en su app: la venta se toma del primer asiento (siempre es la compra) y el precio
 * solo lo ve el comercio (sales no tiene política para el cliente).
 */
export const COLUMNAS_TIQUETERA = Prisma.sql`
  p.id::text AS tiquetera_id, p.affiliation_id::text AS cliente_id,
  (SELECT m.event_id::text FROM ledger.movements m WHERE m.package_id = p.id
    ORDER BY m.created_at, m.id LIMIT 1) AS venta_id,
  p.package_type_id::text AS tipo_id, pt.name AS nombre,
  coalesce(u.code, 'UNIT') AS unidad_codigo, coalesce(u.singular_name, 'unidad') AS singular,
  coalesce(u.plural_name, 'unidades') AS plural, pt.units_quantity AS compradas,
  p.units_balance AS saldo, ps.code AS estado, p.starts_at AS comprada_en,
  p.expires_at AS vence_en,
  (SELECT si.unit_price::int FROM sales.sale_items si WHERE si.id = p.sale_item_id) AS precio`;

export const DESDE_TIQUETERA = Prisma.sql`
  prepaid.packages p
  JOIN prepaid.package_types pt ON pt.id = p.package_type_id
  JOIN prepaid.package_statuses ps ON ps.id = p.package_status_id
  LEFT JOIN prepaid.consumption_units u ON u.id = pt.consumption_unit_id`;

export function consultaTiqueteras(filtro: Prisma.Sql, bloquear = false): Prisma.Sql {
  const bloqueo = bloquear ? Prisma.sql`FOR UPDATE OF p` : Prisma.empty;
  return Prisma.sql`
    SELECT ${COLUMNAS_TIQUETERA}
      FROM ${DESDE_TIQUETERA}
     WHERE ${filtro}
     ORDER BY p.expires_at, p.starts_at
     ${bloqueo}`;
}

interface FilaMovimiento {
  evento_id: string;
  tipo: TipoDeEvento;
  ocurrido_en: Date;
  unidades: number;
  tiquetera: string | null;
  motivo: string | null;
  nota: string | null;
  quien: string | null;
  corrige_a: string | null;
}

/** Nombre corto de quien hizo algo: "Marta R." */
const NOMBRE_CORTO = Prisma.sql`
  quien.given_names || coalesce(' ' || left(quien.family_names, 1) || '.', '')`;

/** La historia del saldo del cliente: un renglón por evento, con sus asientos sumados. */
export function consultaMovimientos(clienteId: string, limite: number): Prisma.Sql {
  return Prisma.sql`
    SELECT e.id::text AS evento_id, et.code AS tipo, e.occurred_at AS ocurrido_en,
           coalesce(sum(m.units_delta), 0)::int AS unidades,
           string_agg(DISTINCT pt.name, ', ') AS tiquetera, r.name AS motivo,
           e.reason_note AS nota, ${NOMBRE_CORTO} AS quien,
           e.reverses_event_id::text AS corrige_a
      FROM ledger.events e
      JOIN ledger.event_types et ON et.id = e.event_type_id
      LEFT JOIN ledger.movements m ON m.event_id = e.id
      LEFT JOIN prepaid.packages p ON p.id = m.package_id
      LEFT JOIN prepaid.package_types pt ON pt.id = p.package_type_id
      LEFT JOIN ledger.event_reasons r ON r.id = e.event_reason_id
      LEFT JOIN tenancy.memberships mb ON mb.id = e.actor_membership_id
      LEFT JOIN identity.users us ON us.id = mb.user_id
      LEFT JOIN identity.people quien ON quien.id = us.person_id
     WHERE e.affiliation_id = ${clienteId}::uuid
     GROUP BY e.id, et.code, r.name, quien.given_names, quien.family_names
     ORDER BY e.occurred_at DESC, e.id DESC
     LIMIT ${limite}`;
}

export const aMovimiento = (f: FilaMovimiento): Movimiento => ({
  eventoId: f.evento_id,
  tipo: f.tipo,
  ocurridoEn: f.ocurrido_en,
  unidades: f.unidades,
  tiquetera: f.tiquetera,
  motivo: f.motivo,
  nota: f.nota,
  quien: f.quien,
  corrigeA: f.corrige_a,
});

export type { FilaMovimiento };
