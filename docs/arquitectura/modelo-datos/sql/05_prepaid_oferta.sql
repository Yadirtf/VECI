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
