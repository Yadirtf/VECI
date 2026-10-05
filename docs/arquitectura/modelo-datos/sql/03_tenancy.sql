-- =============================================================================
-- 03 · tenancy: comercios, sedes, membresías del personal, horarios y ajustes
-- Toda tabla de negocio lleva tenant_id (comercio) y se aísla con RLS (archivo 16).
-- =============================================================================

CREATE SCHEMA tenancy;

-- ----------------------------------------------------------------- catálogos
CREATE TABLE tenancy.business_types (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  description text,
  sort_order  smallint NOT NULL DEFAULT 0,
  is_active   boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE tenancy.business_types IS 'Restaurante, cafetería, panadería, colegio, tienda... Nuevo sector = nueva fila (RF-COM-04, RNF-ESC-02).';

CREATE TABLE tenancy.business_type_services (
  business_type_id smallint NOT NULL REFERENCES tenancy.business_types (id),
  name             varchar(60) NOT NULL,
  suggested_hours  core.time_range NOT NULL CHECK (NOT isempty(suggested_hours)),
  sort_order       smallint NOT NULL DEFAULT 0,
  PRIMARY KEY (business_type_id, name)
);
COMMENT ON TABLE tenancy.business_type_services IS 'Servicios con que nace un comercio según su tipo, con su horario sugerido (HU-03-01, RNF-ESC-02).';

CREATE TABLE tenancy.tenant_statuses (
  id                smallint PRIMARY KEY,
  code              core.catalog_code NOT NULL UNIQUE,
  name              varchar(80) NOT NULL,
  description       text,
  allows_operations boolean NOT NULL,
  is_initial        boolean NOT NULL DEFAULT false,
  is_terminal       boolean NOT NULL DEFAULT false,
  sort_order        smallint NOT NULL DEFAULT 0
);
COMMENT ON TABLE tenancy.tenant_statuses IS 'Estado administrativo del comercio (alta, activo, suspendido por VECI, cerrado). El estado de pago vive en billing.';

CREATE TABLE tenancy.tenant_status_transitions (
  from_status_id smallint NOT NULL REFERENCES tenancy.tenant_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES tenancy.tenant_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE tenancy.branch_statuses (
  id                smallint PRIMARY KEY,
  code              core.catalog_code NOT NULL UNIQUE,
  name              varchar(80) NOT NULL,
  allows_operations boolean NOT NULL,
  sort_order        smallint NOT NULL DEFAULT 0
);

CREATE TABLE tenancy.branch_status_transitions (
  from_status_id smallint NOT NULL REFERENCES tenancy.branch_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES tenancy.branch_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE tenancy.membership_statuses (
  id                smallint PRIMARY KEY,
  code              core.catalog_code NOT NULL UNIQUE,
  name              varchar(80) NOT NULL,
  description       text,
  allows_login      boolean NOT NULL,
  is_initial        boolean NOT NULL DEFAULT false,
  is_terminal       boolean NOT NULL DEFAULT false,
  sort_order        smallint NOT NULL DEFAULT 0
);
COMMENT ON TABLE tenancy.membership_statuses IS 'Invitado, activo, suspendido, retirado (RF-AUT-05).';

CREATE TABLE tenancy.membership_status_transitions (
  from_status_id smallint NOT NULL REFERENCES tenancy.membership_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES tenancy.membership_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE tenancy.setting_definitions (
  id            smallint PRIMARY KEY,
  module_id     smallint NOT NULL REFERENCES core.modules (id),
  code          core.catalog_code NOT NULL UNIQUE,
  name          varchar(120) NOT NULL,
  description   text,
  data_type_id  smallint NOT NULL REFERENCES core.data_types (id),
  default_value text NOT NULL,
  min_value     numeric,
  max_value     numeric
);
COMMENT ON TABLE tenancy.setting_definitions IS 'Parámetros configurables por comercio (aviso de renovación en N unidades, días de inactividad...).';

-- ----------------------------------------------------------------- comercios
CREATE TABLE tenancy.tenants (
  id                 uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  slug               varchar(60) NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  display_name       varchar(120) NOT NULL,
  legal_name         varchar(160),
  document_type_id   smallint NOT NULL REFERENCES core.document_types (id),
  document_number    varchar(20) NOT NULL,
  business_type_id   smallint NOT NULL REFERENCES tenancy.business_types (id),
  tenant_status_id   smallint NOT NULL REFERENCES tenancy.tenant_statuses (id),
  status_changed_at  timestamptz NOT NULL DEFAULT now(),
  currency_code      char(3) NOT NULL DEFAULT 'COP' REFERENCES core.currencies (code),
  time_zone          varchar(64) NOT NULL DEFAULT 'America/Bogota',
  logo_url           varchar(500),
  created_by_user_id uuid REFERENCES identity.users (id),
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE tenancy.tenants IS 'Comercio (tenant). Raíz del aislamiento multi-comercio.';
CREATE INDEX tenants_document_ix ON tenancy.tenants (document_type_id, document_number);

CREATE TABLE tenancy.tenant_contacts (
  id              uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id       uuid NOT NULL REFERENCES tenancy.tenants (id),
  contact_type_id smallint NOT NULL REFERENCES core.contact_types (id),
  value           varchar(120) NOT NULL,
  is_primary      boolean NOT NULL DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, contact_type_id, value)
);
CREATE UNIQUE INDEX tenant_contacts_one_primary_ux
  ON tenancy.tenant_contacts (tenant_id, contact_type_id) WHERE is_primary;

CREATE TABLE tenancy.tenant_settings (
  tenant_id             uuid NOT NULL REFERENCES tenancy.tenants (id),
  setting_definition_id smallint NOT NULL REFERENCES tenancy.setting_definitions (id),
  value                 text NOT NULL,
  updated_by_user_id    uuid REFERENCES identity.users (id),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, setting_definition_id)
);
COMMENT ON TABLE tenancy.tenant_settings IS 'Valor que un comercio da a un parámetro. Sin fila = se usa default_value.';

CREATE TABLE tenancy.tenant_signing_keys (
  id               uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id        uuid NOT NULL REFERENCES tenancy.tenants (id),
  key_id           varchar(40) NOT NULL,
  algorithm        varchar(20) NOT NULL DEFAULT 'Ed25519',
  public_key       bytea NOT NULL,
  private_key_ref  varchar(200) NOT NULL,
  activated_at     timestamptz NOT NULL DEFAULT now(),
  retired_at       timestamptz,
  sync_version     bigint NOT NULL DEFAULT 0,
  UNIQUE (tenant_id, key_id),
  UNIQUE (tenant_id, id)
);
COMMENT ON TABLE tenancy.tenant_signing_keys IS 'Claves para firmar QR. La pública baja al celular del cajero; la privada vive en el gestor de secretos (solo su referencia).';
CREATE UNIQUE INDEX tenant_signing_keys_active_ux
  ON tenancy.tenant_signing_keys (tenant_id) WHERE retired_at IS NULL;

-- "Hoy" para el comercio activo según su zona horaria (EP-03): los horarios vigentes
-- y los cambios de horario se cortan en la fecha del negocio, no en la del servidor.
CREATE FUNCTION tenancy.current_local_date() RETURNS date
LANGUAGE sql STABLE AS $$
  SELECT (now() AT TIME ZONE t.time_zone)::date
    FROM tenancy.tenants t
   WHERE t.id = core.current_tenant_id();
$$;

-- ----------------------------------------------------------------- sedes
CREATE TABLE tenancy.branches (
  id                uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id         uuid NOT NULL REFERENCES tenancy.tenants (id),
  name              varchar(120) NOT NULL,
  is_main           boolean NOT NULL DEFAULT false,
  branch_status_id  smallint NOT NULL REFERENCES tenancy.branch_statuses (id),
  status_changed_at timestamptz NOT NULL DEFAULT now(),
  municipality_id   integer REFERENCES core.municipalities (id),
  address_line      varchar(200),
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, name),
  UNIQUE (tenant_id, id)
);
COMMENT ON TABLE tenancy.branches IS 'Sede o punto físico. Todo comercio nace con su sede principal.';
CREATE UNIQUE INDEX branches_one_main_ux ON tenancy.branches (tenant_id) WHERE is_main;

-- --------------------------------------------- membresías (personal del comercio)
CREATE TABLE tenancy.memberships (
  id                     uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id              uuid NOT NULL REFERENCES tenancy.tenants (id),
  user_id                uuid NOT NULL REFERENCES identity.users (id),
  membership_status_id   smallint NOT NULL REFERENCES tenancy.membership_statuses (id),
  status_changed_at      timestamptz NOT NULL DEFAULT now(),
  invited_by_user_id     uuid REFERENCES identity.users (id),
  invited_at             timestamptz NOT NULL DEFAULT now(),
  joined_at              timestamptz,
  created_at             timestamptz NOT NULL DEFAULT now(),
  updated_at             timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, user_id),
  UNIQUE (tenant_id, id)
);
COMMENT ON TABLE tenancy.memberships IS 'Intermedia usuario-comercio para el personal (propietario, cajero). RF-AUT-04.';
CREATE INDEX memberships_user_ix ON tenancy.memberships (user_id);

CREATE TABLE tenancy.membership_roles (
  id                       uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id                uuid NOT NULL,
  membership_id            uuid NOT NULL,
  role_id                  smallint NOT NULL,
  assignable_to_membership boolean NOT NULL DEFAULT true CHECK (assignable_to_membership),
  granted_by_user_id       uuid REFERENCES identity.users (id),
  granted_at               timestamptz NOT NULL DEFAULT now(),
  revoked_at               timestamptz,
  revoked_by_user_id       uuid REFERENCES identity.users (id),
  FOREIGN KEY (tenant_id, membership_id) REFERENCES tenancy.memberships (tenant_id, id),
  FOREIGN KEY (role_id, assignable_to_membership) REFERENCES identity.roles (id, assignable_to_membership)
);
COMMENT ON TABLE tenancy.membership_roles IS 'Intermedia membresía-rol con vigencia: los cambios de permisos quedan en la historia (RNF-SEG-05).';
CREATE UNIQUE INDEX membership_roles_current_ux
  ON tenancy.membership_roles (membership_id, role_id) WHERE revoked_at IS NULL;

CREATE TABLE tenancy.membership_branches (
  id                 uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id          uuid NOT NULL,
  membership_id      uuid NOT NULL,
  branch_id          uuid NOT NULL,
  assigned_by_user_id uuid REFERENCES identity.users (id),
  assigned_at        timestamptz NOT NULL DEFAULT now(),
  revoked_at         timestamptz,
  FOREIGN KEY (tenant_id, membership_id) REFERENCES tenancy.memberships (tenant_id, id),
  FOREIGN KEY (tenant_id, branch_id) REFERENCES tenancy.branches (tenant_id, id)
);
COMMENT ON TABLE tenancy.membership_branches IS 'Intermedia membresía-sede: en qué sedes trabaja cada cajero (HU-03-03).';
CREATE UNIQUE INDEX membership_branches_current_ux
  ON tenancy.membership_branches (membership_id, branch_id) WHERE revoked_at IS NULL;

CREATE TABLE tenancy.tenant_devices (
  id                    uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id             uuid NOT NULL REFERENCES tenancy.tenants (id),
  device_id             uuid NOT NULL REFERENCES identity.devices (id),
  branch_id             uuid,
  name                  varchar(80),
  registered_by_user_id uuid REFERENCES identity.users (id),
  registered_at         timestamptz NOT NULL DEFAULT now(),
  revoked_at            timestamptz,
  FOREIGN KEY (tenant_id, branch_id) REFERENCES tenancy.branches (tenant_id, id),
  UNIQUE (tenant_id, id)
);
COMMENT ON TABLE tenancy.tenant_devices IS 'Celulares del negocio autorizados para la caja (RF-AUT-06).';
CREATE UNIQUE INDEX tenant_devices_current_ux
  ON tenancy.tenant_devices (tenant_id, device_id) WHERE revoked_at IS NULL;

-- ------------------------------------------------- servicios y horarios
CREATE TABLE tenancy.services (
  id           uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id    uuid NOT NULL REFERENCES tenancy.tenants (id),
  name         varchar(60) NOT NULL,
  sort_order   smallint NOT NULL DEFAULT 0,
  is_active    boolean NOT NULL DEFAULT true,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  sync_version bigint NOT NULL DEFAULT 0,
  UNIQUE (tenant_id, name),
  UNIQUE (tenant_id, id)
);
COMMENT ON TABLE tenancy.services IS 'Servicio que ofrece el comercio: desayuno, almuerzo, cena (o recreo en un colegio).';

CREATE TABLE tenancy.service_schedules (
  id           uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id    uuid NOT NULL,
  service_id   uuid NOT NULL,
  branch_id    uuid NOT NULL,
  weekday_id   smallint NOT NULL REFERENCES core.weekdays (id),
  hours        core.time_range NOT NULL CHECK (NOT isempty(hours)),
  valid_during daterange NOT NULL DEFAULT daterange(current_date, NULL, '[)'),
  is_active    boolean NOT NULL DEFAULT true,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  sync_version bigint NOT NULL DEFAULT 0,
  FOREIGN KEY (tenant_id, service_id) REFERENCES tenancy.services (tenant_id, id),
  FOREIGN KEY (tenant_id, branch_id) REFERENCES tenancy.branches (tenant_id, id),
  UNIQUE (tenant_id, id),
  CONSTRAINT service_schedules_no_overlap EXCLUDE USING gist (
    branch_id WITH =, weekday_id WITH =, hours WITH &&, valid_during WITH &&
  ) WHERE (is_active)
);
COMMENT ON TABLE tenancy.service_schedules IS 'Horario de servicio por sede y día. La base de datos impide horarios que se solapen (HU-03-02).';

-- ----------------------------------------------------------------- triggers
CREATE TRIGGER tenants_touch BEFORE UPDATE ON tenancy.tenants
  FOR EACH ROW EXECUTE FUNCTION core.touch_updated_at();
CREATE TRIGGER tenants_status BEFORE UPDATE OF tenant_status_id ON tenancy.tenants
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('tenancy.tenant_status_transitions', 'tenant_status_id');
CREATE TRIGGER branches_touch BEFORE UPDATE ON tenancy.branches
  FOR EACH ROW EXECUTE FUNCTION core.touch_updated_at();
CREATE TRIGGER branches_status BEFORE UPDATE OF branch_status_id ON tenancy.branches
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('tenancy.branch_status_transitions', 'branch_status_id');
CREATE TRIGGER memberships_touch BEFORE UPDATE ON tenancy.memberships
  FOR EACH ROW EXECUTE FUNCTION core.touch_updated_at();
CREATE TRIGGER memberships_status BEFORE UPDATE OF membership_status_id ON tenancy.memberships
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('tenancy.membership_status_transitions', 'membership_status_id');
CREATE TRIGGER signing_keys_sync BEFORE INSERT OR UPDATE ON tenancy.tenant_signing_keys
  FOR EACH ROW EXECUTE FUNCTION core.bump_sync_version();
CREATE TRIGGER services_touch BEFORE UPDATE ON tenancy.services
  FOR EACH ROW EXECUTE FUNCTION core.touch_updated_at();
CREATE TRIGGER services_sync BEFORE INSERT OR UPDATE ON tenancy.services
  FOR EACH ROW EXECUTE FUNCTION core.bump_sync_version();
CREATE TRIGGER schedules_touch BEFORE UPDATE ON tenancy.service_schedules
  FOR EACH ROW EXECUTE FUNCTION core.touch_updated_at();
CREATE TRIGGER schedules_sync BEFORE INSERT OR UPDATE ON tenancy.service_schedules
  FOR EACH ROW EXECUTE FUNCTION core.bump_sync_version();
