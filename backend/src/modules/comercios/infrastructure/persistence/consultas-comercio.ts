import { Prisma } from '../../../../../generated/prisma/client';
import { PerfilComercio } from '../../domain/entities/comercio';

/** Fila del perfil del comercio activo, con su plan y lo que ya configuró. */
export interface FilaPerfil {
  id: string;
  nombre: string;
  slug: string;
  tipo: string;
  doc_tipo: string;
  doc_numero: string;
  celular: string | null;
  correo: string | null;
  logo_url: string | null;
  estado: string;
  abierto: boolean;
  plan_codigo: string | null;
  plan_nombre: string | null;
  plan_estado: string | null;
  plan_vence: string | null;
  servicios_con_horario: number;
  cajeros: number;
  tiqueteras: number;
}

export const CONSULTA_PERFIL = Prisma.sql`
  SELECT t.id::text, t.display_name AS nombre, t.slug, bt.code AS tipo,
         dt.code AS doc_tipo, t.document_number AS doc_numero,
         (SELECT c.value FROM tenancy.tenant_contacts c JOIN core.contact_types ct ON ct.id = c.contact_type_id
           WHERE c.is_primary AND ct.code = 'MOBILE_PHONE') AS celular,
         (SELECT c.value FROM tenancy.tenant_contacts c JOIN core.contact_types ct ON ct.id = c.contact_type_id
           WHERE c.is_primary AND ct.code = 'EMAIL') AS correo,
         t.logo_url, ts.code AS estado, ts.allows_operations AS abierto,
         p.code AS plan_codigo, p.name AS plan_nombre, ss.code AS plan_estado,
         to_char(s.current_period_ends_at AT TIME ZONE t.time_zone, 'YYYY-MM-DD') AS plan_vence,
         (SELECT count(DISTINCT sch.service_id)::int FROM tenancy.service_schedules sch
           WHERE sch.is_active AND sch.valid_during @> tenancy.current_local_date()) AS servicios_con_horario,
         (SELECT count(*)::int FROM tenancy.memberships m
            JOIN tenancy.membership_statuses ms ON ms.id = m.membership_status_id
            JOIN tenancy.membership_roles mr ON mr.membership_id = m.id AND mr.revoked_at IS NULL
            JOIN identity.roles r ON r.id = mr.role_id AND r.code = 'CASHIER'
           WHERE ms.allows_login OR ms.is_initial) AS cajeros,
         (SELECT count(*)::int FROM prepaid.package_types pt
            JOIN prepaid.package_type_statuses pts ON pts.id = pt.package_type_status_id
           WHERE pts.allows_sale) AS tiqueteras
    FROM tenancy.tenants t
    JOIN tenancy.business_types bt ON bt.id = t.business_type_id
    JOIN core.document_types dt ON dt.id = t.document_type_id
    JOIN tenancy.tenant_statuses ts ON ts.id = t.tenant_status_id
    LEFT JOIN billing.subscriptions s ON s.tenant_id = t.id AND s.ended_at IS NULL
    LEFT JOIN billing.plans p ON p.id = s.plan_id
    LEFT JOIN billing.subscription_statuses ss ON ss.id = s.subscription_status_id
   WHERE t.id = core.current_tenant_id()`;

export function aPerfil(f: FilaPerfil): PerfilComercio {
  return {
    comercioId: f.id,
    nombre: f.nombre,
    slug: f.slug,
    tipoNegocio: f.tipo,
    documento: { tipo: f.doc_tipo, numero: f.doc_numero },
    contacto: { celular: f.celular, correo: f.correo },
    logoUrl: f.logo_url,
    estado: f.estado,
    abierto: f.abierto,
    plan:
      f.plan_codigo && f.plan_nombre && f.plan_estado && f.plan_vence
        ? {
            codigo: f.plan_codigo,
            nombre: f.plan_nombre,
            estado: f.plan_estado,
            venceEl: f.plan_vence,
          }
        : null,
    avance: {
      serviciosConHorario: f.servicios_con_horario,
      cajeros: f.cajeros,
      tiqueteras: f.tiqueteras,
    },
  };
}
