-- EP-05 · Tiqueteras y ventas. Espejo en docs/arquitectura/modelo-datos/sql
-- (09_ledger_movimientos.sql y 15_seguridad_rls.sql).

-- ------------------------------------------- la caché y el estado se mueven juntos
-- Una tiquetera activa que queda en cero (o menos, por un choque offline) pasa a
-- agotada, y una agotada que recibe unidades (reverso o ajuste) vuelve a activa.
-- Vencida y anulada no se tocan: esas las decide la venta, la anulación o el vencimiento.
CREATE OR REPLACE FUNCTION ledger.apply_movement() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_effect smallint;
BEGIN
  SELECT et.balance_effect INTO v_effect
    FROM ledger.events e
    JOIN ledger.event_types et ON et.id = e.event_type_id
   WHERE e.id = NEW.event_id;

  IF v_effect <> 0 AND sign(NEW.units_delta) <> v_effect THEN
    RAISE EXCEPTION 'El signo del movimiento (%) no corresponde al tipo de evento', NEW.units_delta
      USING ERRCODE = 'check_violation';
  END IF;

  UPDATE prepaid.packages
     SET units_balance = units_balance + NEW.units_delta,
         balance_updated_at = now()
   WHERE id = NEW.package_id
     AND tenant_id = NEW.tenant_id
  RETURNING units_balance INTO NEW.balance_after;

  UPDATE prepaid.packages p
     SET package_status_id = destino.id,
         status_changed_at = now()
    FROM prepaid.package_statuses actual, prepaid.package_statuses destino
   WHERE p.id = NEW.package_id
     AND p.tenant_id = NEW.tenant_id
     AND actual.id = p.package_status_id
     AND ((actual.code = 'ACTIVE' AND NEW.balance_after <= 0 AND destino.code = 'DEPLETED')
       OR (actual.code = 'DEPLETED' AND NEW.balance_after > 0 AND destino.code = 'ACTIVE'));

  RETURN NEW;
END $$;

-- ------------------------------------------- vencimiento automático (HU-05-04)
-- El proceso recorre los comercios uno por uno con su contexto (RLS). Para saber
-- cuáles tienen tiqueteras activas ya vencidas solo recibe sus ids.
CREATE FUNCTION prepaid.tenants_with_due_packages(p_as_of timestamptz)
RETURNS SETOF uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
  SELECT DISTINCT p.tenant_id
    FROM prepaid.packages p
    JOIN prepaid.package_statuses s ON s.id = p.package_status_id
   WHERE s.code = 'ACTIVE'
     AND p.expires_at <= p_as_of;
$$;
REVOKE ALL ON FUNCTION prepaid.tenants_with_due_packages(timestamptz) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION prepaid.tenants_with_due_packages(timestamptz) TO veci_app;
