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
