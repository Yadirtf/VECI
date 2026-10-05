-- EP-03 · Comercios, sedes y horarios. Espejo en docs/arquitectura/modelo-datos/sql
-- (03_tenancy.sql, 15_seguridad_rls.sql y 20_semillas_catalogos.sql).

-- ------------------------------------------- servicios sugeridos por tipo de negocio
-- Al registrar un comercio (HU-03-01) nace con los servicios de su tipo y una hora
-- sugerida para cada uno. Un sector nuevo trae sus servicios como filas, no como código.
CREATE TABLE tenancy.business_type_services (
  business_type_id smallint NOT NULL REFERENCES tenancy.business_types (id),
  name             varchar(60) NOT NULL,
  suggested_hours  core.time_range NOT NULL CHECK (NOT isempty(suggested_hours)),
  sort_order       smallint NOT NULL DEFAULT 0,
  PRIMARY KEY (business_type_id, name)
);
COMMENT ON TABLE tenancy.business_type_services IS 'Servicios con que nace un comercio según su tipo, con su horario sugerido (HU-03-01, RNF-ESC-02).';

GRANT SELECT, INSERT, UPDATE ON tenancy.business_type_services TO veci_platform;
GRANT SELECT ON tenancy.business_type_services TO veci_app;

INSERT INTO tenancy.business_type_services (business_type_id, name, suggested_hours, sort_order)
SELECT bt.id, v.nombre, v.horas::core.time_range, v.orden
  FROM (VALUES ('RESTAURANT','Desayuno','[06:30,09:30)',1), ('RESTAURANT','Almuerzo','[11:30,15:00)',2),
               ('RESTAURANT','Cena','[18:00,21:00)',3),
               ('CAFETERIA','Desayuno','[07:00,10:00)',1), ('CAFETERIA','Onces','[15:00,18:00)',2),
               ('BAKERY','Pan de la mañana','[06:00,10:00)',1), ('BAKERY','Pan de la tarde','[16:00,19:00)',2),
               ('SCHOOL','Refrigerio','[09:30,10:00)',1), ('SCHOOL','Almuerzo','[12:00,13:00)',2),
               ('STORE','Atención','[07:00,20:00)',1),
               ('OTHER','Atención','[08:00,18:00)',1)) AS v (tipo, nombre, horas, orden)
  JOIN tenancy.business_types bt ON bt.code = v.tipo;

-- ------------------------------------------- fecha local del comercio
-- "Hoy" para el comercio activo según su zona horaria: los horarios vigentes y los
-- cambios de horario se cortan en la fecha del negocio, no en la del servidor.
CREATE FUNCTION tenancy.current_local_date() RETURNS date
LANGUAGE sql STABLE AS $$
  SELECT (now() AT TIME ZONE t.time_zone)::date
    FROM tenancy.tenants t
   WHERE t.id = core.current_tenant_id();
$$;

-- ------------------------------------------- el comercio nuevo empieza su prueba
-- Al registrarse, el comercio abre su propia suscripción, pero solo a un plan de
-- prueba y en el estado inicial. Los cambios de plan siguen siendo de veci_platform.
GRANT INSERT ON billing.subscriptions TO veci_app;
CREATE POLICY tenant_starts_trial ON billing.subscriptions FOR INSERT TO veci_app
  WITH CHECK (tenant_id = core.current_tenant_id()
              AND plan_id IN (SELECT p.id FROM billing.plans p
                               WHERE p.trial_days IS NOT NULL AND p.is_active)
              AND subscription_status_id IN (SELECT s.id FROM billing.subscription_statuses s
                                              WHERE s.is_initial));
