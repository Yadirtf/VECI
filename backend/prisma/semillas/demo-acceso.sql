-- =============================================================================
-- VECI · Datos de ejemplo (4 de 4): acceso de las personas demo (EP-02).
-- Todas entran con el PIN 246813; Marta (propietaria) también entra al panel con
-- marta@lavecina.co / almuerzo2026. Un usuario de Soporte VECI para la consola.
-- Es idempotente por fila: sirve también para bases sembradas antes de EP-02.
-- =============================================================================

DO $$
BEGIN
  -- Soporte VECI (rol de plataforma, sin comercio)
  INSERT INTO identity.people (id, document_type_id, document_number, given_names, family_names, person_status_id)
  SELECT 'd3000000-0000-7000-8000-000000000005', dt.id, '1124500005', 'Soporte', 'VECI', ps.id
    FROM core.document_types dt, identity.person_statuses ps
   WHERE dt.code = 'CC' AND ps.code = 'ACTIVE'
  ON CONFLICT DO NOTHING;
  INSERT INTO identity.users (id, person_id, user_status_id, activated_at)
  SELECT 'd4000000-0000-7000-8000-000000000005', 'd3000000-0000-7000-8000-000000000005', us.id, now()
    FROM identity.user_statuses us WHERE us.code = 'ACTIVE'
  ON CONFLICT DO NOTHING;
  INSERT INTO identity.user_login_identifiers (user_id, contact_type_id, value, verified_at)
  SELECT 'd4000000-0000-7000-8000-000000000005', ct.id, '+573100000105', now()
    FROM core.contact_types ct
   WHERE ct.code = 'MOBILE_PHONE'
     AND NOT EXISTS (SELECT 1 FROM identity.user_login_identifiers
                      WHERE user_id = 'd4000000-0000-7000-8000-000000000005');
  INSERT INTO identity.user_platform_roles (user_id, role_id)
  SELECT 'd4000000-0000-7000-8000-000000000005', r.id FROM identity.roles r
   WHERE r.code = 'VECI_SUPPORT'
     AND NOT EXISTS (SELECT 1 FROM identity.user_platform_roles
                      WHERE user_id = 'd4000000-0000-7000-8000-000000000005' AND revoked_at IS NULL);

  -- PIN 246813 (Argon2id) para todas las personas demo que aún no tienen PIN
  INSERT INTO identity.user_credentials (user_id, credential_type_id, secret_hash)
  SELECT u.id, ct.id,
         '$argon2id$v=19$m=19456,t=2,p=1$G6zIlHZQtS7Qo3bvREVcOg$O9bifPXg8M4Arlb8Nw8Hj///roXSsmkYF6koKBQcn7Y'
    FROM identity.users u, identity.credential_types ct
   WHERE u.id::text LIKE 'd4000000-%' AND ct.code = 'PIN'
     AND NOT EXISTS (SELECT 1 FROM identity.user_credentials uc
                      WHERE uc.user_id = u.id AND uc.credential_type_id = ct.id);

  -- Correo y contraseña de Marta para el panel (HU-02-02)
  INSERT INTO identity.user_login_identifiers (user_id, contact_type_id, value, verified_at)
  SELECT 'd4000000-0000-7000-8000-000000000001', ct.id, 'marta@lavecina.co', now()
    FROM core.contact_types ct
   WHERE ct.code = 'EMAIL'
     AND NOT EXISTS (SELECT 1 FROM identity.user_login_identifiers WHERE value = 'marta@lavecina.co');
  INSERT INTO identity.user_credentials (user_id, credential_type_id, secret_hash)
  SELECT 'd4000000-0000-7000-8000-000000000001', ct.id,
         '$argon2id$v=19$m=19456,t=2,p=1$wHKYOuS/pY8xq7l6WxESnw$ZDfWwMEcBFO54qYrQjkG6jHgfeHrrgrijgfTyhaToFc'
    FROM identity.credential_types ct
   WHERE ct.code = 'PASSWORD'
     AND NOT EXISTS (SELECT 1 FROM identity.user_credentials uc
                      WHERE uc.user_id = 'd4000000-0000-7000-8000-000000000001'
                        AND uc.credential_type_id = ct.id);
END $$;
