-- =============================================================================
-- VECI · Datos de ejemplo (1 de 4) para desarrollo y staging (HU-01-03). Nunca en producción.
-- Dos comercios (restaurante y panadería) para probar el aislamiento, un cajero,
-- una clienta con su tiquetera vendida y un consumo. Se ejecuta una sola vez:
-- si el comercio demo ya existe, no hace nada.
-- Los catálogos se buscan por code, nunca por id (ADR-0006).
-- =============================================================================

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM tenancy.tenants WHERE slug = 'la-vecina') THEN
    RAISE NOTICE 'Los datos de ejemplo ya existen; no se hace nada.';
    RETURN;
  END IF;

  -- --------------------------------------------------------------- personas
  INSERT INTO identity.people (id, document_type_id, document_number, given_names, family_names, person_status_id)
  SELECT v.id::uuid, dt.id, v.doc, v.nombres, v.apellidos, ps.id
    FROM (VALUES
      ('d3000000-0000-7000-8000-000000000001','1124500001','Marta','Jojoa'),
      ('d3000000-0000-7000-8000-000000000002','1124500002','Jhon','Mutumbajoy'),
      ('d3000000-0000-7000-8000-000000000003','1124500003','Luz Marina','Chindoy'),
      ('d3000000-0000-7000-8000-000000000004','1124500004','Carlos','Benavides')
    ) AS v (id, doc, nombres, apellidos)
    JOIN core.document_types dt ON dt.code = 'CC'
    JOIN identity.person_statuses ps ON ps.code = 'ACTIVE';

  INSERT INTO identity.users (id, person_id, user_status_id, activated_at)
  SELECT ('d4' || substr(p.id::text, 3))::uuid, p.id, us.id, now()
    FROM identity.people p
    JOIN identity.user_statuses us ON us.code = 'ACTIVE'
   WHERE p.id::text LIKE 'd3000000-%';

  INSERT INTO identity.user_login_identifiers (user_id, contact_type_id, value, verified_at)
  SELECT v.user_id::uuid, ct.id, v.celular, now()
    FROM (VALUES
      ('d4000000-0000-7000-8000-000000000001','+573100000101'),
      ('d4000000-0000-7000-8000-000000000002','+573100000102'),
      ('d4000000-0000-7000-8000-000000000003','+573100000103'),
      ('d4000000-0000-7000-8000-000000000004','+573100000104')
    ) AS v (user_id, celular)
    JOIN core.contact_types ct ON ct.code = 'MOBILE_PHONE';
END $$;
