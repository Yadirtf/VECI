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
