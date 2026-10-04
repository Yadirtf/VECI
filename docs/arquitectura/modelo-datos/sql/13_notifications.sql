-- =============================================================================
-- 13 · notifications: plantillas, tokens push y bandeja de envío
-- =============================================================================

CREATE SCHEMA notifications;

CREATE TABLE notifications.channels (
  id         smallint PRIMARY KEY,
  code       core.catalog_code NOT NULL UNIQUE,
  name       varchar(40) NOT NULL,
  is_enabled boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE notifications.channels IS 'Push (MVP); WhatsApp, SMS y correo a futuro.';

CREATE TABLE notifications.notification_types (
  id          smallint PRIMARY KEY,
  module_id   smallint NOT NULL REFERENCES core.modules (id),
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(120) NOT NULL,
  description text
);

CREATE TABLE notifications.templates (
  id                   uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  notification_type_id smallint NOT NULL REFERENCES notifications.notification_types (id),
  channel_id           smallint NOT NULL REFERENCES notifications.channels (id),
  locale               varchar(10) NOT NULL DEFAULT 'es-CO',
  version              integer NOT NULL CHECK (version > 0),
  title_template       varchar(120),
  body_template        varchar(1000) NOT NULL,
  is_active            boolean NOT NULL DEFAULT true,
  created_at           timestamptz NOT NULL DEFAULT now(),
  UNIQUE (notification_type_id, channel_id, locale, version)
);
COMMENT ON TABLE notifications.templates IS 'Textos con el tono VECI, versionados. Cambiar un texto no requiere desplegar código.';
CREATE UNIQUE INDEX templates_one_active_ux
  ON notifications.templates (notification_type_id, channel_id, locale) WHERE is_active;

CREATE TABLE notifications.notification_statuses (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  is_terminal boolean NOT NULL
);

CREATE TABLE notifications.notification_status_transitions (
  from_status_id smallint NOT NULL REFERENCES notifications.notification_statuses (id),
  to_status_id   smallint NOT NULL REFERENCES notifications.notification_statuses (id),
  PRIMARY KEY (from_status_id, to_status_id),
  CHECK (from_status_id <> to_status_id)
);

CREATE TABLE notifications.push_tokens (
  id            uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  user_id       uuid NOT NULL REFERENCES identity.users (id),
  device_id     uuid NOT NULL REFERENCES identity.devices (id),
  token         varchar(500) NOT NULL,
  registered_at timestamptz NOT NULL DEFAULT now(),
  revoked_at    timestamptz
);
COMMENT ON TABLE notifications.push_tokens IS 'Token de Firebase Cloud Messaging por usuario y dispositivo (HU-09-01).';
CREATE UNIQUE INDEX push_tokens_current_ux ON notifications.push_tokens (token) WHERE revoked_at IS NULL;
CREATE INDEX push_tokens_user_ix ON notifications.push_tokens (user_id) WHERE revoked_at IS NULL;

CREATE TABLE notifications.notifications (
  id                     uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id              uuid REFERENCES tenancy.tenants (id),
  recipient_person_id    uuid NOT NULL REFERENCES identity.people (id),
  notification_type_id   smallint NOT NULL REFERENCES notifications.notification_types (id),
  channel_id             smallint NOT NULL REFERENCES notifications.channels (id),
  template_id            uuid NOT NULL REFERENCES notifications.templates (id),
  source_event_id        uuid REFERENCES ledger.events (id),
  package_id             uuid REFERENCES prepaid.packages (id),
  variables              jsonb NOT NULL DEFAULT '{}'::jsonb,
  notification_status_id smallint NOT NULL REFERENCES notifications.notification_statuses (id),
  status_changed_at      timestamptz NOT NULL DEFAULT now(),
  scheduled_at           timestamptz NOT NULL DEFAULT now(),
  sent_at                timestamptz,
  created_at             timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE notifications.notifications IS 'Bandeja de envío (outbox). variables guarda los datos que llenan la plantilla, p. ej. hora real del consumo (RF-OFF-06).';
CREATE INDEX notifications_dispatch_ix ON notifications.notifications (notification_status_id, scheduled_at);
CREATE INDEX notifications_recipient_ix ON notifications.notifications (recipient_person_id, created_at DESC);
-- El aviso de renovación sale una sola vez por tiquetera y canal (HU-09-03)
CREATE UNIQUE INDEX notifications_once_per_package_ux
  ON notifications.notifications (package_id, notification_type_id, channel_id)
  WHERE package_id IS NOT NULL;

CREATE TABLE notifications.delivery_attempts (
  id                  uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  notification_id     uuid NOT NULL REFERENCES notifications.notifications (id),
  attempted_at        timestamptz NOT NULL DEFAULT now(),
  succeeded           boolean NOT NULL,
  provider_message_id varchar(200),
  error_code          varchar(60),
  error_message       varchar(500)
);
CREATE INDEX delivery_attempts_notification_ix ON notifications.delivery_attempts (notification_id);

CREATE TRIGGER notifications_status BEFORE UPDATE OF notification_status_id ON notifications.notifications
  FOR EACH ROW EXECUTE FUNCTION core.enforce_status_transition('notifications.notification_status_transitions', 'notification_status_id');
