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
