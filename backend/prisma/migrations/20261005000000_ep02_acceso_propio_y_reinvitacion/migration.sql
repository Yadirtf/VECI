-- EP-02 · Autenticación y roles. Espejo en docs/arquitectura/modelo-datos/sql
-- (00_extensiones_y_utilidades.sql, 15_seguridad_rls.sql y 20_semillas_catalogos.sql).

-- Usuario de la sesión: la API lo fija con SET LOCAL app.user_id al iniciar sesión,
-- antes de que exista un comercio activo (HU-02-01, HU-02-03).
CREATE FUNCTION core.current_user_id() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.user_id', true), '')::uuid;
$$;

-- ------------------------------------------- el personal ve sus propios lugares de trabajo
-- Para elegir el comercio activo (HU-02-03), el usuario lee solo sus membresías,
-- sus roles y el nombre de esos comercios. Nunca escribe con este contexto.
CREATE POLICY staff_self ON tenancy.memberships FOR SELECT TO veci_app
  USING (user_id = core.current_user_id());
CREATE POLICY staff_self ON tenancy.membership_roles FOR SELECT TO veci_app
  USING (membership_id IN (SELECT m.id FROM tenancy.memberships m
                            WHERE m.user_id = core.current_user_id()));
CREATE POLICY staff_reads_my_tenants ON tenancy.tenants FOR SELECT TO veci_app
  USING (id IN (SELECT m.tenant_id FROM tenancy.memberships m
                 WHERE m.user_id = core.current_user_id()));

-- ------------------------------------------- volver a invitar a un cajero retirado
-- Un restaurante que recontrata a su cajero lo invita de nuevo (HU-02-04): la
-- membresía pasa de Retirado a Invitado y la historia de roles se conserva.
UPDATE tenancy.membership_statuses SET is_terminal = false WHERE code = 'REMOVED';
INSERT INTO tenancy.membership_status_transitions (from_status_id, to_status_id)
SELECT r.id, i.id
  FROM tenancy.membership_statuses r, tenancy.membership_statuses i
 WHERE r.code = 'REMOVED' AND i.code = 'INVITED';
