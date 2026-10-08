import { Prisma } from '../../../../../generated/prisma/client';

export interface FilaVenta {
  venta_id: string;
  cliente_id: string;
  tipo_id: string;
  tiquetera_id: string;
  precio: number;
  medio: string;
  canal: string | null;
  referencia: string | null;
  ocurrida_en: Date;
  origen: string;
  estado: string;
  cliente: string;
  tiquetera: string;
  cajero: string | null;
  saldo: number;
}

/** "Luz Marina C.": nombre corto de una persona (alias dado). */
const corto = (alias: string) =>
  Prisma.raw(`${alias}.given_names || coalesce(' ' || left(${alias}.family_names, 1) || '.', '')`);

/** Una venta por id, o las últimas del comercio (la más reciente primero). */
export function consultaVentas(filtro: { ventaId: string } | { limite: number }): Prisma.Sql {
  const donde =
    'ventaId' in filtro ? Prisma.sql`WHERE s.event_id = ${filtro.ventaId}::uuid` : Prisma.empty;
  const tope = 'limite' in filtro ? Prisma.sql`LIMIT ${filtro.limite}` : Prisma.empty;
  return Prisma.sql`
    SELECT s.event_id::text AS venta_id, e.affiliation_id::text AS cliente_id,
           si.package_type_id::text AS tipo_id, p.id::text AS tiquetera_id,
           si.unit_price::int AS precio, pm.code AS medio, pc.code AS canal,
           sp.reference AS referencia, e.occurred_at AS ocurrida_en, eo.code AS origen,
           ss.code AS estado, ${corto('cli')} AS cliente, pt.name AS tiquetera,
           ${corto('caj')} AS cajero, p.units_balance AS saldo
      FROM sales.sales s
      JOIN sales.sale_statuses ss ON ss.id = s.sale_status_id
      JOIN ledger.events e ON e.id = s.event_id
      JOIN ledger.event_origins eo ON eo.id = e.event_origin_id
      JOIN sales.sale_items si ON si.sale_id = s.event_id AND si.line_number = 1
      JOIN prepaid.package_types pt ON pt.id = si.package_type_id
      JOIN prepaid.packages p ON p.sale_item_id = si.id
      JOIN LATERAL (SELECT * FROM sales.sale_payments x WHERE x.sale_id = s.event_id
                     ORDER BY x.id LIMIT 1) sp ON true
      JOIN core.payment_methods pm ON pm.id = sp.payment_method_id
      LEFT JOIN core.payment_channels pc ON pc.id = sp.payment_channel_id
      JOIN customers.affiliations a ON a.id = e.affiliation_id
      JOIN identity.people cli ON cli.id = a.person_id
      LEFT JOIN tenancy.memberships mb ON mb.id = e.actor_membership_id
      LEFT JOIN identity.users us ON us.id = mb.user_id
      LEFT JOIN identity.people caj ON caj.id = us.person_id
      ${donde}
     ORDER BY e.occurred_at DESC, s.event_id DESC
     ${tope}`;
}
