-- =============================================================================
-- VECI · Comprobaciones después de restaurar una copia (HU-01-08).
-- Se corre con un superusuario sobre la base restaurada; falla si algo no cuadra.
-- =============================================================================
\set ON_ERROR_STOP on

SELECT 'Migraciones aplicadas' AS comprobacion, count(*)::text AS valor
  FROM public._prisma_migrations WHERE finished_at IS NOT NULL
UNION ALL
SELECT 'Comercios', count(*)::text FROM tenancy.tenants
UNION ALL
SELECT 'Clientes afiliados', count(*)::text FROM customers.affiliations
UNION ALL
SELECT 'Tiqueteras', count(*)::text FROM prepaid.packages
UNION ALL
SELECT 'Movimientos del libro', count(*)::text FROM ledger.movements
UNION ALL
SELECT 'Tablas con RLS forzado', count(*)::text
  FROM pg_class WHERE relrowsecurity AND relforcerowsecurity;

DO $$
DECLARE
  descuadradas integer;
  sin_rls integer;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public._prisma_migrations WHERE finished_at IS NOT NULL) THEN
    RAISE EXCEPTION 'La copia no tiene migraciones aplicadas';
  END IF;

  -- El saldo en caché debe ser la suma del libro en todas las tiqueteras.
  SELECT count(*) INTO descuadradas FROM prepaid.v_package_balance_check WHERE NOT is_consistent;
  IF descuadradas > 0 THEN
    RAISE EXCEPTION '% tiquetera(s) con saldo distinto al libro', descuadradas;
  END IF;

  -- Toda tabla con tenant_id conserva su aislamiento por comercio.
  SELECT count(*) INTO sin_rls
    FROM information_schema.columns c
    JOIN pg_class t ON t.relname = c.table_name
    JOIN pg_namespace n ON n.oid = t.relnamespace AND n.nspname = c.table_schema
   WHERE c.column_name = 'tenant_id' AND t.relkind IN ('r', 'p') AND NOT t.relispartition
     AND NOT (t.relrowsecurity AND t.relforcerowsecurity);
  IF sin_rls > 0 THEN
    RAISE EXCEPTION '% tabla(s) con tenant_id sin RLS forzado', sin_rls;
  END IF;

  RAISE NOTICE 'Restauración verificada: estructura, saldos y RLS en orden';
END $$;
