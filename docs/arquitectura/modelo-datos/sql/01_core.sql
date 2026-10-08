-- =============================================================================
-- 01 · core: catálogos compartidos por todos los módulos
-- Catálogo = tabla con id smallint estable (sembrado por migración) y code único.
-- El código de la aplicación se refiere a los registros por su code, nunca por id.
-- =============================================================================

CREATE TABLE core.modules (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  description text,
  is_active   boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE core.modules IS 'Módulos funcionales del backend (auth, tiqueteras...). Agrupa permisos y acciones de auditoría.';

CREATE TABLE core.currencies (
  code        char(3) PRIMARY KEY CHECK (code ~ '^[A-Z]{3}$'),
  name        varchar(60) NOT NULL,
  minor_units smallint NOT NULL CHECK (minor_units BETWEEN 0 AND 4)
);
COMMENT ON TABLE core.currencies IS 'Monedas ISO 4217. COP en el MVP.';

CREATE TABLE core.countries (
  id           smallint PRIMARY KEY,
  iso2         char(2) NOT NULL UNIQUE,
  name         varchar(80) NOT NULL,
  phone_prefix varchar(5) NOT NULL
);

CREATE TABLE core.departments (
  id            smallint PRIMARY KEY,
  country_id    smallint NOT NULL REFERENCES core.countries (id),
  official_code varchar(10) NOT NULL,
  name          varchar(80) NOT NULL,
  UNIQUE (country_id, official_code)
);
COMMENT ON TABLE core.departments IS 'Departamentos (código DIVIPOLA en Colombia).';

CREATE TABLE core.municipalities (
  id            integer PRIMARY KEY,
  department_id smallint NOT NULL REFERENCES core.departments (id),
  official_code varchar(10) NOT NULL UNIQUE,
  name          varchar(80) NOT NULL,
  is_served     boolean NOT NULL DEFAULT false
);
COMMENT ON TABLE core.municipalities IS 'Municipios (DIVIPOLA). Base de la expansión a Puerto Asís, Sibundoy, etc.';
COMMENT ON COLUMN core.municipalities.is_served IS 'VECI recibe solicitudes de negocios de este municipio (cobertura).';

CREATE TABLE core.holidays (
  country_id   smallint NOT NULL REFERENCES core.countries (id),
  holiday_date date NOT NULL,
  name         varchar(80) NOT NULL,
  PRIMARY KEY (country_id, holiday_date)
);
COMMENT ON TABLE core.holidays IS 'Festivos por país. Sirve para calcular plazos en días hábiles (Ley 1581).';

CREATE TABLE core.document_types (
  id                 smallint PRIMARY KEY,
  code               core.catalog_code NOT NULL UNIQUE,
  name               varchar(80) NOT NULL,
  country_id         smallint NOT NULL REFERENCES core.countries (id),
  for_natural_person boolean NOT NULL,
  for_legal_entity   boolean NOT NULL,
  validation_regex   varchar(120),
  sort_order         smallint NOT NULL DEFAULT 0,
  is_active          boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE core.document_types IS 'Tipos de documento: CC, TI, CE, PPT, pasaporte, NIT.';

CREATE TABLE core.contact_types (
  id               smallint PRIMARY KEY,
  code             core.catalog_code NOT NULL UNIQUE,
  name             varchar(80) NOT NULL,
  can_login        boolean NOT NULL,
  validation_regex varchar(120),
  is_active        boolean NOT NULL DEFAULT true,
  UNIQUE (id, can_login)
);
COMMENT ON TABLE core.contact_types IS 'Celular, correo, WhatsApp, fijo. can_login marca los que sirven para iniciar sesión.';

CREATE TABLE core.weekdays (
  id   smallint PRIMARY KEY CHECK (id BETWEEN 1 AND 7),
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(20) NOT NULL
);
COMMENT ON TABLE core.weekdays IS 'Días de la semana ISO 8601 (1 = lunes).';

CREATE TABLE core.data_types (
  id   smallint PRIMARY KEY,
  code core.catalog_code NOT NULL UNIQUE,
  name varchar(40) NOT NULL
);
COMMENT ON TABLE core.data_types IS 'Tipos de dato de las configuraciones (entero, booleano, hora, texto, decimal).';

CREATE TABLE core.payment_methods (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  needs_channel boolean NOT NULL,
  sort_order  smallint NOT NULL DEFAULT 0,
  is_active   boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE core.payment_methods IS 'Medio de pago: efectivo, transferencia, pasarela (futuro).';

CREATE TABLE core.payment_channels (
  id                smallint PRIMARY KEY,
  payment_method_id smallint NOT NULL REFERENCES core.payment_methods (id),
  code              core.catalog_code NOT NULL UNIQUE,
  name              varchar(80) NOT NULL,
  sort_order        smallint NOT NULL DEFAULT 0,
  is_active         boolean NOT NULL DEFAULT true,
  UNIQUE (id, payment_method_id)
);
COMMENT ON TABLE core.payment_channels IS 'Canal dentro de un medio: Nequi, Daviplata, Bancolombia (transferencia); Wompi (pasarela).';

CREATE TABLE core.qr_revocation_reasons (
  id          smallint PRIMARY KEY,
  code        core.catalog_code NOT NULL UNIQUE,
  name        varchar(80) NOT NULL,
  is_active   boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE core.qr_revocation_reasons IS 'Motivos para revocar un QR (perdido, regenerado, compartido, afiliación terminada).';
