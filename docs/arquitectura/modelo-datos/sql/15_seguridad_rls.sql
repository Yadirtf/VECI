-- =============================================================================
-- 15 · Seguridad: roles de base de datos, permisos y Row Level Security
-- La API se conecta con un usuario miembro de veci_app y, en cada transacción:
--   SET LOCAL app.tenant_id = '<comercio activo>';   -- cajero / propietario
--   SET LOCAL app.person_id = '<persona del token>'; -- cliente en su app
--   SET LOCAL app.user_id = '<usuario del token>';   -- elegir comercio (solo lectura)
-- Sin contexto, las políticas no devuelven filas (denegar por defecto).
-- =============================================================================

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'veci_app') THEN
    CREATE ROLE veci_app NOLOGIN NOBYPASSRLS;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'veci_platform') THEN
    CREATE ROLE veci_platform NOLOGIN BYPASSRLS;  -- consola VECI y procesos programados
  END IF;
END $$;

-- ------------------------------------------------------------- permisos
-- Nadie borra filas: se cambian estados o se registran eventos de corrección.
DO $$
DECLARE
  s text;
BEGIN
  FOREACH s IN ARRAY ARRAY['core','identity','tenancy','customers','prepaid','ledger',
                           'sales','consumptions','sync','billing','notifications',
                           'compliance','audit']
  LOOP
    EXECUTE format('GRANT USAGE ON SCHEMA %I TO veci_app, veci_platform', s);
    EXECUTE format('GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA %I TO veci_platform', s);
    EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA %I TO veci_app', s);
  END LOOP;
END $$;

GRANT USAGE ON SEQUENCE core.sync_version_seq TO veci_app, veci_platform;

-- La app escribe en tablas de negocio; los catálogos y la facturación de VECI son de solo lectura para ella.
GRANT INSERT, UPDATE ON
  identity.people, identity.person_contacts, identity.users, identity.user_login_identifiers,
  identity.user_credentials, identity.devices, identity.sessions,
  tenancy.tenants, tenancy.tenant_contacts, tenancy.tenant_settings, tenancy.branches,
  tenancy.memberships, tenancy.membership_roles, tenancy.membership_branches, tenancy.tenant_devices,
  tenancy.services, tenancy.service_schedules,
  customers.personal_qr_codes, customers.affiliations, customers.affiliation_qr_codes, customers.balance_links,
  prepaid.consumption_units, prepaid.package_types, prepaid.packages,
  sales.sales, sync.inbound_events, sync.device_checkpoints, sync.conflicts,
  notifications.push_tokens, notifications.notifications,
  compliance.consents, compliance.data_requests
TO veci_app;

GRANT INSERT ON
  identity.login_attempts, ledger.events, ledger.movements,
  sales.sale_items, sales.sale_payments, sales.cash_closings,
  consumptions.consumptions, consumptions.consumption_overrides,
  sync.sync_batches, sync.conflict_events, notifications.delivery_attempts, audit.audit_log
TO veci_app;

-- ------------------------------------------- aislamiento por comercio (genérico)
-- Toda tabla con tenant_id NOT NULL recibe la misma política estricta.
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT c.table_schema, c.table_name
      FROM information_schema.columns c
      JOIN information_schema.tables t
        ON t.table_schema = c.table_schema AND t.table_name = c.table_name
     WHERE c.column_name = 'tenant_id'
       AND c.is_nullable = 'NO'
       AND t.table_type = 'BASE TABLE'
       AND c.table_schema IN ('tenancy','customers','prepaid','ledger','sales',
                              'consumptions','sync','billing')
  LOOP
    EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', r.table_schema, r.table_name);
    EXECUTE format('ALTER TABLE %I.%I FORCE ROW LEVEL SECURITY', r.table_schema, r.table_name);
    EXECUTE format(
      'CREATE POLICY tenant_isolation ON %I.%I FOR ALL TO veci_app
         USING (tenant_id = core.current_tenant_id())
         WITH CHECK (tenant_id = core.current_tenant_id())',
      r.table_schema, r.table_name);
  END LOOP;
END $$;

-- ------------------------------------------- el comercio en sí
ALTER TABLE tenancy.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenancy.tenants FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_self ON tenancy.tenants FOR ALL TO veci_app
  USING (id = core.current_tenant_id()) WITH CHECK (id = core.current_tenant_id());
CREATE POLICY customer_reads_my_tenants ON tenancy.tenants FOR SELECT TO veci_app
  USING (id IN (SELECT a.tenant_id FROM customers.affiliations a
                 WHERE a.person_id = core.current_person_id()));

-- ------------------------------------------- el personal ve sus propios lugares de trabajo
-- Para elegir el comercio activo (HU-02-03), el usuario lee solo sus membresías,
-- sus roles y el nombre de esos comercios. Nunca escribe con este contexto.
CREATE POLICY staff_self ON tenancy.memberships FOR SELECT TO veci_app
  USING (user_id = core.current_user_id());
CREATE POLICY staff_self ON tenancy.membership_roles FOR SELECT TO veci_app
  USING (membership_id IN (SELECT m.id FROM tenancy.memberships m
                            WHERE m.user_id = core.current_user_id()));
CREATE POLICY staff_reads_my_tenants ON tenancy.tenants FOR SELECT TO veci_app
  USING (id IN (SELECT m.tenant_id FROM tenancy.memberships m
                 WHERE m.user_id = core.current_user_id()));

-- ------------------------------------------- el cliente ve lo suyo en todos sus comercios
CREATE POLICY customer_self ON customers.affiliations FOR SELECT TO veci_app
  USING (person_id = core.current_person_id());

DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['customers.affiliation_qr_codes','prepaid.packages','ledger.events']
  LOOP
    EXECUTE format(
      'CREATE POLICY customer_self ON %s FOR SELECT TO veci_app
         USING (affiliation_id IN (SELECT a.id FROM customers.affiliations a
                                    WHERE a.person_id = core.current_person_id()))', t);
  END LOOP;
END $$;

CREATE POLICY customer_self ON ledger.movements FOR SELECT TO veci_app
  USING (package_id IN (SELECT p.id FROM prepaid.packages p));          -- hereda la política de packages
CREATE POLICY customer_self ON consumptions.consumptions FOR SELECT TO veci_app
  USING (event_id IN (SELECT e.id FROM ledger.events e));               -- hereda la política de events
CREATE POLICY customer_self ON prepaid.package_types FOR SELECT TO veci_app
  USING (id IN (SELECT p.package_type_id FROM prepaid.packages p));
CREATE POLICY customer_self ON tenancy.branches FOR SELECT TO veci_app
  USING (tenant_id IN (SELECT a.tenant_id FROM customers.affiliations a
                        WHERE a.person_id = core.current_person_id()));

-- La facturación de VECI: el comercio la lee, solo veci_platform la escribe.
DROP POLICY tenant_isolation ON billing.subscriptions;
DROP POLICY tenant_isolation ON billing.subscription_payments;
CREATE POLICY tenant_reads ON billing.subscriptions FOR SELECT TO veci_app
  USING (tenant_id = core.current_tenant_id());
CREATE POLICY tenant_reads ON billing.subscription_payments FOR SELECT TO veci_app
  USING (tenant_id = core.current_tenant_id());

-- ------------------------------------------- tablas con tenant_id opcional
ALTER TABLE prepaid.consumption_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE prepaid.consumption_units FORCE ROW LEVEL SECURITY;
CREATE POLICY global_or_tenant ON prepaid.consumption_units FOR SELECT TO veci_app
  USING (tenant_id IS NULL OR tenant_id = core.current_tenant_id());
CREATE POLICY tenant_writes ON prepaid.consumption_units FOR ALL TO veci_app
  USING (tenant_id = core.current_tenant_id()) WITH CHECK (tenant_id = core.current_tenant_id());

ALTER TABLE notifications.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications.notifications FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_or_recipient ON notifications.notifications FOR ALL TO veci_app
  USING (tenant_id = core.current_tenant_id() OR recipient_person_id = core.current_person_id())
  WITH CHECK (tenant_id = core.current_tenant_id());

ALTER TABLE audit.audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit.audit_log FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_reads ON audit.audit_log FOR SELECT TO veci_app
  USING (tenant_id = core.current_tenant_id());
CREATE POLICY app_appends ON audit.audit_log FOR INSERT TO veci_app
  WITH CHECK (tenant_id IS NULL OR tenant_id = core.current_tenant_id());

-- ------------------------------------------- datos personales (globales)
-- Un comercio solo ve a las personas afiliadas a él o que trabajan en él;
-- la persona se ve a sí misma. No se usa FORCE: las funciones SECURITY DEFINER
-- del dueño del esquema (búsqueda por documento) pueden consultar sin RLS.
ALTER TABLE identity.people ENABLE ROW LEVEL SECURITY;
CREATE POLICY visible_people ON identity.people FOR SELECT TO veci_app
  USING (
    id = core.current_person_id()
    OR id IN (SELECT a.person_id FROM customers.affiliations a)
    OR id IN (SELECT u.person_id FROM identity.users u
                JOIN tenancy.memberships m ON m.user_id = u.id)
  );
CREATE POLICY register_people ON identity.people FOR INSERT TO veci_app WITH CHECK (true);
CREATE POLICY self_update ON identity.people FOR UPDATE TO veci_app
  USING (id = core.current_person_id()) WITH CHECK (id = core.current_person_id());

ALTER TABLE identity.person_contacts ENABLE ROW LEVEL SECURITY;
CREATE POLICY visible_contacts ON identity.person_contacts FOR SELECT TO veci_app
  USING (person_id IN (SELECT p.id FROM identity.people p));            -- hereda la política de people
CREATE POLICY register_contacts ON identity.person_contacts FOR INSERT TO veci_app WITH CHECK (true);
CREATE POLICY self_update ON identity.person_contacts FOR UPDATE TO veci_app
  USING (person_id = core.current_person_id()) WITH CHECK (person_id = core.current_person_id());

-- ------------------------------------------- búsqueda global sin exponer datos
-- Registro asistido (HU-04-04): ¿ya existe esta persona en VECI? Devuelve solo
-- el id y datos enmascarados, nunca el registro completo de otro comercio.
CREATE FUNCTION customers.find_person_by_document(p_document_type core.catalog_code, p_number varchar)
RETURNS TABLE (person_id uuid, masked_name text, masked_document text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
  SELECT p.id,
         p.given_names || ' ' || left(coalesce(p.family_names, ''), 1) || '.',
         repeat('*', greatest(length(p.document_number) - 4, 0)) || right(p.document_number, 4)
    FROM identity.people p
    JOIN core.document_types dt ON dt.id = p.document_type_id
   WHERE dt.code = p_document_type
     AND p.document_number = p_number;
$$;
REVOKE ALL ON FUNCTION customers.find_person_by_document(core.catalog_code, varchar) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION customers.find_person_by_document(core.catalog_code, varchar) TO veci_app;

-- ------------------------------------------- particiones sin acceso directo
-- Las tablas particionadas aplican RLS en la tabla madre; leer una partición por
-- su nombre saltaría las políticas. veci_app solo entra por la tabla madre.
-- Quien cree particiones nuevas (proceso mensual) debe repetir este REVOKE.
DO $$
DECLARE
  p record;
BEGIN
  FOR p IN SELECT n.nspname, c.relname
             FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE c.relispartition AND c.relkind IN ('r', 'p')
  LOOP
    EXECUTE format('REVOKE ALL ON %I.%I FROM veci_app', p.nspname, p.relname);
  END LOOP;
END $$;
