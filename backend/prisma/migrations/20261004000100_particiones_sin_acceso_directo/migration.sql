-- HU-01-05: veci_app no puede leer particiones por su nombre (saltaría RLS).
-- Mismo bloque que docs/arquitectura/modelo-datos/sql/15_seguridad_rls.sql.

-- ------------------------------------------- particiones sin acceso directo
-- Las tablas particionadas aplican RLS en la tabla madre; leer una partición por
-- su nombre saltaría las políticas. veci_app solo entra por la tabla madre.
-- Quien cree particiones nuevas (proceso mensual) debe repetir este REVOKE.
DO $$
DECLARE
  p record;
BEGIN
  FOR p IN SELECT n.nspname, c.relname
             FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE c.relispartition AND c.relkind IN ('r', 'p')
  LOOP
    EXECUTE format('REVOKE ALL ON %I.%I FROM veci_app', p.nspname, p.relname);
  END LOOP;
END $$;
