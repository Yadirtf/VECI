-- =============================================================================
-- VECI · Roles de conexión (HU-01-05). Se ejecuta una vez por base de datos,
-- antes o después de las migraciones, con un usuario que pueda crear roles.
--   psql "$DATABASE_URL" -v clave_api='...' -f infra/postgres/crear-roles.sql
-- veci_app (sin BYPASSRLS) agrupa los permisos que da la migración; veci_api es
-- el usuario con el que se conecta la API (DATABASE_APP_URL) y hereda de veci_app.
-- =============================================================================

SELECT 'CREATE ROLE veci_app NOLOGIN NOBYPASSRLS'
 WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'veci_app') \gexec

SELECT format('CREATE ROLE veci_api LOGIN NOBYPASSRLS PASSWORD %L IN ROLE veci_app', :'clave_api')
 WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'veci_api') \gexec

SELECT format('ALTER ROLE veci_api PASSWORD %L', :'clave_api') \gexec
