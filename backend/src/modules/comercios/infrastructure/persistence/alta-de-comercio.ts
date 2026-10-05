import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { ClienteTransaccion } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { AltaDeComercio } from '../../application/puertos/comercios.repository';

/** Intentos de slug antes de añadir un sufijo con parte del id. */
const INTENTOS_SLUG = 5;

/**
 * El comercio en su estado inicial. Como RLS no deja ver los slugs de otros
 * comercios, se intenta insertar y, si ya existe, se prueba "nombre-2", "nombre-3"...
 */
export async function crearComercio(tx: ClienteTransaccion, alta: AltaDeComercio): Promise<string> {
  const base = alta.nombre.slug;
  const candidatos = Array.from({ length: INTENTOS_SLUG }, (_, i) =>
    i ? `${base}-${i + 1}` : base,
  );
  candidatos.push(`${base}-${alta.comercioId.slice(-8)}`);
  for (const slug of candidatos) {
    const insertadas = await tx.$executeRaw`
      INSERT INTO tenancy.tenants (id, slug, display_name, document_type_id, document_number,
                                   business_type_id, tenant_status_id, logo_url, created_by_user_id)
      SELECT ${alta.comercioId}::uuid, ${slug}, ${alta.nombre.valor}, dt.id, ${alta.documento.numero},
             bt.id, ts.id, ${alta.logoUrl}, ${alta.creadoPor}::uuid
        FROM core.document_types dt, tenancy.business_types bt, tenancy.tenant_statuses ts
       WHERE dt.code = ${alta.documento.tipo} AND bt.code = ${alta.tipoNegocio} AND bt.is_active
         AND ts.is_initial
      ON CONFLICT (slug) DO NOTHING`;
    if (insertadas === 1) return slug;
  }
  throw new DatoInvalido('No pudimos crear el enlace del negocio. Prueba con otro nombre.');
}

/** Celular (y correo) del negocio como contactos principales. */
export async function crearContactos(tx: ClienteTransaccion, alta: AltaDeComercio): Promise<void> {
  await tx.$executeRaw`
    INSERT INTO tenancy.tenant_contacts (tenant_id, contact_type_id, value, is_primary)
    SELECT core.current_tenant_id(), ct.id, v.valor, true
      FROM (VALUES ('MOBILE_PHONE', ${alta.celular}::text), ('EMAIL', ${alta.correo}::text)) AS v (tipo, valor)
      JOIN core.contact_types ct ON ct.code = v.tipo
     WHERE v.valor IS NOT NULL`;
}

/** Sede principal y los servicios sugeridos para el tipo de negocio. */
export async function crearSedeYServicios(
  tx: ClienteTransaccion,
  alta: AltaDeComercio,
): Promise<void> {
  await tx.$executeRaw`
    INSERT INTO tenancy.branches (tenant_id, name, is_main, branch_status_id, municipality_id, address_line)
    SELECT core.current_tenant_id(), 'Principal', true, bs.id, ${alta.municipioId}::integer, ${alta.direccion}
      FROM tenancy.branch_statuses bs WHERE bs.code = 'ACTIVE'`;
  await tx.$executeRaw`
    INSERT INTO tenancy.services (tenant_id, name, sort_order)
    SELECT core.current_tenant_id(), bts.name, bts.sort_order
      FROM tenancy.business_type_services bts
      JOIN tenancy.business_types bt ON bt.id = bts.business_type_id
     WHERE bt.code = ${alta.tipoNegocio}`;
}

/** Membresía activa con el rol de propietario para quien registra su propio negocio. */
export async function crearPropietario(
  tx: ClienteTransaccion,
  alta: AltaDeComercio,
  membresiaId: string,
): Promise<void> {
  if (!alta.propietarioId) return;
  await tx.$executeRaw`
    INSERT INTO tenancy.memberships (id, tenant_id, user_id, membership_status_id, joined_at)
    SELECT ${membresiaId}::uuid, core.current_tenant_id(), ${alta.propietarioId}::uuid, ms.id, now()
      FROM tenancy.membership_statuses ms WHERE ms.code = 'ACTIVE'`;
  await tx.$executeRaw`
    INSERT INTO tenancy.membership_roles (tenant_id, membership_id, role_id, granted_by_user_id)
    SELECT core.current_tenant_id(), ${membresiaId}::uuid, r.id, ${alta.creadoPor}::uuid
      FROM identity.roles r WHERE r.code = 'OWNER'`;
}

/** Suscripción al plan de prueba vigente, en su estado inicial (política tenant_starts_trial). */
export async function iniciarPrueba(tx: ClienteTransaccion): Promise<void> {
  await tx.$executeRaw`
    INSERT INTO billing.subscriptions (tenant_id, plan_id, subscription_status_id, current_period_ends_at)
    SELECT core.current_tenant_id(), p.id, s.id, now() + make_interval(days => p.trial_days)
      FROM billing.plans p, billing.subscription_statuses s
     WHERE p.trial_days IS NOT NULL AND p.is_active AND s.is_initial
     ORDER BY p.id
     LIMIT 1`;
}
