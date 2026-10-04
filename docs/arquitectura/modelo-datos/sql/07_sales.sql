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
