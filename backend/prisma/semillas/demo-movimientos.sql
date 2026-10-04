-- =============================================================================
-- VECI · Datos de ejemplo (3 de 3): la clienta compra una tiquetera y almuerza.
-- El saldo no se escribe: lo calcula el trigger desde los movimientos (ADR-0003).
-- =============================================================================

DO $$
DECLARE
  a constant uuid := 'd1000000-0000-7000-8000-000000000001';
  afiliacion constant uuid := 'd8000000-0000-7000-8000-000000000001';
  venta constant uuid := 'd9000000-0000-7000-8000-000000000001';
  consumo constant uuid := 'd9000000-0000-7000-8000-000000000002';
  tiquetera constant uuid := 'da000000-0000-7000-8000-000000000001';
BEGIN
  IF EXISTS (SELECT 1 FROM customers.affiliations WHERE id = afiliacion) THEN
    RETURN;
  END IF;
  PERFORM set_config('app.tenant_id', a::text, true);

  INSERT INTO customers.affiliations (id, tenant_id, person_id, affiliation_status_id, affiliation_channel_id, branch_id, affiliated_by_membership_id)
  SELECT afiliacion, a, 'd3000000-0000-7000-8000-000000000003', st.id, ch.id,
         'd2000000-0000-7000-8000-000000000001', 'd5000000-0000-7000-8000-000000000002'
    FROM customers.affiliation_statuses st, customers.affiliation_channels ch
   WHERE st.code = 'ACTIVE' AND ch.code = 'PERSONAL_QR_SCAN';

  INSERT INTO ledger.events (id, tenant_id, event_type_id, event_origin_id, affiliation_id, branch_id, actor_membership_id, occurred_at)
  SELECT venta, a, et.id, eo.id, afiliacion, 'd2000000-0000-7000-8000-000000000001',
         'd5000000-0000-7000-8000-000000000002', now() - interval '1 day'
    FROM ledger.event_types et, ledger.event_origins eo WHERE et.code = 'SALE' AND eo.code = 'ONLINE';
  INSERT INTO sales.sales (event_id, tenant_id, sale_status_id)
  SELECT venta, a, s.id FROM sales.sale_statuses s WHERE s.code = 'COMPLETED';
  INSERT INTO sales.sale_items (id, tenant_id, sale_id, line_number, package_type_id, quantity, unit_price)
  VALUES ('db000000-0000-7000-8000-000000000001', a, venta, 1, 'd7000000-0000-7000-8000-000000000001', 1, 220000);
  INSERT INTO sales.sale_payments (tenant_id, sale_id, payment_method_id, payment_channel_id, amount, reference)
  SELECT a, venta, pm.id, pc.id, 220000, 'NEQUI-DEMO-001'
    FROM core.payment_methods pm JOIN core.payment_channels pc ON pc.payment_method_id = pm.id
   WHERE pm.code = 'BANK_TRANSFER' AND pc.code = 'NEQUI';
  INSERT INTO prepaid.packages (id, tenant_id, affiliation_id, package_type_id, sale_item_id, starts_at, expires_at, package_status_id)
  SELECT tiquetera, a, afiliacion, 'd7000000-0000-7000-8000-000000000001', 'db000000-0000-7000-8000-000000000001',
         now() - interval '1 day', now() + interval '29 days', ps.id
    FROM prepaid.package_statuses ps WHERE ps.code = 'ACTIVE';
  INSERT INTO ledger.movements (tenant_id, event_id, package_id, units_delta) VALUES (a, venta, tiquetera, 20);

  INSERT INTO ledger.events (id, tenant_id, event_type_id, event_origin_id, affiliation_id, branch_id, actor_membership_id, occurred_at)
  SELECT consumo, a, et.id, eo.id, afiliacion, 'd2000000-0000-7000-8000-000000000001',
         'd5000000-0000-7000-8000-000000000002', now() - interval '2 hours'
    FROM ledger.event_types et, ledger.event_origins eo WHERE et.code = 'CONSUMPTION' AND eo.code = 'ONLINE';
  INSERT INTO consumptions.consumptions (event_id, tenant_id, capture_method_id, service_id, business_date, units_requested)
  SELECT consumo, a, cm.id, 'd6000000-0000-7000-8000-000000000002', current_date, 1
    FROM consumptions.capture_methods cm WHERE cm.code = 'MANUAL_SEARCH';
  INSERT INTO ledger.movements (tenant_id, event_id, package_id, units_delta) VALUES (a, consumo, tiquetera, -1);
END $$;
