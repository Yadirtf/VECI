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
