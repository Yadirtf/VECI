-- EP-04 · Clientes y afiliación por QR. Espejo en docs/arquitectura/modelo-datos/sql
-- (02_identity.sql, 15_seguridad_rls.sql, 20_semillas_catalogos.sql y 21_semillas_seguridad_planes.sql).

-- ------------------------------------------- el PIN de bienvenida vence
-- El PIN temporal (invitación, restablecimiento o bienvenida del registro asistido)
-- sirve solo para crear el propio. Si nadie lo usa en una semana, deja de servir.
ALTER TABLE identity.credential_types
  ADD COLUMN temporary_valid_hours smallint CHECK (temporary_valid_hours > 0);
COMMENT ON COLUMN identity.credential_types.temporary_valid_hours IS 'Horas que sirve una credencial temporal (must_change) desde que se emite. NULL = no vence.';
UPDATE identity.credential_types SET temporary_valid_hours = 168 WHERE code = 'PIN';

-- ------------------------------------------- la clave con que el comercio firma sus QR
-- La API crea la clave Ed25519 del comercio la primera vez que afilia a alguien (ADR-0017).
GRANT INSERT ON tenancy.tenant_signing_keys TO veci_app;
-- El cliente ve las claves públicas de sus comercios: su app arma y comprueba su QR.
CREATE POLICY customer_self ON tenancy.tenant_signing_keys FOR SELECT TO veci_app
  USING (tenant_id IN (SELECT a.tenant_id FROM customers.affiliations a
                        WHERE a.person_id = core.current_person_id()));

-- ------------------------------------------- búsqueda global sin exponer datos
-- El documento se enmascara siempre con el mismo largo (****5678): así no se adivina
-- cuántos dígitos tiene. Una persona sin apellido no queda con un punto suelto.
CREATE OR REPLACE FUNCTION customers.find_person_by_document(p_document_type core.catalog_code, p_number varchar)
RETURNS TABLE (person_id uuid, masked_name text, masked_document text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
  SELECT p.id,
         p.given_names || coalesce(' ' || left(p.family_names, 1) || '.', ''),
         '****' || right(p.document_number, 4)
    FROM identity.people p
    JOIN core.document_types dt ON dt.id = p.document_type_id
   WHERE dt.code = p_document_type
     AND p.document_number = p_number;
$$;

-- Afiliación por QR personal (HU-04-03): el cajero ve a quién va a afiliar antes de
-- confirmar, aunque esa persona aún no sea cliente de su negocio. Solo datos enmascarados.
CREATE FUNCTION customers.preview_personal_qr(p_qr_id uuid)
RETURNS TABLE (person_id uuid, masked_name text, masked_document text, version integer, is_current boolean)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
  SELECT p.id,
         p.given_names || coalesce(' ' || left(p.family_names, 1) || '.', ''),
         '****' || right(p.document_number, 4),
         q.version,
         q.revoked_at IS NULL
    FROM customers.personal_qr_codes q
    JOIN identity.people p ON p.id = q.person_id
   WHERE q.id = p_qr_id;
$$;
REVOKE ALL ON FUNCTION customers.preview_personal_qr(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION customers.preview_personal_qr(uuid) TO veci_app;

-- ------------------------------------------- política de datos 1.0
-- El texto vive en la API (clientes/infrastructure/politica); aquí queda su huella.
INSERT INTO compliance.policy_versions (policy_document_type_id, version_label, content_url,
                                        content_sha256, published_at, requires_reacceptance)
SELECT t.id, '1.0', '/politica-de-datos',
       '\x3abcbb2d30940fd5a419b0bbb8d6a3195a15b652abbd49e3474c970d2e9a3347'::bytea,
       '2026-10-01 00:00:00+00', true
  FROM compliance.policy_document_types t
 WHERE t.code = 'DATA_TREATMENT_POLICY';
