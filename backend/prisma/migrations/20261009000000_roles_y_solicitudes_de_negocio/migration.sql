-- Roles y seguridad · Solicitudes para registrar un negocio y cobertura por municipio.
-- Espejo en docs/arquitectura/modelo-datos/sql (01_core.sql, 03_tenancy.sql,
-- 15_seguridad_rls.sql, 20_semillas_catalogos.sql y 21_semillas_seguridad_planes.sql).

-- ------------------------------------------- dónde opera VECI
-- Por ahora solo Mocoa. Abrir un municipio es cambiar una fila, no el código.
ALTER TABLE core.municipalities ADD COLUMN is_served boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN core.municipalities.is_served IS 'VECI recibe solicitudes de negocios de este municipio (cobertura).';
UPDATE core.municipalities SET is_served = true WHERE official_code = '86001';

-- ------------------------------------------- solicitudes de registro de negocio
-- Cualquier persona con cuenta pide registrar su negocio; Administración VECI lo
-- revisa y, al aprobar, nace el comercio con ella como propietaria.
CREATE TABLE tenancy.business_application_statuses (
  id             smallint PRIMARY KEY,
  code           core.catalog_code NOT NULL UNIQUE,
  name           varchar(80) NOT NULL,
  creates_tenant boolean NOT NULL DEFAULT false,
  is_initial     boolean NOT NULL DEFAULT false,
  is_terminal    boolean NOT NULL DEFAULT false,
  sort_order     smallint NOT NULL DEFAULT 0
);
COMMENT ON TABLE tenancy.business_application_statuses IS 'En revisión, aprobada (crea el comercio), rechazada.';

CREATE TABLE tenancy.business_application_status_transitions (
  from_status_id smallint NOT NULL REFERENCES tenancy.business_application_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES tenancy.business_application_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE tenancy.business_applications (
  id                             uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  applicant_user_id              uuid NOT NULL REFERENCES identity.users (id),
  display_name                   varchar(120) NOT NULL,
  document_type_id               smallint NOT NULL REFERENCES core.document_types (id),
  document_number                varchar(20) NOT NULL,
  business_type_id               smallint NOT NULL REFERENCES tenancy.business_types (id),
  contact_phone                  varchar(20) NOT NULL,
  contact_email                  varchar(254),
  logo_url                       varchar(500),
  municipality_id                integer NOT NULL REFERENCES core.municipalities (id),
  address_line                   varchar(200),
  business_application_status_id smallint NOT NULL REFERENCES tenancy.business_application_statuses (id),
  status_changed_at              timestamptz NOT NULL DEFAULT now(),
  reviewed_by_user_id            uuid REFERENCES identity.users (id),
  review_note                    varchar(500),
  tenant_id                      uuid UNIQUE REFERENCES tenancy.tenants (id),
  created_at                     timestamptz NOT NULL DEFAULT now(),
  updated_at                     timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE tenancy.business_applications IS 'Solicitud de una persona para registrar su negocio; VECI la aprueba o la rechaza.';
CREATE UNIQUE INDEX business_applications_one_open_ux
  ON tenancy.business_applications (applicant_user_id) WHERE reviewed_by_user_id IS NULL;
CREATE INDEX business_applications_status_ix
  ON tenancy.business_applications (business_application_status_id, created_at);

CREATE TRIGGER business_applications_touch BEFORE UPDATE ON tenancy.business_applications
  FOR EACH ROW EXECUTE FUNCTION core.touch_updated_at();
CREATE TRIGGER business_applications_status BEFORE UPDATE OF business_application_status_id ON tenancy.business_applications
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('tenancy.business_application_status_transitions', 'business_application_status_id');

INSERT INTO tenancy.business_application_statuses (id, code, name, creates_tenant, is_initial, is_terminal) VALUES
  (1,'PENDING','En revisión',false,true,false), (2,'APPROVED','Aprobada',true,false,true),
  (3,'REJECTED','Rechazada',false,false,true);
INSERT INTO tenancy.business_application_status_transitions VALUES (1,2),(1,3);

INSERT INTO audit.actions (id, module_id, code, name, is_sensitive) VALUES
  (21,2,'BUSINESS_APPLICATION_SUBMITTED','Solicitud de negocio radicada',false),
  (22,2,'BUSINESS_APPLICATION_REVIEWED','Solicitud de negocio revisada',true);

-- ------------------------------------------- permisos y RLS
GRANT SELECT, INSERT, UPDATE ON tenancy.business_application_statuses,
  tenancy.business_application_status_transitions, tenancy.business_applications TO veci_platform;
GRANT SELECT ON tenancy.business_application_statuses,
  tenancy.business_application_status_transitions TO veci_app;
GRANT SELECT, INSERT, UPDATE ON tenancy.business_applications TO veci_app;

-- ¿El usuario de la sesión tiene este permiso por un rol de plataforma vigente?
-- Lo usan las políticas de la consola VECI: la base no confía solo en el guard.
CREATE FUNCTION identity.current_user_has_platform_permission(p_permission text) RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1
      FROM identity.user_platform_roles upr
      JOIN identity.roles r ON r.id = upr.role_id AND r.is_active
      JOIN identity.role_permissions rp ON rp.role_id = r.id
      JOIN identity.permissions p ON p.id = rp.permission_id AND p.code = p_permission
      JOIN identity.users u ON u.id = upr.user_id
      JOIN identity.user_statuses us ON us.id = u.user_status_id AND us.allows_login
     WHERE upr.user_id = core.current_user_id() AND upr.revoked_at IS NULL);
$$;

ALTER TABLE tenancy.business_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenancy.business_applications FORCE ROW LEVEL SECURITY;
-- La persona ve y radica solo las suyas, siempre en el estado inicial y sin revisión.
CREATE POLICY applicant_self ON tenancy.business_applications FOR SELECT TO veci_app
  USING (applicant_user_id = core.current_user_id());
CREATE POLICY applicant_submits ON tenancy.business_applications FOR INSERT TO veci_app
  WITH CHECK (applicant_user_id = core.current_user_id()
              AND reviewed_by_user_id IS NULL AND tenant_id IS NULL
              AND business_application_status_id IN (SELECT s.id FROM tenancy.business_application_statuses s
                                                      WHERE s.is_initial));
-- Solo Administración VECI (platform.manage_tenants) las lee todas y las decide a su nombre.
CREATE POLICY platform_reviews ON tenancy.business_applications FOR SELECT TO veci_app
  USING (identity.current_user_has_platform_permission('platform.manage_tenants'));
CREATE POLICY platform_decides ON tenancy.business_applications FOR UPDATE TO veci_app
  USING (identity.current_user_has_platform_permission('platform.manage_tenants'))
  WITH CHECK (identity.current_user_has_platform_permission('platform.manage_tenants')
              AND reviewed_by_user_id = core.current_user_id());

-- Administración VECI ve el nombre de quien pide registrar un negocio, y de nadie más.
CREATE POLICY platform_sees_applicants ON identity.people FOR SELECT TO veci_app
  USING (identity.current_user_has_platform_permission('platform.manage_tenants')
         AND id IN (SELECT u.person_id FROM identity.users u
                      JOIN tenancy.business_applications b ON b.applicant_user_id = u.id));
