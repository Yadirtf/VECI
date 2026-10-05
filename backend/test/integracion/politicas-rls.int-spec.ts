import { Client } from 'pg';
import { conectarDueno } from '../soporte/base-de-datos';

/**
 * Datos que no pertenecen a un comercio: de la persona (identidad, QR personal,
 * consentimientos) o de la plataforma. Agregar una tabla aquí es una decisión de
 * diseño que se revisa en el PR; cualquier otra tabla nueva debe llevar tenant_id.
 */
const TABLAS_SIN_COMERCIO = [
  'billing.plan_features',
  'billing.plan_limits',
  'compliance.consents',
  'compliance.data_requests',
  'compliance.policy_versions',
  'core.countries',
  'core.departments',
  'core.holidays',
  'core.municipalities',
  'customers.personal_qr_codes',
  'identity.devices',
  'identity.login_attempts',
  'identity.people',
  'identity.person_contacts',
  'identity.role_permissions',
  'identity.sessions',
  'identity.user_credentials',
  'identity.user_login_identifiers',
  'identity.user_platform_roles',
  'identity.users',
  'notifications.delivery_attempts',
  'notifications.push_tokens',
  'notifications.templates',
  // Plantilla global de servicios por tipo de negocio (EP-03), sin datos de comercios.
  'tenancy.business_type_services',
  'tenancy.tenants',
];

interface Tabla {
  tabla: string;
  tiene_comercio: boolean;
  es_catalogo: boolean;
  rls: boolean;
  rls_forzado: boolean;
  politicas: number;
}

const CONSULTA = `
  SELECT n.nspname || '.' || c.relname AS tabla,
         EXISTS (SELECT 1 FROM pg_attribute a WHERE a.attrelid = c.oid AND a.attname = 'tenant_id' AND NOT a.attisdropped) AS tiene_comercio,
         (EXISTS (SELECT 1 FROM pg_attribute a WHERE a.attrelid = c.oid AND a.attname = 'code' AND NOT a.attisdropped)
           OR c.relname LIKE '%\\_transitions') AS es_catalogo,
         c.relrowsecurity AS rls, c.relforcerowsecurity AS rls_forzado,
         (SELECT count(*)::int FROM pg_policy p WHERE p.polrelid = c.oid) AS politicas
    FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
   WHERE c.relkind IN ('r', 'p') AND NOT c.relispartition
     AND n.nspname IN ('core','identity','tenancy','customers','prepaid','ledger','sales',
                       'consumptions','sync','billing','notifications','compliance','audit')`;

// HU-01-05: toda tabla de negocio tiene comercio_id y una política RLS.
describe('Políticas RLS del modelo', () => {
  let dueno: Client;
  let tablas: Tabla[];

  beforeAll(async () => {
    dueno = await conectarDueno();
    tablas = (await dueno.query<Tabla>(CONSULTA)).rows;
  });

  afterAll(() => dueno.end());

  it('toda tabla con tenant_id tiene RLS forzado y al menos una política', () => {
    const sinProteccion = tablas
      .filter((t) => t.tiene_comercio && !(t.rls && t.rls_forzado && t.politicas > 0))
      .map((t) => t.tabla);
    expect(sinProteccion).toEqual([]);
  });

  it('las tablas sin tenant_id son catálogos o datos globales revisados', () => {
    const inesperadas = tablas
      .filter((t) => !t.tiene_comercio && !t.es_catalogo && !TABLAS_SIN_COMERCIO.includes(t.tabla))
      .map((t) => t.tabla);
    expect(inesperadas).toEqual([]);
  });

  it('veci_api no puede leer una partición por su nombre (saltaría RLS)', async () => {
    const { rows } = await dueno.query<{ particion: string }>(
      `SELECT n.nspname || '.' || c.relname AS particion
         FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relispartition
          AND has_table_privilege('veci_api', c.oid, 'SELECT, INSERT, UPDATE, DELETE')`,
    );
    expect(rows.map((r) => r.particion)).toEqual([]);
  });

  it('la API se conecta con un rol sin BYPASSRLS ni superusuario', async () => {
    const { rows } = await dueno.query(
      `SELECT rolsuper, rolbypassrls FROM pg_roles WHERE rolname IN ('veci_app', 'veci_api')`,
    );
    expect(rows).toHaveLength(2);
    expect(rows.every((r) => !r.rolsuper && !r.rolbypassrls)).toBe(true);
  });
});
