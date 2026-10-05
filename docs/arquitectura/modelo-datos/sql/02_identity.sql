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
  is_active      boolean NOT NULL DEFAULT true,
  temporary_valid_hours smallint CHECK (temporary_valid_hours > 0)
);
COMMENT ON TABLE identity.credential_types IS 'PIN de 6 dígitos, contraseña; a futuro OTP. Las reglas de bloqueo viven aquí, no en código.';
COMMENT ON COLUMN identity.credential_types.temporary_valid_hours IS 'Horas que sirve una credencial temporal (must_change) desde que se emite. NULL = no vence.';

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
