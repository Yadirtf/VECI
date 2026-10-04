import { randomUUID } from 'node:crypto';
import { Client } from 'pg';
import { ComercioDePrueba } from './base-de-datos';
import { crearPersona, crearUsuario } from './personas';

async function insertarComercio(dueno: Client, comercioId: string): Promise<void> {
  await dueno.query(
    `INSERT INTO tenancy.tenants (id, slug, display_name, document_type_id, document_number, business_type_id, tenant_status_id)
     SELECT $1, $2, 'Comercio de prueba', dt.id, '900000000', bt.id, ts.id
       FROM core.document_types dt, tenancy.business_types bt, tenancy.tenant_statuses ts
      WHERE dt.code = 'NIT' AND bt.code = 'RESTAURANT' AND ts.code = 'ACTIVE'`,
    [comercioId, `prueba-${comercioId}`],
  );
}

async function insertarPersonal(
  dueno: Client,
  comercioId: string,
  usuarioId: string,
): Promise<void> {
  const membresiaId = randomUUID();
  await dueno.query(
    `INSERT INTO tenancy.memberships (id, tenant_id, user_id, membership_status_id)
     SELECT $1, $2, $3, id FROM tenancy.membership_statuses WHERE code = 'ACTIVE'`,
    [membresiaId, comercioId, usuarioId],
  );
  await dueno.query(
    `INSERT INTO tenancy.membership_roles (tenant_id, membership_id, role_id)
     SELECT $1, $2, id FROM identity.roles WHERE code = 'OWNER'`,
    [comercioId, membresiaId],
  );
}

async function insertarSedeYServicio(dueno: Client, c: ComercioDePrueba): Promise<void> {
  await dueno.query(
    `INSERT INTO tenancy.branches (id, tenant_id, name, is_main, branch_status_id)
     SELECT $1, $2, 'Principal', true, id FROM tenancy.branch_statuses WHERE code = 'ACTIVE'`,
    [c.sedeId, c.comercioId],
  );
  await dueno.query(
    `INSERT INTO tenancy.services (id, tenant_id, name) VALUES ($1, $2, 'Almuerzo')`,
    [c.servicioId, c.comercioId],
  );
}

async function insertarAfiliacion(dueno: Client, c: ComercioDePrueba): Promise<void> {
  const clienteId = await crearPersona(dueno);
  await dueno.query(
    `INSERT INTO customers.affiliations (id, tenant_id, person_id, affiliation_status_id, affiliation_channel_id)
     SELECT $1, $2, $3, st.id, ch.id FROM customers.affiliation_statuses st, customers.affiliation_channels ch
      WHERE st.code = 'ACTIVE' AND ch.code = 'PERSONAL_QR_SCAN'`,
    [c.afiliacionId, c.comercioId, clienteId],
  );
}

/**
 * Crea un comercio completo y nuevo en cada ejecución (ids aleatorios), así las
 * pruebas se pueden repetir sobre la misma base. Inserta con el comercio fijado,
 * como lo haría la API, para cumplir RLS aunque el dueño no sea superusuario.
 */
export async function crearComercio(dueno: Client): Promise<ComercioDePrueba> {
  const comercio: ComercioDePrueba = {
    comercioId: randomUUID(),
    usuarioId: await crearUsuario(dueno),
    sedeId: randomUUID(),
    servicioId: randomUUID(),
    afiliacionId: randomUUID(),
  };
  await dueno.query('BEGIN');
  try {
    await dueno.query(`SELECT set_config('app.tenant_id', $1, true)`, [comercio.comercioId]);
    await insertarComercio(dueno, comercio.comercioId);
    await insertarPersonal(dueno, comercio.comercioId, comercio.usuarioId);
    await insertarSedeYServicio(dueno, comercio);
    await insertarAfiliacion(dueno, comercio);
    await dueno.query('COMMIT');
  } catch (error) {
    await dueno.query('ROLLBACK');
    throw error;
  }
  return comercio;
}
