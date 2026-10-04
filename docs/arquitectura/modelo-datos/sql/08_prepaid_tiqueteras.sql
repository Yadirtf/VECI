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
