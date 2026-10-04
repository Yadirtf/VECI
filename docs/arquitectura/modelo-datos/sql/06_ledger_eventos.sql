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
