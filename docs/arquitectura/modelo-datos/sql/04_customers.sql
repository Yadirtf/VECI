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
