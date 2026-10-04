-- VECI · Migración inicial (HU-01-03 y HU-01-04)
-- Generada a partir del DDL de referencia: docs/arquitectura/modelo-datos/sql (archivos 00 a 21).
-- prisma/verificar-migraciones.sh comprueba que las migraciones y el DDL de referencia producen la misma base.

-- >>> 00_extensiones_y_utilidades.sql
-- =============================================================================
-- VECI · Modelo de datos de referencia (HU-00-03)
-- 00 · Extensiones, dominios y funciones utilitarias compartidas
-- PostgreSQL 16+. Las migraciones reales (Prisma, HU-01-03) parten de estos archivos.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;    -- gen_random_bytes, digest
CREATE EXTENSION IF NOT EXISTS citext;      -- correos sin distinguir mayúsculas
CREATE EXTENSION IF NOT EXISTS btree_gist;  -- restricciones de exclusión (horarios)
CREATE EXTENSION IF NOT EXISTS pg_trgm;     -- búsqueda de clientes por nombre

CREATE SCHEMA core;

-- -----------------------------------------------------------------------------
-- Dominios: una regla de formato se escribe una sola vez
-- -----------------------------------------------------------------------------
CREATE DOMAIN core.catalog_code AS varchar(40)
  CHECK (VALUE ~ '^[A-Z][A-Z0-9_]*$');

CREATE DOMAIN core.money_amount AS numeric(14, 2)
  CHECK (VALUE >= 0);

-- Rango de horas del día para horarios de servicio (desayuno, almuerzo...)
CREATE TYPE core.time_range AS RANGE (subtype = time);

-- -----------------------------------------------------------------------------
-- UUID v7: ordenado por tiempo, generable en el celular (offline) o en el servidor.
-- PostgreSQL 18 trae uuidv7() nativo; esta función cubre PostgreSQL 16 y 17.
-- -----------------------------------------------------------------------------
CREATE FUNCTION core.uuid_v7() RETURNS uuid
LANGUAGE sql VOLATILE PARALLEL SAFE AS $$
  SELECT encode(
    set_bit(set_bit(
      overlay(uuid_send(gen_random_uuid())
              PLACING substring(int8send((extract(epoch FROM clock_timestamp()) * 1000)::bigint) FROM 3)
              FROM 1 FOR 6),
      52, 1), 53, 1),
    'hex')::uuid;
$$;

-- -----------------------------------------------------------------------------
-- updated_at automático
-- -----------------------------------------------------------------------------
CREATE FUNCTION core.touch_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END $$;

-- -----------------------------------------------------------------------------
-- Versión de sincronización: cada cambio en una tabla que baja al celular
-- recibe un número creciente global. El dispositivo pide "cambios desde N".
-- -----------------------------------------------------------------------------
CREATE SEQUENCE core.sync_version_seq AS bigint;

CREATE FUNCTION core.bump_sync_version() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.sync_version := nextval('core.sync_version_seq');
  RETURN NEW;
END $$;

-- -----------------------------------------------------------------------------
-- Inmutabilidad: libro de movimientos, eventos y auditoría no se editan ni borran
-- -----------------------------------------------------------------------------
CREATE FUNCTION core.forbid_mutation() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'La tabla %.% es inmutable: registre un evento de corrección',
    TG_TABLE_SCHEMA, TG_TABLE_NAME
    USING ERRCODE = 'restrict_violation';
END $$;

-- -----------------------------------------------------------------------------
-- Máquina de estados en datos: valida que el cambio de estado exista en la
-- tabla de transiciones permitidas del catálogo.
--   TG_ARGV[0] = tabla de transiciones (esquema.tabla)
--   TG_ARGV[1] = columna de estado en la tabla vigilada
-- -----------------------------------------------------------------------------
CREATE FUNCTION core.enforce_status_transition() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_old smallint;
  v_new smallint;
  v_ok  boolean;
BEGIN
  EXECUTE format('SELECT ($1).%1$I, ($2).%1$I', TG_ARGV[1])
    INTO v_old, v_new USING OLD, NEW;

  IF v_old IS NOT DISTINCT FROM v_new THEN
    RETURN NEW;
  END IF;

  EXECUTE format(
    'SELECT EXISTS (SELECT 1 FROM %s WHERE from_status_id = $1 AND to_status_id = $2)',
    TG_ARGV[0])
    INTO v_ok USING v_old, v_new;

  IF NOT v_ok THEN
    RAISE EXCEPTION 'Transición de estado no permitida en %.%: % -> %',
      TG_TABLE_SCHEMA, TG_TABLE_NAME, v_old, v_new
      USING ERRCODE = 'check_violation';
  END IF;

  NEW.status_changed_at := now();
  RETURN NEW;
END $$;

-- -----------------------------------------------------------------------------
-- Contexto de la petición (lo fija el guard de NestJS con SET LOCAL)
-- -----------------------------------------------------------------------------
CREATE FUNCTION core.current_tenant_id() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.tenant_id', true), '')::uuid;
$$;

CREATE FUNCTION core.current_person_id() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.person_id', true), '')::uuid;
$$;

-- >>> 01_core.sql
-- =============================================================================
-- 01 · core: catálogos compartidos por todos los módulos
-- Catálogo = tabla con id smallint estable (sembrado por migración) y code único.
-- El código de la aplicación se refiere a los registros por su code, nunca por id.
-- =============================================================================

CREATE TABLE core.modules (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  description text,
  is_active   boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE core.modules IS 'Módulos funcionales del backend (auth, tiqueteras...). Agrupa permisos y acciones de auditoría.';

CREATE TABLE core.currencies (
  code        char(3) PRIMARY KEY CHECK (code ~ '^[A-Z]{3}$'),
  name        varchar(60) NOT NULL,
  minor_units smallint NOT NULL CHECK (minor_units BETWEEN 0 AND 4)
);
COMMENT ON TABLE core.currencies IS 'Monedas ISO 4217. COP en el MVP.';

CREATE TABLE core.countries (
  id           smallint PRIMARY KEY,
  iso2         char(2) NOT NULL UNIQUE,
  name         varchar(80) NOT NULL,
  phone_prefix varchar(5) NOT NULL
);

CREATE TABLE core.departments (
  id            smallint PRIMARY KEY,
  country_id    smallint NOT NULL REFERENCES core.countries (id),
  official_code varchar(10) NOT NULL,
  name          varchar(80) NOT NULL,
  UNIQUE (country_id, official_code)
);
COMMENT ON TABLE core.departments IS 'Departamentos (código DIVIPOLA en Colombia).';

CREATE TABLE core.municipalities (
  id            integer PRIMARY KEY,
  department_id smallint NOT NULL REFERENCES core.departments (id),
  official_code varchar(10) NOT NULL UNIQUE,
  name          varchar(80) NOT NULL
);
COMMENT ON TABLE core.municipalities IS 'Municipios (DIVIPOLA). Base de la expansión a Puerto Asís, Sibundoy, etc.';

CREATE TABLE core.holidays (
  country_id   smallint NOT NULL REFERENCES core.countries (id),
  holiday_date date NOT NULL,
  name         varchar(80) NOT NULL,
  PRIMARY KEY (country_id, holiday_date)
);
COMMENT ON TABLE core.holidays IS 'Festivos por país. Sirve para calcular plazos en días hábiles (Ley 1581).';

CREATE TABLE core.document_types (
  id                 smallint PRIMARY KEY,
  code               core.catalog_code NOT NULL UNIQUE,
  name               varchar(80) NOT NULL,
  country_id         smallint NOT NULL REFERENCES core.countries (id),
  for_natural_person boolean NOT NULL,
  for_legal_entity   boolean NOT NULL,
  validation_regex   varchar(120),
  sort_order         smallint NOT NULL DEFAULT 0,
  is_active          boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE core.document_types IS 'Tipos de documento: CC, TI, CE, PPT, pasaporte, NIT.';

CREATE TABLE core.contact_types (
  id               smallint PRIMARY KEY,
  code             core.catalog_code NOT NULL UNIQUE,
  name             varchar(80) NOT NULL,
  can_login        boolean NOT NULL,
  validation_regex varchar(120),
  is_active        boolean NOT NULL DEFAULT true,
  UNIQUE (id, can_login)
);
COMMENT ON TABLE core.contact_types IS 'Celular, correo, WhatsApp, fijo. can_login marca los que sirven para iniciar sesión.';

CREATE TABLE core.weekdays (
  id   smallint PRIMARY KEY CHECK (id BETWEEN 1 AND 7),
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(20) NOT NULL
);
COMMENT ON TABLE core.weekdays IS 'Días de la semana ISO 8601 (1 = lunes).';

CREATE TABLE core.data_types (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(40) NOT NULL
);
COMMENT ON TABLE core.data_types IS 'Tipos de dato de las configuraciones (entero, booleano, hora, texto, decimal).';

CREATE TABLE core.payment_methods (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  needs_channel boolean NOT NULL,
  sort_order  smallint NOT NULL DEFAULT 0,
  is_active   boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE core.payment_methods IS 'Medio de pago: efectivo, transferencia, pasarela (futuro).';

CREATE TABLE core.payment_channels (
  id                smallint PRIMARY KEY,
  payment_method_id smallint NOT NULL REFERENCES core.payment_methods (id),
  code              core.catalog_code NOT NULL UNIQUE,
  name              varchar(80) NOT NULL,
  sort_order        smallint NOT NULL DEFAULT 0,
  is_active         boolean NOT NULL DEFAULT true,
  UNIQUE (id, payment_method_id)
);
COMMENT ON TABLE core.payment_channels IS 'Canal dentro de un medio: Nequi, Daviplata, Bancolombia (transferencia); Wompi (pasarela).';

CREATE TABLE core.qr_revocation_reasons (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  is_active   boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE core.qr_revocation_reasons IS 'Motivos para revocar un QR (perdido, regenerado, compartido, afiliación terminada).';

-- >>> 02_identity.sql
-- =============================================================================
-- 02 · identity: personas, usuarios, credenciales, roles, permisos y sesiones
-- Persona (quién es) ≠ Usuario (cuenta para entrar) ≠ Rol (qué puede hacer).
-- =============================================================================

CREATE SCHEMA identity;

-- ----------------------------------------------------------------- catálogos
CREATE TABLE identity.person_statuses (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  description text,
  is_initial  boolean NOT NULL DEFAULT false,
  is_terminal boolean NOT NULL DEFAULT false,
  sort_order  smallint NOT NULL DEFAULT 0
);

CREATE TABLE identity.person_status_transitions (
  from_status_id smallint NOT NULL REFERENCES identity.person_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES identity.person_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE identity.user_statuses (
  id           smallint PRIMARY KEY,
  code         core.catalog_code NOT NULL UNIQUE,
  name         varchar(80) NOT NULL,
  description  text,
  allows_login boolean NOT NULL,
  is_initial   boolean NOT NULL DEFAULT false,
  is_terminal  boolean NOT NULL DEFAULT false,
  sort_order   smallint NOT NULL DEFAULT 0
);

CREATE TABLE identity.user_status_transitions (
  from_status_id smallint NOT NULL REFERENCES identity.user_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES identity.user_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE identity.credential_types (
  id             smallint PRIMARY KEY,
  code           core.catalog_code NOT NULL UNIQUE,
  name           varchar(80) NOT NULL,
  max_failed_attempts smallint NOT NULL CHECK (max_failed_attempts > 0),
  lock_minutes   smallint NOT NULL CHECK (lock_minutes > 0),
  is_active      boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE identity.credential_types IS 'PIN de 6 dígitos, contraseña; a futuro OTP. Las reglas de bloqueo viven aquí, no en código.';

CREATE TABLE identity.credential_revocation_reasons (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(80) NOT NULL
);

CREATE TABLE identity.login_failure_reasons (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(80) NOT NULL
);

CREATE TABLE identity.session_revocation_reasons (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(80) NOT NULL
);

CREATE TABLE identity.device_platforms (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(40) NOT NULL
);

-- ----------------------------------------------------------------- personas
CREATE TABLE identity.people (
  id                uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  document_type_id  smallint NOT NULL REFERENCES core.document_types (id),
  document_number   varchar(20) NOT NULL,
  given_names       varchar(80) NOT NULL,
  family_names      varchar(80),
  person_status_id  smallint NOT NULL REFERENCES identity.person_statuses (id),
  status_changed_at timestamptz NOT NULL DEFAULT now(),
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  sync_version      bigint NOT NULL DEFAULT 0,
  CONSTRAINT people_document_uk UNIQUE (document_type_id, document_number)
);
COMMENT ON TABLE identity.people IS 'Persona natural única en VECI (RF-CLI-06). Un cliente en 3 comercios es 1 persona.';

CREATE INDEX people_full_name_trgm_ix ON identity.people
  USING gin ((given_names || ' ' || coalesce(family_names, '')) gin_trgm_ops);

CREATE TABLE identity.person_contacts (
  id              uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  person_id       uuid NOT NULL REFERENCES identity.people (id),
  contact_type_id smallint NOT NULL REFERENCES core.contact_types (id),
  value           varchar(120) NOT NULL,
  is_primary      boolean NOT NULL DEFAULT false,
  verified_at     timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (person_id, contact_type_id, value)
);
CREATE UNIQUE INDEX person_contacts_one_primary_ux
  ON identity.person_contacts (person_id, contact_type_id) WHERE is_primary;
CREATE INDEX person_contacts_value_ix ON identity.person_contacts (contact_type_id, value);

-- ----------------------------------------------------------------- usuarios
CREATE TABLE identity.users (
  id                uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  person_id         uuid NOT NULL UNIQUE REFERENCES identity.people (id),
  user_status_id    smallint NOT NULL REFERENCES identity.user_statuses (id),
  status_changed_at timestamptz NOT NULL DEFAULT now(),
  activated_at      timestamptz,
  last_login_at     timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE identity.users IS 'Cuenta para iniciar sesión. Una persona tiene como máximo un usuario; un cliente registrado por el cajero puede no tenerlo aún.';

CREATE TABLE identity.user_login_identifiers (
  id              uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  user_id         uuid NOT NULL REFERENCES identity.users (id),
  contact_type_id smallint NOT NULL,
  can_login       boolean NOT NULL DEFAULT true CHECK (can_login),
  value           varchar(120) NOT NULL,
  verified_at     timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  revoked_at      timestamptz,
  FOREIGN KEY (contact_type_id, can_login) REFERENCES core.contact_types (id, can_login)
);
COMMENT ON TABLE identity.user_login_identifiers IS 'Celular (E.164) o correo con el que se entra. Único en toda la plataforma mientras esté vigente.';
CREATE UNIQUE INDEX user_login_identifiers_value_ux
  ON identity.user_login_identifiers (contact_type_id, value) WHERE revoked_at IS NULL;

CREATE TABLE identity.user_credentials (
  id                    uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  user_id               uuid NOT NULL REFERENCES identity.users (id),
  credential_type_id    smallint NOT NULL REFERENCES identity.credential_types (id),
  secret_hash           text NOT NULL,
  must_change           boolean NOT NULL DEFAULT false,
  failed_attempts       smallint NOT NULL DEFAULT 0 CHECK (failed_attempts >= 0),
  locked_until          timestamptz,
  created_by_user_id    uuid REFERENCES identity.users (id),
  created_at            timestamptz NOT NULL DEFAULT now(),
  revoked_at            timestamptz,
  revocation_reason_id  smallint REFERENCES identity.credential_revocation_reasons (id),
  CHECK ((revoked_at IS NULL) = (revocation_reason_id IS NULL))
);
COMMENT ON TABLE identity.user_credentials IS 'PIN o contraseña con hash Argon2id. Restablecer = revocar la fila vigente y crear otra (historial completo).';
CREATE UNIQUE INDEX user_credentials_current_ux
  ON identity.user_credentials (user_id, credential_type_id) WHERE revoked_at IS NULL;

-- --------------------------------------------------- roles y permisos (RBAC)
CREATE TABLE identity.roles (
  id                       smallint PRIMARY KEY,
  code                     core.catalog_code NOT NULL UNIQUE,
  name                     varchar(80) NOT NULL,
  description              text,
  assignable_to_platform   boolean NOT NULL,
  assignable_to_membership boolean NOT NULL,
  is_active                boolean NOT NULL DEFAULT true,
  UNIQUE (id, assignable_to_platform),
  UNIQUE (id, assignable_to_membership)
);
COMMENT ON TABLE identity.roles IS 'Administrador VECI, Propietario, Cajero, Cliente. El rol Cliente se obtiene por la afiliación, no por membresía.';

CREATE TABLE identity.permissions (
  id          smallint PRIMARY KEY,
  module_id   smallint NOT NULL REFERENCES core.modules (id),
  code        varchar(80) NOT NULL UNIQUE CHECK (code ~ '^[a-z]+(\.[a-z_]+)+$'),
  name        varchar(120) NOT NULL,
  description text
);
COMMENT ON TABLE identity.permissions IS 'Acción atómica que un endpoint exige, p. ej. consumptions.register.';

CREATE TABLE identity.role_permissions (
  role_id       smallint NOT NULL REFERENCES identity.roles (id),
  permission_id smallint NOT NULL REFERENCES identity.permissions (id),
  PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE identity.user_platform_roles (
  id                     uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  user_id                uuid NOT NULL REFERENCES identity.users (id),
  role_id                smallint NOT NULL,
  assignable_to_platform boolean NOT NULL DEFAULT true CHECK (assignable_to_platform),
  granted_by_user_id     uuid REFERENCES identity.users (id),
  granted_at             timestamptz NOT NULL DEFAULT now(),
  revoked_at             timestamptz,
  FOREIGN KEY (role_id, assignable_to_platform) REFERENCES identity.roles (id, assignable_to_platform)
);
COMMENT ON TABLE identity.user_platform_roles IS 'Roles internos de VECI (Administrador, Soporte). Intermedia usuario-rol con vigencia.';
CREATE UNIQUE INDEX user_platform_roles_current_ux
  ON identity.user_platform_roles (user_id, role_id) WHERE revoked_at IS NULL;

-- ------------------------------------------------------ dispositivos y sesiones
CREATE TABLE identity.devices (
  id                 uuid PRIMARY KEY,
  device_platform_id smallint NOT NULL REFERENCES identity.device_platforms (id),
  model              varchar(80),
  os_version         varchar(40),
  app_version        varchar(40),
  first_seen_at      timestamptz NOT NULL DEFAULT now(),
  last_seen_at       timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE identity.devices IS 'Celular o navegador. El id lo genera el propio dispositivo (UUID v7) y viaja en cada evento offline.';

CREATE TABLE identity.sessions (
  id                   uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  user_id              uuid NOT NULL REFERENCES identity.users (id),
  device_id            uuid NOT NULL REFERENCES identity.devices (id),
  refresh_token_hash   bytea NOT NULL UNIQUE,
  created_at           timestamptz NOT NULL DEFAULT now(),
  last_refreshed_at    timestamptz NOT NULL DEFAULT now(),
  expires_at           timestamptz NOT NULL,
  revoked_at           timestamptz,
  revoked_by_user_id   uuid REFERENCES identity.users (id),
  revocation_reason_id smallint REFERENCES identity.session_revocation_reasons (id),
  CHECK (expires_at > created_at),
  CHECK ((revoked_at IS NULL) = (revocation_reason_id IS NULL))
);
COMMENT ON TABLE identity.sessions IS 'Sesión por dispositivo con token de renovación (hash). Permite el cierre remoto (RF-AUT-06).';
CREATE INDEX sessions_user_ix ON identity.sessions (user_id) WHERE revoked_at IS NULL;
CREATE INDEX sessions_device_ix ON identity.sessions (device_id) WHERE revoked_at IS NULL;

-- Intentos de inicio de sesión: alto volumen, solo inserción, particionado por mes
CREATE TABLE identity.login_attempts (
  id                      uuid NOT NULL DEFAULT core.uuid_v7(),
  attempted_at            timestamptz NOT NULL DEFAULT now(),
  identifier_hash         bytea NOT NULL,
  user_id                 uuid,
  device_id               uuid,
  ip_address              inet,
  succeeded               boolean NOT NULL,
  login_failure_reason_id smallint REFERENCES identity.login_failure_reasons (id),
  PRIMARY KEY (id, attempted_at),
  CHECK (succeeded = (login_failure_reason_id IS NULL))
) PARTITION BY RANGE (attempted_at);
CREATE TABLE identity.login_attempts_default PARTITION OF identity.login_attempts DEFAULT;
CREATE INDEX login_attempts_user_ix ON identity.login_attempts (user_id, attempted_at);

-- ----------------------------------------------------------------- triggers
CREATE TRIGGER people_touch BEFORE UPDATE ON identity.people
  FOR EACH ROW EXECUTE FUNCTION core.touch_updated_at();
CREATE TRIGGER people_sync BEFORE INSERT OR UPDATE ON identity.people
  FOR EACH ROW EXECUTE FUNCTION core.bump_sync_version();
CREATE TRIGGER people_status BEFORE UPDATE OF person_status_id ON identity.people
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('identity.person_status_transitions', 'person_status_id');
CREATE TRIGGER person_contacts_touch BEFORE UPDATE ON identity.person_contacts
  FOR EACH ROW EXECUTE FUNCTION core.touch_updated_at();
CREATE TRIGGER users_touch BEFORE UPDATE ON identity.users
  FOR EACH ROW EXECUTE FUNCTION core.touch_updated_at();
CREATE TRIGGER users_status BEFORE UPDATE OF user_status_id ON identity.users
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('identity.user_status_transitions', 'user_status_id');

-- >>> 03_tenancy.sql
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

-- >>> 04_customers.sql
-- =============================================================================
-- 04 · customers: afiliación cliente-comercio, QR y enlaces de saldo
-- La persona es global (identity.people); lo que un comercio sabe de ella vive aquí.
-- =============================================================================

CREATE SCHEMA customers;

-- ----------------------------------------------------------------- catálogos
CREATE TABLE customers.affiliation_statuses (
  id                smallint PRIMARY KEY,
  code              core.catalog_code NOT NULL UNIQUE,
  name              varchar(80) NOT NULL,
  description       text,
  allows_operations boolean NOT NULL,
  is_initial        boolean NOT NULL DEFAULT false,
  is_terminal       boolean NOT NULL DEFAULT false,
  sort_order        smallint NOT NULL DEFAULT 0
);
COMMENT ON TABLE customers.affiliation_statuses IS 'Activa, bloqueada por el comercio, retirada.';

CREATE TABLE customers.affiliation_status_transitions (
  from_status_id smallint NOT NULL REFERENCES customers.affiliation_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES customers.affiliation_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE customers.affiliation_channels (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(80) NOT NULL
);
COMMENT ON TABLE customers.affiliation_channels IS 'Cómo llegó el cliente: escaneo del QR personal, registro asistido, importación.';

-- ----------------------------------------------------------------- QR personal
CREATE TABLE customers.personal_qr_codes (
  id                   uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  person_id            uuid NOT NULL REFERENCES identity.people (id),
  version              integer NOT NULL CHECK (version > 0),
  issued_at            timestamptz NOT NULL DEFAULT now(),
  revoked_at           timestamptz,
  revocation_reason_id smallint REFERENCES core.qr_revocation_reasons (id),
  UNIQUE (person_id, version),
  CHECK ((revoked_at IS NULL) = (revocation_reason_id IS NULL))
);
COMMENT ON TABLE customers.personal_qr_codes IS 'QR personal del cliente (RF-CLI-02), solo para afiliarse. Lleva un token firmado por VECI con person_id y versión.';
CREATE UNIQUE INDEX personal_qr_codes_current_ux
  ON customers.personal_qr_codes (person_id) WHERE revoked_at IS NULL;

-- ----------------------------------------------------------------- afiliaciones
CREATE TABLE customers.affiliations (
  id                     uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id              uuid NOT NULL REFERENCES tenancy.tenants (id),
  person_id              uuid NOT NULL REFERENCES identity.people (id),
  affiliation_status_id  smallint NOT NULL REFERENCES customers.affiliation_statuses (id),
  status_changed_at      timestamptz NOT NULL DEFAULT now(),
  affiliation_channel_id smallint NOT NULL REFERENCES customers.affiliation_channels (id),
  branch_id              uuid,
  affiliated_by_membership_id uuid,
  affiliated_at          timestamptz NOT NULL DEFAULT now(),
  created_at             timestamptz NOT NULL DEFAULT now(),
  updated_at             timestamptz NOT NULL DEFAULT now(),
  sync_version           bigint NOT NULL DEFAULT 0,
  UNIQUE (tenant_id, person_id),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, branch_id) REFERENCES tenancy.branches (tenant_id, id),
  FOREIGN KEY (tenant_id, affiliated_by_membership_id) REFERENCES tenancy.memberships (tenant_id, id)
);
COMMENT ON TABLE customers.affiliations IS 'Intermedia persona-comercio: el cliente "en" un negocio. Una persona en 3 comercios = 3 afiliaciones, 1 persona.';
CREATE INDEX affiliations_person_ix ON customers.affiliations (person_id);

-- ----------------------------------------------------- QR del cliente en el comercio
CREATE TABLE customers.affiliation_qr_codes (
  id                   uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id            uuid NOT NULL,
  affiliation_id       uuid NOT NULL,
  version              integer NOT NULL CHECK (version > 0),
  signing_key_id       uuid NOT NULL,
  issued_at            timestamptz NOT NULL DEFAULT now(),
  revoked_at           timestamptz,
  revoked_by_user_id   uuid REFERENCES identity.users (id),
  revocation_reason_id smallint REFERENCES core.qr_revocation_reasons (id),
  sync_version         bigint NOT NULL DEFAULT 0,
  UNIQUE (affiliation_id, version),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, affiliation_id) REFERENCES customers.affiliations (tenant_id, id),
  FOREIGN KEY (tenant_id, signing_key_id) REFERENCES tenancy.tenant_signing_keys (tenant_id, id),
  CHECK ((revoked_at IS NULL) = (revocation_reason_id IS NULL))
);
COMMENT ON TABLE customers.affiliation_qr_codes IS 'QR único del cliente en un comercio (RF-CLI-03). Token = firma(afiliación + comercio + versión). No guarda saldo.';
CREATE UNIQUE INDEX affiliation_qr_codes_current_ux
  ON customers.affiliation_qr_codes (affiliation_id) WHERE revoked_at IS NULL;

-- ----------------------------------------------------------------- enlace de saldo
CREATE TABLE customers.balance_links (
  id                 uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id          uuid NOT NULL,
  affiliation_id     uuid NOT NULL,
  token_hash         bytea NOT NULL UNIQUE,
  created_by_user_id uuid REFERENCES identity.users (id),
  created_at         timestamptz NOT NULL DEFAULT now(),
  last_accessed_at   timestamptz,
  revoked_at         timestamptz,
  FOREIGN KEY (tenant_id, affiliation_id) REFERENCES customers.affiliations (tenant_id, id)
);
COMMENT ON TABLE customers.balance_links IS 'Enlace web para ver saldo sin app (RF-APC-03). Solo se guarda el hash del token.';
CREATE UNIQUE INDEX balance_links_current_ux
  ON customers.balance_links (affiliation_id) WHERE revoked_at IS NULL;

-- ----------------------------------------------------------------- triggers
CREATE TRIGGER affiliations_touch BEFORE UPDATE ON customers.affiliations
  FOR EACH ROW EXECUTE FUNCTION core.touch_updated_at();
CREATE TRIGGER affiliations_sync BEFORE INSERT OR UPDATE ON customers.affiliations
  FOR EACH ROW EXECUTE FUNCTION core.bump_sync_version();
CREATE TRIGGER affiliations_status BEFORE UPDATE OF affiliation_status_id ON customers.affiliations
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('customers.affiliation_status_transitions', 'affiliation_status_id');
CREATE TRIGGER affiliation_qr_sync BEFORE INSERT OR UPDATE ON customers.affiliation_qr_codes
  FOR EACH ROW EXECUTE FUNCTION core.bump_sync_version();

-- >>> 05_prepaid_oferta.sql
-- =============================================================================
-- 05 · prepaid (oferta): unidades de consumo y tipos de tiquetera
-- "Tiquetera" en el dominio = paquete prepagado genérico (almuerzos, cafés, panes).
-- =============================================================================

CREATE SCHEMA prepaid;

CREATE TABLE prepaid.consumption_units (
  id            uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id     uuid REFERENCES tenancy.tenants (id),
  code          core.catalog_code NOT NULL,
  singular_name varchar(40) NOT NULL,
  plural_name   varchar(40) NOT NULL,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  sync_version  bigint NOT NULL DEFAULT 0,
  CONSTRAINT consumption_units_code_uk UNIQUE NULLS NOT DISTINCT (tenant_id, code)
);
COMMENT ON TABLE prepaid.consumption_units IS 'Unidad que se descuenta: almuerzo, café, pan, lavada. tenant_id NULL = unidad global de VECI; con valor = propia del comercio.';

CREATE TABLE prepaid.package_type_statuses (
  id           smallint PRIMARY KEY,
  code         core.catalog_code NOT NULL UNIQUE,
  name         varchar(80) NOT NULL,
  allows_sale  boolean NOT NULL,
  is_initial   boolean NOT NULL DEFAULT false,
  is_terminal  boolean NOT NULL DEFAULT false,
  sort_order   smallint NOT NULL DEFAULT 0
);

CREATE TABLE prepaid.package_type_status_transitions (
  from_status_id smallint NOT NULL REFERENCES prepaid.package_type_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES prepaid.package_type_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE prepaid.package_types (
  id                     uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id              uuid NOT NULL REFERENCES tenancy.tenants (id),
  name                   varchar(80) NOT NULL,
  consumption_unit_id    uuid NOT NULL REFERENCES prepaid.consumption_units (id),
  units_quantity         integer NOT NULL CHECK (units_quantity > 0),
  price_amount           core.money_amount NOT NULL,
  validity_days          integer NOT NULL CHECK (validity_days > 0),
  package_type_status_id smallint NOT NULL REFERENCES prepaid.package_type_statuses (id),
  status_changed_at      timestamptz NOT NULL DEFAULT now(),
  created_by_user_id     uuid REFERENCES identity.users (id),
  created_at             timestamptz NOT NULL DEFAULT now(),
  updated_at             timestamptz NOT NULL DEFAULT now(),
  sync_version           bigint NOT NULL DEFAULT 0,
  UNIQUE (tenant_id, name),
  UNIQUE (tenant_id, id)
);
COMMENT ON TABLE prepaid.package_types IS 'Tipo de tiquetera que vende el comercio (RF-TIQ-01). Cambiar su precio no altera lo ya vendido: la venta guarda el precio pagado.';

CREATE TRIGGER package_types_touch BEFORE UPDATE ON prepaid.package_types
  FOR EACH ROW EXECUTE FUNCTION core.touch_updated_at();
CREATE TRIGGER package_types_sync BEFORE INSERT OR UPDATE ON prepaid.package_types
  FOR EACH ROW EXECUTE FUNCTION core.bump_sync_version();
CREATE TRIGGER package_types_status BEFORE UPDATE OF package_type_status_id ON prepaid.package_types
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('prepaid.package_type_status_transitions', 'package_type_status_id');
CREATE TRIGGER consumption_units_sync BEFORE INSERT OR UPDATE ON prepaid.consumption_units
  FOR EACH ROW EXECUTE FUNCTION core.bump_sync_version();

-- >>> 06_ledger_eventos.sql
-- =============================================================================
-- 06 · ledger (eventos): cabecera común e inmutable de todo hecho de negocio
-- Venta, consumo, reverso, ajuste, anulación y vencimiento son eventos.
-- Cada subtipo (sales.sales, consumptions.consumptions) comparte la PK del evento.
-- =============================================================================

CREATE SCHEMA ledger;

CREATE TABLE ledger.event_types (
  id                smallint PRIMARY KEY,
  code              core.catalog_code NOT NULL UNIQUE,
  name              varchar(80) NOT NULL,
  description       text,
  balance_effect    smallint NOT NULL CHECK (balance_effect IN (-1, 0, 1)),
  requires_actor    boolean NOT NULL,
  requires_reason   boolean NOT NULL,
  is_reversal       boolean NOT NULL,
  is_reversible     boolean NOT NULL,
  notifies_customer boolean NOT NULL
);
COMMENT ON TABLE ledger.event_types IS 'Tipos de evento y sus reglas (signo, si exige motivo, si se puede reversar...). balance_effect 0 = depende del evento (ajuste).';

CREATE TABLE ledger.event_origins (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(80) NOT NULL
);
COMMENT ON TABLE ledger.event_origins IS 'En línea, sincronizado desde offline, proceso automático, consola VECI.';

CREATE TABLE ledger.event_reasons (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  is_active   boolean NOT NULL DEFAULT true,
  sort_order  smallint NOT NULL DEFAULT 0
);
COMMENT ON TABLE ledger.event_reasons IS 'Motivos estándar para reversos, ajustes, anulaciones y autorizaciones (error de digitación, reclamo, cortesía...).';

CREATE TABLE ledger.events (
  id                  uuid PRIMARY KEY,
  tenant_id           uuid NOT NULL REFERENCES tenancy.tenants (id),
  event_type_id       smallint NOT NULL REFERENCES ledger.event_types (id),
  event_origin_id     smallint NOT NULL REFERENCES ledger.event_origins (id),
  affiliation_id      uuid NOT NULL,
  branch_id           uuid,
  actor_membership_id uuid,
  device_id           uuid REFERENCES identity.devices (id),
  occurred_at         timestamptz NOT NULL,
  recorded_at         timestamptz NOT NULL DEFAULT now(),
  reverses_event_id   uuid,
  event_reason_id     smallint REFERENCES ledger.event_reasons (id),
  reason_note         varchar(500),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, affiliation_id) REFERENCES customers.affiliations (tenant_id, id),
  FOREIGN KEY (tenant_id, branch_id) REFERENCES tenancy.branches (tenant_id, id),
  FOREIGN KEY (tenant_id, actor_membership_id) REFERENCES tenancy.memberships (tenant_id, id),
  FOREIGN KEY (tenant_id, reverses_event_id) REFERENCES ledger.events (tenant_id, id),
  CHECK (reverses_event_id IS NULL OR reverses_event_id <> id)
);
COMMENT ON TABLE ledger.events IS 'Hecho de negocio inmutable. El id (UUID v7) lo genera el dispositivo y es la llave de idempotencia. occurred_at = hora real; recorded_at = hora de llegada al servidor.';
COMMENT ON COLUMN ledger.events.reverses_event_id IS 'Evento que este reversa o anula. Un evento solo se puede reversar una vez.';

CREATE UNIQUE INDEX events_reversed_once_ux ON ledger.events (reverses_event_id)
  WHERE reverses_event_id IS NOT NULL;
CREATE INDEX events_affiliation_ix ON ledger.events (tenant_id, affiliation_id, occurred_at DESC);
CREATE INDEX events_branch_day_ix ON ledger.events (tenant_id, branch_id, occurred_at);
CREATE INDEX events_actor_ix ON ledger.events (tenant_id, actor_membership_id, occurred_at);

CREATE TRIGGER events_immutable BEFORE UPDATE OR DELETE ON ledger.events
  FOR EACH ROW EXECUTE FUNCTION core.forbid_mutation();

-- >>> 07_sales.sql
-- =============================================================================
-- 07 · sales: venta de tiqueteras, sus líneas, sus pagos y el cierre de caja
-- sales.sales es subtipo de ledger.events (misma PK).
-- =============================================================================

CREATE SCHEMA sales;

CREATE TABLE sales.sale_statuses (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  counts_as_revenue boolean NOT NULL,
  is_initial  boolean NOT NULL DEFAULT false,
  is_terminal boolean NOT NULL DEFAULT false
);
COMMENT ON TABLE sales.sale_statuses IS 'Completada, anulada. counts_as_revenue decide si suma en reportes de ingresos.';

CREATE TABLE sales.sale_status_transitions (
  from_status_id smallint NOT NULL REFERENCES sales.sale_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES sales.sale_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE sales.sales (
  event_id          uuid PRIMARY KEY,
  tenant_id         uuid NOT NULL,
  sale_status_id    smallint NOT NULL REFERENCES sales.sale_statuses (id),
  status_changed_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, event_id),
  FOREIGN KEY (tenant_id, event_id) REFERENCES ledger.events (tenant_id, id)
);
COMMENT ON TABLE sales.sales IS 'Venta (RF-TIQ-02). Cliente, cajero, sede, dispositivo y hora están en ledger.events.';

CREATE TABLE sales.sale_items (
  id              uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id       uuid NOT NULL,
  sale_id         uuid NOT NULL,
  line_number     smallint NOT NULL CHECK (line_number > 0),
  package_type_id uuid NOT NULL,
  quantity        smallint NOT NULL CHECK (quantity > 0),
  unit_price      core.money_amount NOT NULL,
  line_total      numeric(14, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  UNIQUE (sale_id, line_number),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, sale_id) REFERENCES sales.sales (tenant_id, event_id),
  FOREIGN KEY (tenant_id, package_type_id) REFERENCES prepaid.package_types (tenant_id, id)
);
COMMENT ON TABLE sales.sale_items IS 'Línea de la venta con el precio realmente cobrado. Preparada para vender productos sueltos en fases futuras.';

CREATE TABLE sales.sale_payments (
  id                 uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id          uuid NOT NULL,
  sale_id            uuid NOT NULL,
  payment_method_id  smallint NOT NULL REFERENCES core.payment_methods (id),
  payment_channel_id smallint,
  amount             core.money_amount NOT NULL CHECK (amount > 0),
  reference          varchar(60),
  FOREIGN KEY (tenant_id, sale_id) REFERENCES sales.sales (tenant_id, event_id),
  FOREIGN KEY (payment_channel_id, payment_method_id)
    REFERENCES core.payment_channels (id, payment_method_id)
);
COMMENT ON TABLE sales.sale_payments IS 'Pagos de la venta: efectivo o transferencia (Nequi, Daviplata, Bancolombia) con referencia opcional. Admite pago mixto.';
CREATE INDEX sale_payments_sale_ix ON sales.sale_payments (tenant_id, sale_id);

CREATE TABLE sales.cash_closings (
  id                uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id         uuid NOT NULL,
  branch_id         uuid NOT NULL,
  membership_id     uuid NOT NULL,
  business_date     date NOT NULL,
  expected_cash     core.money_amount NOT NULL,
  counted_cash      core.money_amount NOT NULL,
  difference        numeric(14, 2) GENERATED ALWAYS AS (counted_cash - expected_cash) STORED,
  note              varchar(500),
  closed_at         timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, branch_id, membership_id, business_date),
  FOREIGN KEY (tenant_id, branch_id) REFERENCES tenancy.branches (tenant_id, id),
  FOREIGN KEY (tenant_id, membership_id) REFERENCES tenancy.memberships (tenant_id, id)
);
COMMENT ON TABLE sales.cash_closings IS 'Cierre de caja diario por cajero y sede (RF-REP-06). expected_cash es la foto calculada al cerrar.';

CREATE TRIGGER sales_status BEFORE UPDATE OF sale_status_id ON sales.sales
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('sales.sale_status_transitions', 'sale_status_id');
CREATE TRIGGER sale_items_immutable BEFORE UPDATE OR DELETE ON sales.sale_items
  FOR EACH ROW EXECUTE FUNCTION core.forbid_mutation();
CREATE TRIGGER sale_payments_immutable BEFORE UPDATE OR DELETE ON sales.sale_payments
  FOR EACH ROW EXECUTE FUNCTION core.forbid_mutation();
CREATE TRIGGER cash_closings_immutable BEFORE UPDATE OR DELETE ON sales.cash_closings
  FOR EACH ROW EXECUTE FUNCTION core.forbid_mutation();

-- >>> 08_prepaid_tiqueteras.sql
-- =============================================================================
-- 08 · prepaid (tiqueteras vendidas)
-- El saldo verdadero es la suma de ledger.movements; units_balance es su caché
-- transaccional, mantenida por trigger en la misma transacción (archivo 09).
-- =============================================================================

CREATE TABLE prepaid.package_statuses (
  id                 smallint PRIMARY KEY,
  code               core.catalog_code NOT NULL UNIQUE,
  name               varchar(80) NOT NULL,
  description        text,
  allows_consumption boolean NOT NULL,
  counts_as_liability boolean NOT NULL,
  is_initial         boolean NOT NULL DEFAULT false,
  is_terminal        boolean NOT NULL DEFAULT false,
  sort_order         smallint NOT NULL DEFAULT 0
);
COMMENT ON TABLE prepaid.package_statuses IS 'Activa, agotada, vencida, anulada. allows_consumption y counts_as_liability gobiernan escaneo y reportes.';

CREATE TABLE prepaid.package_status_transitions (
  from_status_id smallint NOT NULL REFERENCES prepaid.package_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES prepaid.package_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE prepaid.packages (
  id                uuid PRIMARY KEY,
  tenant_id         uuid NOT NULL,
  affiliation_id    uuid NOT NULL,
  package_type_id   uuid NOT NULL,
  sale_item_id      uuid NOT NULL,
  starts_at         timestamptz NOT NULL,
  expires_at        timestamptz NOT NULL,
  package_status_id smallint NOT NULL REFERENCES prepaid.package_statuses (id),
  status_changed_at timestamptz NOT NULL DEFAULT now(),
  units_balance     integer NOT NULL DEFAULT 0,
  balance_updated_at timestamptz NOT NULL DEFAULT now(),
  created_at        timestamptz NOT NULL DEFAULT now(),
  sync_version      bigint NOT NULL DEFAULT 0,
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, affiliation_id) REFERENCES customers.affiliations (tenant_id, id),
  FOREIGN KEY (tenant_id, package_type_id) REFERENCES prepaid.package_types (tenant_id, id),
  FOREIGN KEY (tenant_id, sale_item_id) REFERENCES sales.sale_items (tenant_id, id),
  CHECK (expires_at > starts_at)
);
COMMENT ON TABLE prepaid.packages IS 'Tiquetera vendida a un cliente en un comercio. El id lo genera el dispositivo (venta offline).';
COMMENT ON COLUMN prepaid.packages.units_balance IS 'Caché del saldo = SUM(ledger.movements.units_delta). Puede quedar negativo si dos consumos offline chocan: eso abre un conflicto (RF-OFF-04).';

-- Orden FIFO por vencimiento (RF-TIQ-04)
CREATE INDEX packages_affiliation_fifo_ix ON prepaid.packages (tenant_id, affiliation_id, expires_at);
-- Proceso diario de vencimiento (RF-TIQ-05)
CREATE INDEX packages_expiration_ix ON prepaid.packages (expires_at, package_status_id);
CREATE INDEX packages_sale_item_ix ON prepaid.packages (tenant_id, sale_item_id);

CREATE TRIGGER packages_sync BEFORE INSERT OR UPDATE ON prepaid.packages
  FOR EACH ROW EXECUTE FUNCTION core.bump_sync_version();
CREATE TRIGGER packages_status BEFORE UPDATE OF package_status_id ON prepaid.packages
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('prepaid.package_status_transitions', 'package_status_id');

-- >>> 09_ledger_movimientos.sql
-- =============================================================================
-- 09 · ledger (movimientos): asientos por tiquetera, inmutables
-- Un evento genera 1..n movimientos (un consumo de 2 unidades puede tocar
-- dos tiqueteras si la primera se agota). El saldo es la suma de movimientos.
-- =============================================================================

CREATE TABLE ledger.movements (
  id            uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id     uuid NOT NULL,
  event_id      uuid NOT NULL,
  package_id    uuid NOT NULL,
  units_delta   integer NOT NULL CHECK (units_delta <> 0),
  balance_after integer NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (event_id, package_id),
  FOREIGN KEY (tenant_id, event_id) REFERENCES ledger.events (tenant_id, id),
  FOREIGN KEY (tenant_id, package_id) REFERENCES prepaid.packages (tenant_id, id)
);
COMMENT ON TABLE ledger.movements IS 'Asiento del libro de unidades: +compra, -consumo, +reverso, ±ajuste, -vencimiento. Nunca se edita ni se borra.';
COMMENT ON COLUMN ledger.movements.balance_after IS 'Saldo de la tiquetera justo después de aplicar el asiento en el servidor.';

CREATE INDEX movements_package_ix ON ledger.movements (tenant_id, package_id, created_at);

-- -----------------------------------------------------------------------------
-- Aplica el asiento a la caché de saldo en la misma transacción.
-- El UPDATE bloquea la fila de la tiquetera: dos consumos simultáneos se serializan.
-- El signo del asiento debe coincidir con el definido para el tipo de evento.
-- -----------------------------------------------------------------------------
CREATE FUNCTION ledger.apply_movement() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_effect smallint;
BEGIN
  SELECT et.balance_effect INTO v_effect
    FROM ledger.events e
    JOIN ledger.event_types et ON et.id = e.event_type_id
   WHERE e.id = NEW.event_id;

  IF v_effect <> 0 AND sign(NEW.units_delta) <> v_effect THEN
    RAISE EXCEPTION 'El signo del movimiento (%) no corresponde al tipo de evento', NEW.units_delta
      USING ERRCODE = 'check_violation';
  END IF;

  UPDATE prepaid.packages
     SET units_balance = units_balance + NEW.units_delta,
         balance_updated_at = now()
   WHERE id = NEW.package_id
     AND tenant_id = NEW.tenant_id
  RETURNING units_balance INTO NEW.balance_after;

  RETURN NEW;
END $$;

CREATE TRIGGER movements_apply BEFORE INSERT ON ledger.movements
  FOR EACH ROW EXECUTE FUNCTION ledger.apply_movement();
CREATE TRIGGER movements_immutable BEFORE UPDATE OR DELETE ON ledger.movements
  FOR EACH ROW EXECUTE FUNCTION core.forbid_mutation();

-- >>> 10_consumptions.sql
-- =============================================================================
-- 10 · consumptions: detalle del consumo (subtipo de ledger.events)
-- =============================================================================

CREATE SCHEMA consumptions;

CREATE TABLE consumptions.capture_methods (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(80) NOT NULL
);
COMMENT ON TABLE consumptions.capture_methods IS 'Escaneo de QR o búsqueda manual por nombre/documento (RF-CON-06).';

CREATE TABLE consumptions.consumptions (
  event_id                     uuid PRIMARY KEY,
  tenant_id                    uuid NOT NULL,
  capture_method_id            smallint NOT NULL REFERENCES consumptions.capture_methods (id),
  service_id                   uuid,
  service_schedule_id          uuid,
  business_date                date NOT NULL,
  units_requested              integer NOT NULL CHECK (units_requested > 0),
  affiliation_qr_code_id       uuid,
  device_reported_balance_after integer,
  UNIQUE (tenant_id, event_id),
  FOREIGN KEY (tenant_id, event_id) REFERENCES ledger.events (tenant_id, id),
  FOREIGN KEY (tenant_id, service_id) REFERENCES tenancy.services (tenant_id, id),
  FOREIGN KEY (tenant_id, service_schedule_id) REFERENCES tenancy.service_schedules (tenant_id, id),
  FOREIGN KEY (tenant_id, affiliation_qr_code_id) REFERENCES customers.affiliation_qr_codes (tenant_id, id)
);
COMMENT ON TABLE consumptions.consumptions IS 'Consumo (RF-CON-02). business_date es la fecha local del comercio en que ocurrió; con service_id sostiene la regla de un consumo por horario.';
COMMENT ON COLUMN consumptions.consumptions.device_reported_balance_after IS 'Saldo que vio el cajero en su celular (posiblemente offline). Comparado con el del servidor ayuda a detectar conflictos.';

-- Regla antifraude (RF-CON-03): búsqueda rápida de consumos del mismo cliente,
-- servicio y día. No es UNIQUE a propósito: un consumo offline que choca debe
-- guardarse (ya ocurrió) y abrir un conflicto, no rechazarse.
CREATE INDEX consumptions_service_day_ix
  ON consumptions.consumptions (tenant_id, service_id, business_date);

CREATE TABLE consumptions.consumption_overrides (
  event_id                    uuid PRIMARY KEY,
  tenant_id                   uuid NOT NULL,
  event_reason_id             smallint NOT NULL REFERENCES ledger.event_reasons (id),
  reason_note                 varchar(500) NOT NULL CHECK (length(trim(reason_note)) > 0),
  authorized_by_membership_id uuid NOT NULL,
  authorized_at               timestamptz NOT NULL,
  FOREIGN KEY (tenant_id, event_id) REFERENCES consumptions.consumptions (tenant_id, event_id),
  FOREIGN KEY (tenant_id, authorized_by_membership_id) REFERENCES tenancy.memberships (tenant_id, id)
);
COMMENT ON TABLE consumptions.consumption_overrides IS 'Autorización explícita de un segundo consumo en el mismo horario, con motivo obligatorio (HU-06-03).';

CREATE TRIGGER consumptions_immutable BEFORE UPDATE OR DELETE ON consumptions.consumptions
  FOR EACH ROW EXECUTE FUNCTION core.forbid_mutation();
CREATE TRIGGER consumption_overrides_immutable BEFORE UPDATE OR DELETE ON consumptions.consumption_overrides
  FOR EACH ROW EXECUTE FUNCTION core.forbid_mutation();

-- >>> 11_sync.sql
-- =============================================================================
-- 11 · sync: recepción idempotente de la bandeja de salida y conflictos
-- =============================================================================

CREATE SCHEMA sync;

CREATE TABLE sync.inbound_event_kinds (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(80) NOT NULL
);
COMMENT ON TABLE sync.inbound_event_kinds IS 'Qué trae el celular: venta, consumo, reverso, afiliación, registro asistido.';

CREATE TABLE sync.inbound_event_statuses (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  is_terminal boolean NOT NULL
);
COMMENT ON TABLE sync.inbound_event_statuses IS 'Recibido, aplicado, aplicado con conflicto, rechazado.';

CREATE TABLE sync.inbound_event_status_transitions (
  from_status_id smallint NOT NULL REFERENCES sync.inbound_event_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES sync.inbound_event_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE sync.rejection_reasons (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(120) NOT NULL
);
COMMENT ON TABLE sync.rejection_reasons IS 'QR con firma inválida, de otro comercio, comercio en solo lectura, datos inválidos...';

CREATE TABLE sync.sync_batches (
  id            uuid PRIMARY KEY,
  tenant_id     uuid NOT NULL REFERENCES tenancy.tenants (id),
  device_id     uuid NOT NULL REFERENCES identity.devices (id),
  membership_id uuid NOT NULL,
  event_count   integer NOT NULL CHECK (event_count > 0),
  received_at   timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, membership_id) REFERENCES tenancy.memberships (tenant_id, id)
);
COMMENT ON TABLE sync.sync_batches IS 'Lote enviado por un celular. Reenviar el mismo lote no duplica nada.';

CREATE TABLE sync.inbound_events (
  id                       uuid PRIMARY KEY,
  tenant_id                uuid NOT NULL,
  batch_id                 uuid NOT NULL,
  inbound_event_kind_id    smallint NOT NULL REFERENCES sync.inbound_event_kinds (id),
  inbound_event_status_id  smallint NOT NULL REFERENCES sync.inbound_event_statuses (id),
  status_changed_at        timestamptz NOT NULL DEFAULT now(),
  rejection_reason_id      smallint REFERENCES sync.rejection_reasons (id),
  occurred_at              timestamptz NOT NULL,
  received_at              timestamptz NOT NULL DEFAULT now(),
  payload                  jsonb,
  payload_sha256           bytea NOT NULL,
  ledger_event_id          uuid,
  FOREIGN KEY (tenant_id, batch_id) REFERENCES sync.sync_batches (tenant_id, id),
  FOREIGN KEY (tenant_id, ledger_event_id) REFERENCES ledger.events (tenant_id, id)
);
COMMENT ON TABLE sync.inbound_events IS 'Registro de idempotencia: la PK es el UUID v7 generado en el celular. Un reintento choca con la PK y se responde "ya aplicado".';
COMMENT ON COLUMN sync.inbound_events.payload IS 'Copia cruda para soporte y reproceso. Se vacía (NULL) a los 90 días; el hash queda.';
CREATE INDEX inbound_events_pending_ix ON sync.inbound_events (tenant_id, inbound_event_status_id, occurred_at);

CREATE TABLE sync.device_checkpoints (
  tenant_id            uuid NOT NULL REFERENCES tenancy.tenants (id),
  device_id            uuid NOT NULL REFERENCES identity.devices (id),
  last_pulled_version  bigint NOT NULL DEFAULT 0,
  last_pulled_at       timestamptz,
  last_pushed_at       timestamptz,
  pending_reported     integer NOT NULL DEFAULT 0 CHECK (pending_reported >= 0),
  oldest_pending_at    timestamptz,
  PRIMARY KEY (tenant_id, device_id)
);
COMMENT ON TABLE sync.device_checkpoints IS 'Hasta qué versión bajó cada celular y cuántos pendientes reportó (HU-07-01, HU-07-05).';

-- ----------------------------------------------------------------- conflictos
CREATE TABLE sync.conflict_types (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(120) NOT NULL,
  description text
);

CREATE TABLE sync.conflict_statuses (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  is_initial  boolean NOT NULL DEFAULT false,
  is_terminal boolean NOT NULL DEFAULT false
);

CREATE TABLE sync.conflict_status_transitions (
  from_status_id smallint NOT NULL REFERENCES sync.conflict_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES sync.conflict_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE sync.conflicts (
  id                        uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id                 uuid NOT NULL REFERENCES tenancy.tenants (id),
  conflict_type_id          smallint NOT NULL REFERENCES sync.conflict_types (id),
  conflict_status_id        smallint NOT NULL REFERENCES sync.conflict_statuses (id),
  status_changed_at         timestamptz NOT NULL DEFAULT now(),
  detected_at               timestamptz NOT NULL DEFAULT now(),
  resolved_by_membership_id uuid,
  resolution_note           varchar(500),
  resolution_event_id       uuid,
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, resolved_by_membership_id) REFERENCES tenancy.memberships (tenant_id, id),
  FOREIGN KEY (tenant_id, resolution_event_id) REFERENCES ledger.events (tenant_id, id)
);
COMMENT ON TABLE sync.conflicts IS 'Conflicto detectado al sincronizar (doble consumo, saldo negativo...). El propietario acepta o reversa (RF-OFF-04).';
CREATE INDEX conflicts_open_ix ON sync.conflicts (tenant_id, conflict_status_id, detected_at);

CREATE TABLE sync.conflict_events (
  tenant_id   uuid NOT NULL,
  conflict_id uuid NOT NULL,
  event_id    uuid NOT NULL,
  PRIMARY KEY (conflict_id, event_id),
  FOREIGN KEY (tenant_id, conflict_id) REFERENCES sync.conflicts (tenant_id, id),
  FOREIGN KEY (tenant_id, event_id) REFERENCES ledger.events (tenant_id, id)
);
COMMENT ON TABLE sync.conflict_events IS 'Intermedia conflicto-evento: qué eventos chocaron.';

CREATE TRIGGER inbound_events_status BEFORE UPDATE OF inbound_event_status_id ON sync.inbound_events
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('sync.inbound_event_status_transitions', 'inbound_event_status_id');
CREATE TRIGGER conflicts_status BEFORE UPDATE OF conflict_status_id ON sync.conflicts
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('sync.conflict_status_transitions', 'conflict_status_id');

-- >>> 12_billing.sql
-- =============================================================================
-- 12 · billing: planes de VECI, límites, funciones, suscripciones y pagos
-- =============================================================================

CREATE SCHEMA billing;

CREATE TABLE billing.billing_periods (
  id     smallint PRIMARY KEY,
  code   core.catalog_code NOT NULL UNIQUE,
  name   varchar(40) NOT NULL,
  months smallint NOT NULL CHECK (months > 0)
);

CREATE TABLE billing.limit_types (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  description text
);
COMMENT ON TABLE billing.limit_types IS 'Qué se limita: clientes activos, cajeros, sedes. Un límite nuevo = una fila, no una columna.';

CREATE TABLE billing.features (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  description text
);
COMMENT ON TABLE billing.features IS 'Funciones que se habilitan por plan: multisede, WhatsApp, exportar reportes...';

CREATE TABLE billing.plans (
  id                smallint PRIMARY KEY,
  code              core.catalog_code NOT NULL UNIQUE,
  name              varchar(80) NOT NULL,
  price_amount      core.money_amount NOT NULL,
  currency_code     char(3) NOT NULL DEFAULT 'COP' REFERENCES core.currencies (code),
  billing_period_id smallint NOT NULL REFERENCES billing.billing_periods (id),
  trial_days        smallint CHECK (trial_days > 0),
  grace_days        smallint NOT NULL DEFAULT 7 CHECK (grace_days >= 0),
  is_public         boolean NOT NULL DEFAULT true,
  is_active         boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE billing.plans IS 'Prueba, Básico, Pro (RF-SUS-01).';

CREATE TABLE billing.plan_limits (
  plan_id       smallint NOT NULL REFERENCES billing.plans (id),
  limit_type_id smallint NOT NULL REFERENCES billing.limit_types (id),
  max_value     integer CHECK (max_value >= 0),
  PRIMARY KEY (plan_id, limit_type_id)
);
COMMENT ON TABLE billing.plan_limits IS 'Intermedia plan-límite. max_value NULL = ilimitado.';

CREATE TABLE billing.plan_features (
  plan_id    smallint NOT NULL REFERENCES billing.plans (id),
  feature_id smallint NOT NULL REFERENCES billing.features (id),
  PRIMARY KEY (plan_id, feature_id)
);
COMMENT ON TABLE billing.plan_features IS 'Intermedia plan-función.';

CREATE TABLE billing.subscription_statuses (
  id            smallint PRIMARY KEY,
  code          core.catalog_code NOT NULL UNIQUE,
  name          varchar(80) NOT NULL,
  description   text,
  allows_writes boolean NOT NULL,
  is_initial    boolean NOT NULL DEFAULT false,
  is_terminal   boolean NOT NULL DEFAULT false
);
COMMENT ON TABLE billing.subscription_statuses IS 'Prueba, activa, en gracia, solo lectura, cancelada. allows_writes = puede vender y registrar consumos (RF-SUS-03).';

CREATE TABLE billing.subscription_status_transitions (
  from_status_id smallint NOT NULL REFERENCES billing.subscription_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES billing.subscription_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE billing.subscriptions (
  id                     uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id              uuid NOT NULL REFERENCES tenancy.tenants (id),
  plan_id                smallint NOT NULL REFERENCES billing.plans (id),
  subscription_status_id smallint NOT NULL REFERENCES billing.subscription_statuses (id),
  status_changed_at      timestamptz NOT NULL DEFAULT now(),
  started_at             timestamptz NOT NULL DEFAULT now(),
  current_period_ends_at timestamptz NOT NULL,
  grace_ends_at          timestamptz,
  ended_at               timestamptz,
  UNIQUE (tenant_id, id),
  CHECK (current_period_ends_at > started_at)
);
COMMENT ON TABLE billing.subscriptions IS 'Suscripción del comercio a un plan. Cambiar de plan cierra la fila (ended_at) y abre otra: queda la historia.';
CREATE UNIQUE INDEX subscriptions_current_ux ON billing.subscriptions (tenant_id) WHERE ended_at IS NULL;
CREATE INDEX subscriptions_due_ix ON billing.subscriptions (current_period_ends_at) WHERE ended_at IS NULL;

CREATE TABLE billing.subscription_payments (
  id                  uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id           uuid NOT NULL,
  subscription_id     uuid NOT NULL,
  paid_at             timestamptz NOT NULL,
  amount              core.money_amount NOT NULL CHECK (amount > 0),
  currency_code       char(3) NOT NULL DEFAULT 'COP' REFERENCES core.currencies (code),
  payment_method_id   smallint NOT NULL REFERENCES core.payment_methods (id),
  payment_channel_id  smallint,
  reference           varchar(60),
  period_starts_on    date NOT NULL,
  period_ends_on      date NOT NULL,
  recorded_by_user_id uuid NOT NULL REFERENCES identity.users (id),
  created_at          timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (tenant_id, subscription_id) REFERENCES billing.subscriptions (tenant_id, id),
  FOREIGN KEY (payment_channel_id, payment_method_id) REFERENCES core.payment_channels (id, payment_method_id),
  CHECK (period_ends_on > period_starts_on)
);
COMMENT ON TABLE billing.subscription_payments IS 'Pago manual de la suscripción registrado por VECI (RF-SUS-02).';

CREATE TRIGGER subscriptions_status BEFORE UPDATE OF subscription_status_id ON billing.subscriptions
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('billing.subscription_status_transitions', 'subscription_status_id');
CREATE TRIGGER subscription_payments_immutable BEFORE UPDATE OR DELETE ON billing.subscription_payments
  FOR EACH ROW EXECUTE FUNCTION core.forbid_mutation();

-- >>> 13_notifications.sql
-- =============================================================================
-- 13 · notifications: plantillas, tokens push y bandeja de envío
-- =============================================================================

CREATE SCHEMA notifications;

CREATE TABLE notifications.channels (
  id         smallint PRIMARY KEY,
  code       core.catalog_code NOT NULL UNIQUE,
  name       varchar(40) NOT NULL,
  is_enabled boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE notifications.channels IS 'Push (MVP); WhatsApp, SMS y correo a futuro.';

CREATE TABLE notifications.notification_types (
  id          smallint PRIMARY KEY,
  module_id   smallint NOT NULL REFERENCES core.modules (id),
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(120) NOT NULL,
  description text
);

CREATE TABLE notifications.templates (
  id                   uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  notification_type_id smallint NOT NULL REFERENCES notifications.notification_types (id),
  channel_id           smallint NOT NULL REFERENCES notifications.channels (id),
  locale               varchar(10) NOT NULL DEFAULT 'es-CO',
  version              integer NOT NULL CHECK (version > 0),
  title_template       varchar(120),
  body_template        varchar(1000) NOT NULL,
  is_active            boolean NOT NULL DEFAULT true,
  created_at           timestamptz NOT NULL DEFAULT now(),
  UNIQUE (notification_type_id, channel_id, locale, version)
);
COMMENT ON TABLE notifications.templates IS 'Textos con el tono VECI, versionados. Cambiar un texto no requiere desplegar código.';
CREATE UNIQUE INDEX templates_one_active_ux
  ON notifications.templates (notification_type_id, channel_id, locale) WHERE is_active;

CREATE TABLE notifications.notification_statuses (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  is_terminal boolean NOT NULL
);

CREATE TABLE notifications.notification_status_transitions (
  from_status_id smallint NOT NULL REFERENCES notifications.notification_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES notifications.notification_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE notifications.push_tokens (
  id            uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  user_id       uuid NOT NULL REFERENCES identity.users (id),
  device_id     uuid NOT NULL REFERENCES identity.devices (id),
  token         varchar(500) NOT NULL,
  registered_at timestamptz NOT NULL DEFAULT now(),
  revoked_at    timestamptz
);
COMMENT ON TABLE notifications.push_tokens IS 'Token de Firebase Cloud Messaging por usuario y dispositivo (HU-09-01).';
CREATE UNIQUE INDEX push_tokens_current_ux ON notifications.push_tokens (token) WHERE revoked_at IS NULL;
CREATE INDEX push_tokens_user_ix ON notifications.push_tokens (user_id) WHERE revoked_at IS NULL;

CREATE TABLE notifications.notifications (
  id                     uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id              uuid REFERENCES tenancy.tenants (id),
  recipient_person_id    uuid NOT NULL REFERENCES identity.people (id),
  notification_type_id   smallint NOT NULL REFERENCES notifications.notification_types (id),
  channel_id             smallint NOT NULL REFERENCES notifications.channels (id),
  template_id            uuid NOT NULL REFERENCES notifications.templates (id),
  source_event_id        uuid REFERENCES ledger.events (id),
  package_id             uuid REFERENCES prepaid.packages (id),
  variables              jsonb NOT NULL DEFAULT '{}'::jsonb,
  notification_status_id smallint NOT NULL REFERENCES notifications.notification_statuses (id),
  status_changed_at      timestamptz NOT NULL DEFAULT now(),
  scheduled_at           timestamptz NOT NULL DEFAULT now(),
  sent_at                timestamptz,
  created_at             timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE notifications.notifications IS 'Bandeja de envío (outbox). variables guarda los datos que llenan la plantilla, p. ej. hora real del consumo (RF-OFF-06).';
CREATE INDEX notifications_dispatch_ix ON notifications.notifications (notification_status_id, scheduled_at);
CREATE INDEX notifications_recipient_ix ON notifications.notifications (recipient_person_id, created_at DESC);
-- El aviso de renovación sale una sola vez por tiquetera y canal (HU-09-03)
CREATE UNIQUE INDEX notifications_once_per_package_ux
  ON notifications.notifications (package_id, notification_type_id, channel_id)
  WHERE package_id IS NOT NULL;

CREATE TABLE notifications.delivery_attempts (
  id                  uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  notification_id     uuid NOT NULL REFERENCES notifications.notifications (id),
  attempted_at        timestamptz NOT NULL DEFAULT now(),
  succeeded           boolean NOT NULL,
  provider_message_id varchar(200),
  error_code          varchar(60),
  error_message       varchar(500)
);
CREATE INDEX delivery_attempts_notification_ix ON notifications.delivery_attempts (notification_id);

CREATE TRIGGER notifications_status BEFORE UPDATE OF notification_status_id ON notifications.notifications
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('notifications.notification_status_transitions', 'notification_status_id');

-- >>> 14_compliance_audit.sql
-- =============================================================================
-- 14 · compliance (Ley 1581 de 2012) y audit (bitácora inmutable)
-- =============================================================================

CREATE SCHEMA compliance;
CREATE SCHEMA audit;

-- ------------------------------------------------- políticas y autorizaciones
CREATE TABLE compliance.policy_document_types (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(120) NOT NULL
);

CREATE TABLE compliance.policy_versions (
  id                      uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  policy_document_type_id smallint NOT NULL REFERENCES compliance.policy_document_types (id),
  version_label           varchar(20) NOT NULL,
  content_url             varchar(500) NOT NULL,
  content_sha256          bytea NOT NULL,
  published_at            timestamptz NOT NULL,
  requires_reacceptance   boolean NOT NULL DEFAULT true,
  UNIQUE (policy_document_type_id, version_label)
);
COMMENT ON TABLE compliance.policy_versions IS 'Versiones publicadas de la política de tratamiento de datos (HU-12-01). La vigente es la última publicada.';

CREATE TABLE compliance.consent_channels (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(80) NOT NULL
);
COMMENT ON TABLE compliance.consent_channels IS 'Aceptada por el cliente en la app, confirmada por el cajero (registro asistido), web.';

CREATE TABLE compliance.consents (
  id                         uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  person_id                  uuid NOT NULL REFERENCES identity.people (id),
  policy_version_id          uuid NOT NULL REFERENCES compliance.policy_versions (id),
  consent_channel_id         smallint NOT NULL REFERENCES compliance.consent_channels (id),
  accepted_at                timestamptz NOT NULL DEFAULT now(),
  captured_by_tenant_id      uuid REFERENCES tenancy.tenants (id),
  captured_by_membership_id  uuid REFERENCES tenancy.memberships (id),
  device_id                  uuid REFERENCES identity.devices (id),
  ip_address                 inet,
  revoked_at                 timestamptz,
  UNIQUE (person_id, policy_version_id)
);
COMMENT ON TABLE compliance.consents IS 'Quién aceptó qué versión, cuándo y por qué canal (RF-CLI-05, RNF-LEG-01).';

-- ------------------------------------------------- derechos de habeas data
CREATE TABLE compliance.data_request_types (
  id                       smallint PRIMARY KEY,
  code                     core.catalog_code NOT NULL UNIQUE,
  name                     varchar(80) NOT NULL,
  legal_term_business_days smallint NOT NULL CHECK (legal_term_business_days > 0)
);
COMMENT ON TABLE compliance.data_request_types IS 'Consulta (10 días hábiles), corrección y supresión (reclamos, 15 días hábiles).';

CREATE TABLE compliance.data_request_statuses (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  is_initial  boolean NOT NULL DEFAULT false,
  is_terminal boolean NOT NULL DEFAULT false
);

CREATE TABLE compliance.data_request_status_transitions (
  from_status_id smallint NOT NULL REFERENCES compliance.data_request_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES compliance.data_request_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE compliance.data_requests (
  id                     uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  person_id              uuid NOT NULL REFERENCES identity.people (id),
  data_request_type_id   smallint NOT NULL REFERENCES compliance.data_request_types (id),
  data_request_status_id smallint NOT NULL REFERENCES compliance.data_request_statuses (id),
  status_changed_at      timestamptz NOT NULL DEFAULT now(),
  filed_at               timestamptz NOT NULL DEFAULT now(),
  due_on                 date NOT NULL,
  request_detail         varchar(2000) NOT NULL,
  resolution_detail      varchar(2000),
  resolved_by_user_id    uuid REFERENCES identity.users (id),
  resolved_at            timestamptz
);
COMMENT ON TABLE compliance.data_requests IS 'Solicitudes de ver, corregir o eliminar datos (HU-12-02). due_on se calcula con core.holidays.';
CREATE INDEX data_requests_due_ix ON compliance.data_requests (data_request_status_id, due_on);

CREATE TRIGGER data_requests_status BEFORE UPDATE OF data_request_status_id ON compliance.data_requests
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('compliance.data_request_status_transitions', 'data_request_status_id');

-- ------------------------------------------------- bitácora de auditoría
CREATE TABLE audit.actions (
  id          smallint PRIMARY KEY,
  module_id   smallint NOT NULL REFERENCES core.modules (id),
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(120) NOT NULL,
  is_sensitive boolean NOT NULL DEFAULT false
);
COMMENT ON TABLE audit.actions IS 'Acciones auditables: venta, consumo, ajuste, cambio de rol, restablecer PIN, bloqueo de cuenta...';

CREATE TABLE audit.audit_log (
  id                  uuid NOT NULL DEFAULT core.uuid_v7(),
  occurred_at         timestamptz NOT NULL DEFAULT now(),
  tenant_id           uuid,
  action_id           smallint NOT NULL REFERENCES audit.actions (id),
  actor_user_id       uuid,
  actor_membership_id uuid,
  entity_table        varchar(63) NOT NULL,
  entity_id           uuid,
  device_id           uuid,
  ip_address          inet,
  request_id          uuid,
  before_data         jsonb,
  after_data          jsonb,
  PRIMARY KEY (id, occurred_at)
) PARTITION BY RANGE (occurred_at);
COMMENT ON TABLE audit.audit_log IS 'Bitácora inmutable (RNF-SEG-05). Particionada por mes; sin FK a datos de negocio para que nada impida conservarla.';
CREATE TABLE audit.audit_log_default PARTITION OF audit.audit_log DEFAULT;
CREATE INDEX audit_log_tenant_ix ON audit.audit_log (tenant_id, occurred_at DESC);
CREATE INDEX audit_log_entity_ix ON audit.audit_log (entity_table, entity_id);

CREATE TRIGGER audit_log_immutable BEFORE UPDATE OR DELETE ON audit.audit_log
  FOR EACH ROW EXECUTE FUNCTION core.forbid_mutation();

-- >>> 15_seguridad_rls.sql
-- =============================================================================
-- 15 · Seguridad: roles de base de datos, permisos y Row Level Security
-- La API se conecta con un usuario miembro de veci_app y, en cada transacción:
--   SET LOCAL app.tenant_id = '<comercio activo>';   -- cajero / propietario
--   SET LOCAL app.person_id = '<persona del token>'; -- cliente en su app
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

-- >>> 16_vistas.sql
-- =============================================================================
-- 16 · Vistas de lectura (security_invoker: respetan RLS de quien consulta)
-- =============================================================================

-- Conciliación: la caché de saldo debe ser igual a la suma del libro.
CREATE VIEW prepaid.v_package_balance_check WITH (security_invoker = true) AS
SELECT p.tenant_id,
       p.id                              AS package_id,
       p.units_balance                   AS cached_balance,
       coalesce(sum(m.units_delta), 0)   AS ledger_balance,
       p.units_balance = coalesce(sum(m.units_delta), 0) AS is_consistent
  FROM prepaid.packages p
  LEFT JOIN ledger.movements m ON m.package_id = p.id AND m.tenant_id = p.tenant_id
 GROUP BY p.tenant_id, p.id, p.units_balance;

-- Saldo del cliente en cada comercio: suma de tiqueteras que admiten consumo (RF-TIQ-04).
CREATE VIEW customers.v_affiliation_balances WITH (security_invoker = true) AS
SELECT a.tenant_id,
       a.id                                   AS affiliation_id,
       a.person_id,
       coalesce(sum(p.units_balance) FILTER (WHERE ps.allows_consumption AND p.expires_at > now()), 0)
                                              AS available_units,
       min(p.expires_at) FILTER (WHERE ps.allows_consumption AND p.expires_at > now())
                                              AS next_expiration_at
  FROM customers.affiliations a
  LEFT JOIN prepaid.packages p          ON p.affiliation_id = a.id AND p.tenant_id = a.tenant_id
  LEFT JOIN prepaid.package_statuses ps ON ps.id = p.package_status_id
 GROUP BY a.tenant_id, a.id, a.person_id;

-- Totales de venta derivados de sus líneas (no se guardan para no duplicar datos).
CREATE VIEW sales.v_sale_totals WITH (security_invoker = true) AS
SELECT s.tenant_id,
       s.event_id                      AS sale_id,
       e.occurred_at,
       e.branch_id,
       e.actor_membership_id,
       ss.counts_as_revenue,
       sum(si.line_total)              AS total_amount
  FROM sales.sales s
  JOIN ledger.events e        ON e.id = s.event_id
  JOIN sales.sale_statuses ss ON ss.id = s.sale_status_id
  JOIN sales.sale_items si    ON si.sale_id = s.event_id
 GROUP BY s.tenant_id, s.event_id, e.occurred_at, e.branch_id, e.actor_membership_id, ss.counts_as_revenue;

-- Dinero comprometido (RF-REP-01): unidades por servir × valor pagado por unidad.
CREATE VIEW prepaid.v_committed_liability WITH (security_invoker = true) AS
SELECT p.tenant_id,
       p.package_type_id,
       sum(greatest(p.units_balance, 0))                                          AS pending_units,
       round(sum(greatest(p.units_balance, 0) * si.unit_price / pt.units_quantity), 2) AS pending_amount
  FROM prepaid.packages p
  JOIN prepaid.package_statuses ps ON ps.id = p.package_status_id AND ps.counts_as_liability
  JOIN sales.sale_items si         ON si.id = p.sale_item_id
  JOIN prepaid.package_types pt    ON pt.id = p.package_type_id
 GROUP BY p.tenant_id, p.package_type_id;

-- Historial auditable por cliente (RF-REP-04, HU-10-04)
CREATE VIEW ledger.v_customer_history WITH (security_invoker = true) AS
SELECT e.tenant_id,
       e.affiliation_id,
       e.id                AS event_id,
       et.code             AS event_type_code,
       e.occurred_at,
       e.recorded_at,
       e.recorded_at - e.occurred_at AS sync_delay,
       e.branch_id,
       e.actor_membership_id,
       m.package_id,
       m.units_delta,
       m.balance_after,
       e.reverses_event_id,
       e.event_reason_id,
       e.reason_note
  FROM ledger.events e
  JOIN ledger.event_types et ON et.id = e.event_type_id
  LEFT JOIN ledger.movements m ON m.event_id = e.id AND m.tenant_id = e.tenant_id;

GRANT SELECT ON prepaid.v_package_balance_check, customers.v_affiliation_balances,
                sales.v_sale_totals, prepaid.v_committed_liability, ledger.v_customer_history
  TO veci_app, veci_platform;

-- >>> 20_semillas_catalogos.sql
-- =============================================================================
-- 20 · Semillas de catálogos y máquinas de estado
-- Los id son estables entre entornos; el código de la aplicación usa code.
-- =============================================================================

-- ---------------------------------------------------------------- core
INSERT INTO core.modules (id, code, name) VALUES
  (1,'AUTH','Autenticación'), (2,'TENANCY','Comercios y sedes'), (3,'CUSTOMERS','Clientes'),
  (4,'PREPAID','Tiqueteras'), (5,'CONSUMPTIONS','Consumos'), (6,'SYNC','Sincronización'),
  (7,'REPORTS','Reportes'), (8,'NOTIFICATIONS','Notificaciones'), (9,'BILLING','Suscripciones'),
  (10,'COMPLIANCE','Protección de datos'), (11,'PLATFORM','Administración VECI');

INSERT INTO core.currencies VALUES ('COP','Peso colombiano',2);
INSERT INTO core.countries VALUES (1,'CO','Colombia','+57');
INSERT INTO core.departments VALUES (1,1,'86','Putumayo');
INSERT INTO core.municipalities (id, department_id, official_code, name) VALUES
  (86001,1,'86001','Mocoa'), (86219,1,'86219','Colón'), (86320,1,'86320','Orito'),
  (86568,1,'86568','Puerto Asís'), (86569,1,'86569','Puerto Caicedo'),
  (86571,1,'86571','Puerto Guzmán'), (86573,1,'86573','Puerto Leguízamo'),
  (86749,1,'86749','Sibundoy'), (86755,1,'86755','San Francisco'),
  (86757,1,'86757','San Miguel'), (86760,1,'86760','Santiago'),
  (86865,1,'86865','Valle del Guamuez'), (86885,1,'86885','Villagarzón');

INSERT INTO core.document_types (id, code, name, country_id, for_natural_person, for_legal_entity, validation_regex, sort_order) VALUES
  (1,'CC','Cédula de ciudadanía',1,true,false,'^[0-9]{6,10}$',1),
  (2,'TI','Tarjeta de identidad',1,true,false,'^[0-9]{10,11}$',2),
  (3,'RC','Registro civil',1,true,false,'^[0-9]{10,11}$',3),
  (4,'CE','Cédula de extranjería',1,true,false,'^[0-9]{6,7}$',4),
  (5,'PPT','Permiso por protección temporal',1,true,false,NULL,5),
  (6,'PASSPORT','Pasaporte',1,true,false,NULL,6),
  (7,'NIT','NIT',1,true,true,'^[0-9]{9,10}$',7);

INSERT INTO core.contact_types (id, code, name, can_login, validation_regex) VALUES
  (1,'MOBILE_PHONE','Celular',true,'^\+[1-9][0-9]{7,14}$'),
  (2,'EMAIL','Correo electrónico',true,'^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  (3,'WHATSAPP','WhatsApp',false,'^\+[1-9][0-9]{7,14}$'),
  (4,'LANDLINE','Teléfono fijo',false,NULL);

INSERT INTO core.weekdays VALUES
  (1,'MONDAY','Lunes'), (2,'TUESDAY','Martes'), (3,'WEDNESDAY','Miércoles'), (4,'THURSDAY','Jueves'),
  (5,'FRIDAY','Viernes'), (6,'SATURDAY','Sábado'), (7,'SUNDAY','Domingo');

INSERT INTO core.data_types VALUES
  (1,'INTEGER','Entero'), (2,'DECIMAL','Decimal'), (3,'BOOLEAN','Sí/No'), (4,'TEXT','Texto'), (5,'TIME','Hora');

INSERT INTO core.payment_methods (id, code, name, needs_channel, sort_order, is_active) VALUES
  (1,'CASH','Efectivo',false,1,true),
  (2,'BANK_TRANSFER','Transferencia',true,2,true),
  (3,'ONLINE_GATEWAY','Pago en línea',true,3,false);

INSERT INTO core.payment_channels (id, payment_method_id, code, name, sort_order, is_active) VALUES
  (1,2,'NEQUI','Nequi',1,true), (2,2,'DAVIPLATA','Daviplata',2,true),
  (3,2,'BANCOLOMBIA','Bancolombia',3,true), (4,3,'WOMPI','Wompi',4,false);

INSERT INTO core.qr_revocation_reasons (id, code, name) VALUES
  (1,'REGENERATED','Regenerado a pedido'), (2,'LOST','Perdido'), (3,'SHARED_OR_COMPROMISED','Compartido o comprometido'),
  (4,'AFFILIATION_ENDED','Afiliación terminada'), (5,'PERSON_ANONYMIZED','Datos eliminados (habeas data)');

-- ---------------------------------------------------------------- identity
INSERT INTO identity.person_statuses (id, code, name, is_initial, is_terminal) VALUES
  (1,'ACTIVE','Activa',true,false), (2,'ANONYMIZED','Anonimizada',false,true);
INSERT INTO identity.person_status_transitions VALUES (1,2);

INSERT INTO identity.user_statuses (id, code, name, allows_login, is_initial, is_terminal) VALUES
  (1,'PENDING_ACTIVATION','Pendiente de activar',false,true,false),
  (2,'ACTIVE','Activo',true,false,false),
  (3,'SUSPENDED','Suspendido por VECI',false,false,false),
  (4,'CLOSED','Cerrado',false,false,true);
INSERT INTO identity.user_status_transitions VALUES (1,2),(1,4),(2,3),(3,2),(2,4),(3,4);

INSERT INTO identity.credential_types (id, code, name, max_failed_attempts, lock_minutes, is_active) VALUES
  (1,'PIN','PIN de 6 dígitos',5,15,true), (2,'PASSWORD','Contraseña',5,15,true),
  (3,'OTP','Código de un solo uso (WhatsApp o SMS)',3,15,false);
INSERT INTO identity.credential_revocation_reasons VALUES
  (1,'CHANGED_BY_USER','Cambiado por el usuario'), (2,'RESET_BY_OWNER','Restablecido por el propietario'),
  (3,'RESET_BY_SUPPORT','Restablecido por soporte VECI'), (4,'USER_CLOSED','Cuenta cerrada');
INSERT INTO identity.login_failure_reasons VALUES
  (1,'UNKNOWN_IDENTIFIER','Celular o correo no registrado'), (2,'WRONG_SECRET','PIN o contraseña incorrectos'),
  (3,'CREDENTIAL_LOCKED','Bloqueo temporal por intentos'), (4,'USER_NOT_ALLOWED','Usuario no habilitado'),
  (5,'MEMBERSHIP_NOT_ALLOWED','Sin acceso activo al comercio');
INSERT INTO identity.session_revocation_reasons VALUES
  (1,'LOGOUT','Cierre de sesión'), (2,'REMOTE_LOGOUT','Cierre remoto desde el panel'),
  (3,'CREDENTIAL_RESET','PIN restablecido'), (4,'USER_SUSPENDED','Usuario suspendido'),
  (5,'MEMBERSHIP_ENDED','Retirado del comercio'), (6,'TOKEN_REUSE_DETECTED','Reutilización de token detectada');
INSERT INTO identity.device_platforms VALUES (1,'ANDROID','Android'), (2,'IOS','iOS'), (3,'WEB','Navegador');

-- ---------------------------------------------------------------- tenancy
INSERT INTO tenancy.business_types (id, code, name, sort_order, is_active) VALUES
  (1,'RESTAURANT','Restaurante',1,true), (2,'CAFETERIA','Cafetería',2,true), (3,'BAKERY','Panadería',3,true),
  (4,'SCHOOL','Colegio',4,true), (5,'STORE','Tienda de barrio',5,true), (6,'OTHER','Otro',99,true);

INSERT INTO tenancy.tenant_statuses (id, code, name, allows_operations, is_initial, is_terminal) VALUES
  (1,'ONBOARDING','En configuración',false,true,false), (2,'ACTIVE','Activo',true,false,false),
  (3,'SUSPENDED','Suspendido por VECI',false,false,false), (4,'CLOSED','Cerrado',false,false,true);
INSERT INTO tenancy.tenant_status_transitions VALUES (1,2),(1,4),(2,3),(3,2),(2,4),(3,4);

INSERT INTO tenancy.branch_statuses (id, code, name, allows_operations) VALUES
  (1,'ACTIVE','Activa',true), (2,'INACTIVE','Inactiva',false), (3,'CLOSED','Cerrada',false);
INSERT INTO tenancy.branch_status_transitions VALUES (1,2),(2,1),(1,3),(2,3);

INSERT INTO tenancy.membership_statuses (id, code, name, allows_login, is_initial, is_terminal) VALUES
  (1,'INVITED','Invitado',false,true,false), (2,'ACTIVE','Activo',true,false,false),
  (3,'SUSPENDED','Suspendido',false,false,false), (4,'REMOVED','Retirado',false,false,true);
INSERT INTO tenancy.membership_status_transitions VALUES (1,2),(1,4),(2,3),(3,2),(2,4),(3,4);

-- ---------------------------------------------------------------- customers
INSERT INTO customers.affiliation_statuses (id, code, name, allows_operations, is_initial, is_terminal) VALUES
  (1,'ACTIVE','Activa',true,true,false), (2,'BLOCKED','Bloqueada por el comercio',false,false,false),
  (3,'ENDED','Retirada',false,false,true);
INSERT INTO customers.affiliation_status_transitions VALUES (1,2),(2,1),(1,3),(2,3);
INSERT INTO customers.affiliation_channels VALUES
  (1,'PERSONAL_QR_SCAN','Escaneo del QR personal'), (2,'ASSISTED_REGISTRATION','Registro asistido por el cajero'),
  (3,'DATA_IMPORT','Importación de datos');

-- ---------------------------------------------------------------- prepaid
INSERT INTO prepaid.package_type_statuses (id, code, name, allows_sale, is_initial, is_terminal) VALUES
  (1,'ACTIVE','Activo',true,true,false), (2,'INACTIVE','Inactivo',false,false,false),
  (3,'ARCHIVED','Archivado',false,false,true);
INSERT INTO prepaid.package_type_status_transitions VALUES (1,2),(2,1),(2,3);

INSERT INTO prepaid.package_statuses (id, code, name, allows_consumption, counts_as_liability, is_initial, is_terminal) VALUES
  (1,'ACTIVE','Activa',true,true,true,false), (2,'DEPLETED','Agotada',false,false,false,false),
  (3,'EXPIRED','Vencida',false,false,false,true), (4,'VOIDED','Anulada',false,false,false,true);
INSERT INTO prepaid.package_status_transitions VALUES (1,2),(2,1),(1,3),(1,4),(2,4);

INSERT INTO prepaid.consumption_units (tenant_id, code, singular_name, plural_name) VALUES
  (NULL,'LUNCH','almuerzo','almuerzos'), (NULL,'BREAKFAST','desayuno','desayunos'),
  (NULL,'DINNER','cena','cenas'), (NULL,'MEAL','comida','comidas'), (NULL,'COFFEE','café','cafés'),
  (NULL,'BREAD','pan','panes'), (NULL,'UNIT','unidad','unidades');

-- ---------------------------------------------------------------- ledger
INSERT INTO ledger.event_types (id, code, name, balance_effect, requires_actor, requires_reason, is_reversal, is_reversible, notifies_customer) VALUES
  (1,'SALE','Venta de tiquetera',1,true,false,false,true,true),
  (2,'CONSUMPTION','Consumo',-1,true,false,false,true,true),
  (3,'CONSUMPTION_REVERSAL','Reverso de consumo',1,true,true,true,false,true),
  (4,'SALE_VOID','Anulación de venta',-1,true,true,true,false,true),
  (5,'ADJUSTMENT','Ajuste de saldo',0,true,true,false,false,true),
  (6,'EXPIRATION','Vencimiento',-1,false,false,false,false,false);
INSERT INTO ledger.event_origins VALUES
  (1,'ONLINE','En línea'), (2,'OFFLINE_SYNC','Sincronizado desde el celular'),
  (3,'SYSTEM_JOB','Proceso automático'), (4,'PLATFORM_CONSOLE','Consola VECI');
INSERT INTO ledger.event_reasons (id, code, name, sort_order) VALUES
  (1,'DATA_ENTRY_ERROR','Error al registrar',1), (2,'CUSTOMER_CLAIM','Reclamo del cliente',2),
  (3,'DUPLICATE_RECORD','Registro duplicado',3), (4,'COURTESY','Cortesía',4),
  (5,'AUTHORIZED_EXTRA_SERVICE','Consumo adicional autorizado',5), (6,'CONFLICT_RESOLUTION','Resolución de conflicto',6),
  (7,'OTHER','Otro',99);

-- ---------------------------------------------------------------- sales y consumos
INSERT INTO sales.sale_statuses (id, code, name, counts_as_revenue, is_initial, is_terminal) VALUES
  (1,'COMPLETED','Completada',true,true,false), (2,'VOIDED','Anulada',false,false,true);
INSERT INTO sales.sale_status_transitions VALUES (1,2);
INSERT INTO consumptions.capture_methods VALUES (1,'QR_SCAN','Escaneo de QR'), (2,'MANUAL_SEARCH','Búsqueda manual');

-- ---------------------------------------------------------------- sync
INSERT INTO sync.inbound_event_kinds VALUES
  (1,'SALE','Venta'), (2,'CONSUMPTION','Consumo'), (3,'CONSUMPTION_REVERSAL','Reverso de consumo'),
  (4,'AFFILIATION','Afiliación'), (5,'ASSISTED_REGISTRATION','Registro asistido');
INSERT INTO sync.inbound_event_statuses VALUES
  (1,'RECEIVED','Recibido',false), (2,'APPLIED','Aplicado',true),
  (3,'APPLIED_WITH_CONFLICT','Aplicado con conflicto',true), (4,'REJECTED','Rechazado',true);
INSERT INTO sync.inbound_event_status_transitions VALUES (1,2),(1,3),(1,4);
INSERT INTO sync.rejection_reasons VALUES
  (1,'INVALID_SIGNATURE','Firma del QR inválida'), (2,'QR_FROM_OTHER_TENANT','QR de otro comercio'),
  (3,'TENANT_READ_ONLY','Comercio en solo lectura'), (4,'MEMBERSHIP_NOT_ALLOWED','Cajero sin acceso'),
  (5,'VALIDATION_ERROR','Datos inválidos'), (6,'UNKNOWN_REFERENCE','Referencia inexistente');
INSERT INTO sync.conflict_types (id, code, name) VALUES
  (1,'DOUBLE_CONSUMPTION_SAME_SERVICE','Dos consumos en el mismo horario'),
  (2,'NEGATIVE_BALANCE','Saldo negativo'), (3,'CONSUMPTION_ON_EXPIRED_PACKAGE','Consumo con tiquetera vencida'),
  (4,'REVOKED_QR_USED','Consumo con QR revocado');
INSERT INTO sync.conflict_statuses (id, code, name, is_initial, is_terminal) VALUES
  (1,'OPEN','Abierto',true,false), (2,'ACCEPTED','Aceptado',false,true), (3,'REVERSED','Reversado',false,true);
INSERT INTO sync.conflict_status_transitions VALUES (1,2),(1,3);

-- >>> 21_semillas_seguridad_planes.sql
-- =============================================================================
-- 21 · Semillas: roles, permisos, ajustes, planes, notificaciones, cumplimiento
-- =============================================================================

-- ---------------------------------------------------------------- roles
INSERT INTO identity.roles (id, code, name, assignable_to_platform, assignable_to_membership) VALUES
  (1,'VECI_ADMIN','Administrador VECI',true,false),
  (2,'VECI_SUPPORT','Soporte VECI',true,false),
  (3,'OWNER','Propietario',false,true),
  (4,'CASHIER','Cajero',false,true),
  (5,'CUSTOMER','Cliente',false,false);

-- ---------------------------------------------------------------- permisos
INSERT INTO identity.permissions (id, module_id, code, name) VALUES
  (1,2,'tenancy.view_tenant','Ver datos del comercio'),
  (2,2,'tenancy.manage_tenant','Editar datos del comercio'),
  (3,2,'tenancy.manage_branches','Gestionar sedes'),
  (4,2,'tenancy.manage_schedules','Gestionar horarios de servicio'),
  (5,2,'tenancy.manage_staff','Invitar, suspender y retirar cajeros'),
  (6,2,'tenancy.reset_staff_pin','Restablecer PIN de cajeros'),
  (7,2,'tenancy.revoke_devices','Cerrar sesiones de dispositivos'),
  (8,2,'tenancy.manage_settings','Cambiar configuraciones'),
  (9,3,'customers.register','Registrar clientes'),
  (10,3,'customers.affiliate','Afiliar clientes'),
  (11,3,'customers.search','Buscar clientes'),
  (12,3,'customers.view_full_document','Ver documento completo'),
  (13,3,'customers.manage_qr','Revocar y regenerar QR'),
  (14,3,'customers.block','Bloquear afiliaciones'),
  (15,4,'prepaid.manage_package_types','Gestionar tipos de tiquetera'),
  (16,4,'prepaid.sell','Vender tiqueteras'),
  (17,4,'prepaid.void_sale','Anular ventas'),
  (18,4,'prepaid.adjust_balance','Ajustar saldos'),
  (19,5,'consumptions.register','Registrar consumos'),
  (20,5,'consumptions.authorize_extra','Autorizar consumo adicional en el horario'),
  (21,5,'consumptions.reverse_own_recent','Reversar consumos propios recientes'),
  (22,5,'consumptions.reverse_any','Reversar cualquier consumo'),
  (23,6,'sync.push_events','Sincronizar eventos'),
  (24,6,'sync.resolve_conflicts','Resolver conflictos'),
  (25,7,'reports.view_dashboard','Ver tablero y reportes'),
  (26,7,'reports.export','Exportar reportes'),
  (27,7,'reports.cash_closing','Hacer cierre de caja'),
  (28,9,'billing.view_subscription','Ver suscripción'),
  (29,9,'billing.manage_plans','Gestionar planes'),
  (30,9,'billing.record_payment','Registrar pagos de suscripción'),
  (31,11,'platform.manage_tenants','Administrar comercios'),
  (32,11,'platform.reset_customer_pin','Restablecer PIN de clientes'),
  (33,10,'compliance.manage_data_requests','Atender solicitudes de habeas data'),
  (34,3,'me.view_balances','Ver mis saldos y QR'),
  (35,3,'me.manage_profile','Gestionar mi perfil'),
  (36,10,'me.request_data_rights','Solicitar ver, corregir o eliminar mis datos'),
  (37,10,'compliance.view_audit_log','Consultar la bitácora de auditoría');

INSERT INTO identity.role_permissions (role_id, permission_id)
SELECT r.id, p.id
  FROM identity.roles r
  JOIN identity.permissions p ON
       (r.code = 'OWNER' AND split_part(p.code, '.', 1) IN ('tenancy','customers','prepaid','consumptions','sync','reports'))
    OR (r.code = 'OWNER' AND p.code IN ('billing.view_subscription','compliance.view_audit_log'))
    OR (r.code = 'CASHIER' AND p.code IN ('tenancy.view_tenant','customers.register','customers.affiliate',
          'customers.search','prepaid.sell','consumptions.register','consumptions.authorize_extra',
          'consumptions.reverse_own_recent','sync.push_events','reports.cash_closing'))
    OR (r.code = 'VECI_ADMIN' AND (split_part(p.code, '.', 1) IN ('platform','billing')
          OR p.code IN ('tenancy.view_tenant','compliance.manage_data_requests','compliance.view_audit_log')))
    OR (r.code = 'VECI_SUPPORT' AND p.code IN ('tenancy.view_tenant','platform.reset_customer_pin',
          'compliance.manage_data_requests','billing.view_subscription'))
    OR (r.code = 'CUSTOMER' AND split_part(p.code, '.', 1) = 'me');

-- ---------------------------------------------------------------- ajustes
INSERT INTO tenancy.setting_definitions (id, module_id, code, name, data_type_id, default_value, min_value, max_value) VALUES
  (1,8,'RENEWAL_REMINDER_UNITS','Avisar renovación al quedar N unidades',1,'2',1,50),
  (2,7,'INACTIVITY_DAYS','Días sin consumo para considerar inactivo',1,'15',1,365),
  (3,7,'LOW_BALANCE_REPORT_UNITS','Unidades para "próximo a terminar" en reportes',1,'3',1,50),
  (4,5,'CASHIER_REVERSAL_WINDOW_MINUTES','Minutos en que el cajero puede reversar',1,'10',0,1440),
  (5,5,'ONE_CONSUMPTION_PER_SERVICE','Un consumo por horario de servicio',3,'true',NULL,NULL),
  (6,5,'DEFAULT_CONSUMPTION_UNITS','Unidades por defecto al escanear',1,'1',1,20),
  (7,6,'LATE_SYNC_NOTICE_MINUTES','Minutos para explicar un consumo sincronizado tarde',1,'5',1,1440),
  (8,8,'DAILY_SUMMARY_TIME','Hora del resumen diario',5,'20:00',NULL,NULL);

-- ---------------------------------------------------------------- planes
INSERT INTO billing.billing_periods VALUES (1,'MONTHLY','Mensual',1), (2,'YEARLY','Anual',12);
INSERT INTO billing.limit_types (id, code, name) VALUES
  (1,'ACTIVE_CUSTOMERS','Clientes activos'), (2,'CASHIERS','Cajeros'), (3,'BRANCHES','Sedes');
INSERT INTO billing.features (id, code, name) VALUES
  (1,'MULTI_BRANCH','Varias sedes'), (2,'REPORT_EXPORT','Exportar reportes'),
  (3,'WHATSAPP_NOTIFICATIONS','Avisos por WhatsApp'), (4,'DAILY_SUMMARY','Resumen diario');
INSERT INTO billing.plans (id, code, name, price_amount, billing_period_id, trial_days) VALUES
  (1,'TRIAL','Prueba',0,1,30), (2,'BASIC','Básico',35000,1,NULL), (3,'PRO','Pro',65000,1,NULL);
INSERT INTO billing.plan_limits VALUES
  (1,1,30),(1,2,2),(1,3,1), (2,1,100),(2,2,2),(2,3,1), (3,1,NULL),(3,2,NULL),(3,3,NULL);
INSERT INTO billing.plan_features VALUES (1,4), (2,4), (3,1),(3,2),(3,3),(3,4);
INSERT INTO billing.subscription_statuses (id, code, name, allows_writes, is_initial, is_terminal) VALUES
  (1,'TRIAL','Prueba',true,true,false), (2,'ACTIVE','Activa',true,false,false),
  (3,'GRACE','En periodo de gracia',true,false,false), (4,'READ_ONLY','Solo lectura',false,false,false),
  (5,'CANCELLED','Cancelada',false,false,true);
INSERT INTO billing.subscription_status_transitions VALUES
  (1,2),(1,4),(2,3),(3,2),(3,4),(4,2),(1,5),(2,5),(3,5),(4,5);

-- ---------------------------------------------------------------- notificaciones
INSERT INTO notifications.channels (id, code, name, is_enabled) VALUES
  (1,'PUSH','Notificación push',true), (2,'WHATSAPP','WhatsApp',false), (3,'SMS','SMS',false), (4,'EMAIL','Correo',false);
INSERT INTO notifications.notification_types (id, module_id, code, name) VALUES
  (1,4,'PACKAGE_PURCHASED','Compra de tiquetera'), (2,5,'CONSUMPTION_REGISTERED','Consumo registrado'),
  (3,5,'CONSUMPTION_REGISTERED_LATE','Consumo registrado sin internet'), (4,5,'CONSUMPTION_REVERSED','Consumo reversado'),
  (5,4,'RENEWAL_REMINDER','Aviso de renovación'), (6,7,'DAILY_SUMMARY','Resumen diario'),
  (7,9,'SUBSCRIPTION_GRACE','Suscripción en gracia');
INSERT INTO notifications.templates (notification_type_id, channel_id, version, title_template, body_template) VALUES
  (1,1,1,'¡Listo, veci!','{{tenant}} te cargó {{units}} {{unit_plural}}. Ahora tienes {{balance}} disponibles.'),
  (2,1,1,'¡Buen provecho, veci!','{{tenant}} descontó {{units}} {{unit_name}}. Te quedan {{balance}}.'),
  (3,1,1,'Te contamos, veci','{{tenant}} registró tu consumo de {{units}} {{unit_name}} a las {{occurred_time}}. Te llega ahora porque en ese momento no había internet.'),
  (4,1,1,'Corregimos tu saldo','{{tenant}} reversó un consumo de {{units}} {{unit_name}}. Ahora tienes {{balance}}.'),
  (5,1,1,'¡Ojo, veci!','Te quedan {{balance}} {{unit_plural}} en {{tenant}}. Renueva tu tiquetera y sigue tranquilo.'),
  (6,1,1,'Tu día en VECI','Hoy vendiste {{sales_count}} tiqueteras por {{sales_amount}} y se sirvieron {{consumptions}} consumos.'),
  (7,1,1,'Tu plan VECI venció','Tienes {{grace_days_left}} días para renovar. Tus datos siguen seguros con nosotros.');
INSERT INTO notifications.notification_statuses VALUES
  (1,'PENDING','Pendiente',false), (2,'SENT','Enviada',true), (3,'FAILED','Falló',false), (4,'CANCELLED','Cancelada',true);
INSERT INTO notifications.notification_status_transitions VALUES (1,2),(1,3),(3,1),(1,4),(3,4);

-- ---------------------------------------------------------------- cumplimiento y auditoría
INSERT INTO compliance.policy_document_types VALUES
  (1,'DATA_TREATMENT_POLICY','Política de tratamiento de datos'), (2,'TERMS_OF_SERVICE','Términos de uso');
INSERT INTO compliance.consent_channels VALUES
  (1,'SELF_APP','El cliente en la app'), (2,'ASSISTED_BY_CASHIER','Confirmada por el cajero'), (3,'WEB','Web');
INSERT INTO compliance.data_request_types VALUES
  (1,'CONSULTATION','Consulta de datos',10), (2,'CORRECTION','Corrección de datos',15),
  (3,'DELETION','Supresión de datos',15), (4,'CONSENT_REVOCATION','Revocar autorización',15);
INSERT INTO compliance.data_request_statuses (id, code, name, is_initial, is_terminal) VALUES
  (1,'FILED','Radicada',true,false), (2,'IN_PROGRESS','En trámite',false,false),
  (3,'RESOLVED','Resuelta',false,true), (4,'REJECTED','Rechazada',false,true);
INSERT INTO compliance.data_request_status_transitions VALUES (1,2),(2,3),(2,4),(1,4);

INSERT INTO audit.actions (id, module_id, code, name, is_sensitive) VALUES
  (1,1,'LOGIN_LOCKED','Cuenta bloqueada por intentos',true), (2,1,'PIN_RESET','PIN restablecido',true),
  (3,1,'SESSION_REVOKED','Sesión cerrada a distancia',true), (4,2,'TENANT_CREATED','Comercio creado',false),
  (5,2,'MEMBERSHIP_CHANGED','Estado de membresía cambiado',true), (6,2,'ROLE_GRANTED','Rol asignado',true),
  (7,2,'ROLE_REVOKED','Rol retirado',true), (8,3,'CUSTOMER_AFFILIATED','Cliente afiliado',false),
  (9,3,'QR_REVOKED','QR revocado',true), (10,4,'SALE_CREATED','Venta registrada',false),
  (11,4,'SALE_VOIDED','Venta anulada',true), (12,4,'BALANCE_ADJUSTED','Saldo ajustado',true),
  (13,5,'CONSUMPTION_REGISTERED','Consumo registrado',false), (14,5,'CONSUMPTION_REVERSED','Consumo reversado',true),
  (15,5,'EXTRA_CONSUMPTION_AUTHORIZED','Consumo adicional autorizado',true),
  (16,6,'CONFLICT_RESOLVED','Conflicto resuelto',true), (17,2,'SETTING_CHANGED','Configuración cambiada',false),
  (18,9,'SUBSCRIPTION_CHANGED','Suscripción cambiada',false), (19,10,'DATA_REQUEST_RESOLVED','Solicitud de datos resuelta',true),
  (20,10,'PERSON_ANONYMIZED','Datos personales anonimizados',true);
