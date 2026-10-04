-- =============================================================================
-- VECI · Modelo de datos de referencia (HU-00-03)
-- 00 · Extensiones, dominios y funciones utilitarias compartidas
-- PostgreSQL 16+. Las migraciones reales (Prisma, HU-01-03) parten de estos archivos.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;    -- gen_random_bytes, digest
CREATE EXTENSION IF NOT EXISTS citext;      -- correos sin distinguir mayúsculas
CREATE EXTENSION IF NOT EXISTS btree_gist;  -- restricciones de exclusión (horarios)
CREATE EXTENSION IF NOT EXISTS pg_trgm;     -- búsqueda de clientes por nombre

CREATE SCHEMA core;

-- -----------------------------------------------------------------------------
-- Dominios: una regla de formato se escribe una sola vez
-- -----------------------------------------------------------------------------
CREATE DOMAIN core.catalog_code AS varchar(40)
  CHECK (VALUE ~ '^[A-Z][A-Z0-9_]*$');

CREATE DOMAIN core.money_amount AS numeric(14, 2)
  CHECK (VALUE >= 0);

-- Rango de horas del día para horarios de servicio (desayuno, almuerzo...)
CREATE TYPE core.time_range AS RANGE (subtype = time);

-- -----------------------------------------------------------------------------
-- UUID v7: ordenado por tiempo, generable en el celular (offline) o en el servidor.
-- PostgreSQL 18 trae uuidv7() nativo; esta función cubre PostgreSQL 16 y 17.
-- -----------------------------------------------------------------------------
CREATE FUNCTION core.uuid_v7() RETURNS uuid
LANGUAGE sql VOLATILE PARALLEL SAFE AS $$
  SELECT encode(
    set_bit(set_bit(
      overlay(uuid_send(gen_random_uuid())
              PLACING substring(int8send((extract(epoch FROM clock_timestamp()) * 1000)::bigint) FROM 3)
              FROM 1 FOR 6),
      52, 1), 53, 1),
    'hex')::uuid;
$$;

-- -----------------------------------------------------------------------------
-- updated_at automático
-- -----------------------------------------------------------------------------
CREATE FUNCTION core.touch_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END $$;

-- -----------------------------------------------------------------------------
-- Versión de sincronización: cada cambio en una tabla que baja al celular
-- recibe un número creciente global. El dispositivo pide "cambios desde N".
-- -----------------------------------------------------------------------------
CREATE SEQUENCE core.sync_version_seq AS bigint;

CREATE FUNCTION core.bump_sync_version() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.sync_version := nextval('core.sync_version_seq');
  RETURN NEW;
END $$;

-- -----------------------------------------------------------------------------
-- Inmutabilidad: libro de movimientos, eventos y auditoría no se editan ni borran
-- -----------------------------------------------------------------------------
CREATE FUNCTION core.forbid_mutation() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'La tabla %.% es inmutable: registre un evento de corrección',
    TG_TABLE_SCHEMA, TG_TABLE_NAME
    USING ERRCODE = 'restrict_violation';
END $$;

-- -----------------------------------------------------------------------------
-- Máquina de estados en datos: valida que el cambio de estado exista en la
-- tabla de transiciones permitidas del catálogo.
--   TG_ARGV[0] = tabla de transiciones (esquema.tabla)
--   TG_ARGV[1] = columna de estado en la tabla vigilada
-- -----------------------------------------------------------------------------
CREATE FUNCTION core.enforce_status_transition() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_old smallint;
  v_new smallint;
  v_ok  boolean;
BEGIN
  EXECUTE format('SELECT ($1).%1$I, ($2).%1$I', TG_ARGV[1])
    INTO v_old, v_new USING OLD, NEW;

  IF v_old IS NOT DISTINCT FROM v_new THEN
    RETURN NEW;
  END IF;

  EXECUTE format(
    'SELECT EXISTS (SELECT 1 FROM %s WHERE from_status_id = $1 AND to_status_id = $2)',
    TG_ARGV[0])
    INTO v_ok USING v_old, v_new;

  IF NOT v_ok THEN
    RAISE EXCEPTION 'Transición de estado no permitida en %.%: % -> %',
      TG_TABLE_SCHEMA, TG_TABLE_NAME, v_old, v_new
      USING ERRCODE = 'check_violation';
  END IF;

  NEW.status_changed_at := now();
  RETURN NEW;
END $$;

-- -----------------------------------------------------------------------------
-- Contexto de la petición (lo fija el guard de NestJS con SET LOCAL)
-- -----------------------------------------------------------------------------
CREATE FUNCTION core.current_tenant_id() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.tenant_id', true), '')::uuid;
$$;

CREATE FUNCTION core.current_person_id() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.person_id', true), '')::uuid;
$$;

-- Usuario de la sesión (EP-02): se fija al iniciar sesión, antes de elegir comercio.
CREATE FUNCTION core.current_user_id() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.user_id', true), '')::uuid;
$$;
