-- =============================================================================
-- 90 · Prueba de humo del modelo: flujo completo y reglas que la base garantiza
-- Se ejecuta con validar.sh sobre una base desechable. Falla al primer error.
-- =============================================================================

-- Ejecuta una sentencia que DEBE fallar; si no falla, la prueba se detiene.
CREATE FUNCTION pg_temp.expect_error(p_label text, p_sql text) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  BEGIN
    EXECUTE p_sql;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'OK (rechazado como se esperaba): % → %', p_label, SQLERRM;
    RETURN;
  END;
  RAISE EXCEPTION 'FALLO: se esperaba un error en "%"', p_label;
END $$;

CREATE FUNCTION pg_temp.expect(p_label text, p_ok boolean) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  IF p_ok IS NOT TRUE THEN
    RAISE EXCEPTION 'FALLO: %', p_label;
  END IF;
  RAISE NOTICE 'OK: %', p_label;
END $$;
GRANT EXECUTE ON FUNCTION pg_temp.expect_error(text, text), pg_temp.expect(text, boolean) TO veci_app;

-- ------------------------------------------------- 1. Alta de plataforma (consola VECI)
INSERT INTO identity.people (id, document_type_id, document_number, given_names, family_names, person_status_id) VALUES
  ('30000000-0000-7000-8000-000000000001',1,'1124000001','Rosa','Muñoz',1),
  ('30000000-0000-7000-8000-000000000002',1,'1124000002','Andrés','Jojoa',1);
INSERT INTO identity.users (id, person_id, user_status_id) VALUES
  ('40000000-0000-7000-8000-000000000001','30000000-0000-7000-8000-000000000001',2),
  ('40000000-0000-7000-8000-000000000002','30000000-0000-7000-8000-000000000002',2);
INSERT INTO identity.user_login_identifiers (user_id, contact_type_id, value) VALUES
  ('40000000-0000-7000-8000-000000000001',1,'+573100000001'),
  ('40000000-0000-7000-8000-000000000002',1,'+573100000002');
INSERT INTO identity.user_credentials (user_id, credential_type_id, secret_hash) VALUES
  ('40000000-0000-7000-8000-000000000001',1,'$argon2id$v=19$demo');
INSERT INTO identity.devices (id, device_platform_id, model) VALUES
  ('70000000-0000-7000-8000-000000000001',1,'Moto E13');

INSERT INTO tenancy.tenants (id, slug, display_name, document_type_id, document_number, business_type_id, tenant_status_id) VALUES
  ('10000000-0000-7000-8000-00000000000a','donde-rosa','Restaurante Donde Rosa',1,'1124000001',1,2),
  ('10000000-0000-7000-8000-00000000000b','cafe-sibundoy','Café Sibundoy',7,'900123456',2,2);
INSERT INTO tenancy.branches (id, tenant_id, name, is_main, branch_status_id, municipality_id) VALUES
  ('20000000-0000-7000-8000-00000000000a','10000000-0000-7000-8000-00000000000a','Principal',true,1,86001),
  ('20000000-0000-7000-8000-00000000000b','10000000-0000-7000-8000-00000000000b','Principal',true,1,86749);
INSERT INTO tenancy.memberships (id, tenant_id, user_id, membership_status_id) VALUES
  ('50000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a','40000000-0000-7000-8000-000000000001',2),
  ('50000000-0000-7000-8000-000000000002','10000000-0000-7000-8000-00000000000a','40000000-0000-7000-8000-000000000002',2);
INSERT INTO tenancy.membership_roles (tenant_id, membership_id, role_id) VALUES
  ('10000000-0000-7000-8000-00000000000a','50000000-0000-7000-8000-000000000001',3),
  ('10000000-0000-7000-8000-00000000000a','50000000-0000-7000-8000-000000000002',4);
INSERT INTO tenancy.tenant_signing_keys (id, tenant_id, key_id, public_key, private_key_ref) VALUES
  ('60000000-0000-7000-8000-00000000000a','10000000-0000-7000-8000-00000000000a','k1','\x00','secret://veci/tenants/a/k1');
INSERT INTO billing.subscriptions (tenant_id, plan_id, subscription_status_id, current_period_ends_at) VALUES
  ('10000000-0000-7000-8000-00000000000a',1,1, now() + interval '30 days');

SELECT pg_temp.expect_error('rol de plataforma asignado a una membresía',
  $$INSERT INTO tenancy.membership_roles (tenant_id, membership_id, role_id)
    VALUES ('10000000-0000-7000-8000-00000000000a','50000000-0000-7000-8000-000000000002',1)$$);
SELECT pg_temp.expect_error('celular duplicado para iniciar sesión',
  $$INSERT INTO identity.user_login_identifiers (user_id, contact_type_id, value)
    VALUES ('40000000-0000-7000-8000-000000000002',1,'+573100000001')$$);
SELECT pg_temp.expect_error('WhatsApp no sirve para iniciar sesión',
  $$INSERT INTO identity.user_login_identifiers (user_id, contact_type_id, value)
    VALUES ('40000000-0000-7000-8000-000000000002',3,'+573100000009')$$);
SELECT pg_temp.expect_error('transición de membresía no permitida (retirado -> activo)',
  $$UPDATE tenancy.memberships SET membership_status_id = 4 WHERE id = '50000000-0000-7000-8000-000000000002';
    UPDATE tenancy.memberships SET membership_status_id = 2 WHERE id = '50000000-0000-7000-8000-000000000002'$$);

-- ------------------------------------------------- 2. Operación del cajero (con RLS)
SET ROLE veci_app;
SET app.tenant_id = '10000000-0000-7000-8000-00000000000a';

-- Registro asistido de un cliente (HU-04-04) y afiliación
INSERT INTO identity.people (id, document_type_id, document_number, given_names, family_names, person_status_id)
VALUES ('30000000-0000-7000-8000-000000000003',1,'1124000003','Luz Marina','Chindoy',1);
INSERT INTO customers.affiliations (id, tenant_id, person_id, affiliation_status_id, affiliation_channel_id, branch_id, affiliated_by_membership_id)
VALUES ('80000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a','30000000-0000-7000-8000-000000000003',1,2,
        '20000000-0000-7000-8000-00000000000a','50000000-0000-7000-8000-000000000002');
INSERT INTO identity.person_contacts (person_id, contact_type_id, value, is_primary)
VALUES ('30000000-0000-7000-8000-000000000003',1,'+573100000003',true);
INSERT INTO customers.affiliation_qr_codes (id, tenant_id, affiliation_id, version, signing_key_id)
VALUES ('81000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a','80000000-0000-7000-8000-000000000001',1,
        '60000000-0000-7000-8000-00000000000a');

-- Oferta, servicio y horario
INSERT INTO prepaid.package_types (id, tenant_id, name, consumption_unit_id, units_quantity, price_amount, validity_days, package_type_status_id)
SELECT '90000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a','Tiquetera 30 almuerzos', u.id, 30, 330000, 45, 1
  FROM prepaid.consumption_units u WHERE u.tenant_id IS NULL AND u.code = 'LUNCH';
INSERT INTO tenancy.services (id, tenant_id, name) VALUES
  ('a1000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a','Almuerzo');
INSERT INTO tenancy.service_schedules (id, tenant_id, service_id, branch_id, weekday_id, hours) VALUES
  ('a2000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a','a1000000-0000-7000-8000-000000000001',
   '20000000-0000-7000-8000-00000000000a',1,'[11:30,15:00)');
SELECT pg_temp.expect_error('horario que se solapa el mismo día y sede',
  $$INSERT INTO tenancy.service_schedules (tenant_id, service_id, branch_id, weekday_id, hours)
    VALUES ('10000000-0000-7000-8000-00000000000a','a1000000-0000-7000-8000-000000000001',
            '20000000-0000-7000-8000-00000000000a',1,'[14:00,16:00)')$$);

-- Venta offline sincronizada: evento + venta + línea + pago + tiquetera + movimiento
INSERT INTO ledger.events (id, tenant_id, event_type_id, event_origin_id, affiliation_id, branch_id, actor_membership_id, device_id, occurred_at)
VALUES ('b0000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a',1,2,'80000000-0000-7000-8000-000000000001',
        '20000000-0000-7000-8000-00000000000a','50000000-0000-7000-8000-000000000002','70000000-0000-7000-8000-000000000001', now() - interval '2 hours');
INSERT INTO sales.sales (event_id, tenant_id, sale_status_id) VALUES
  ('b0000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a',1);
INSERT INTO sales.sale_items (id, tenant_id, sale_id, line_number, package_type_id, quantity, unit_price) VALUES
  ('b1000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a','b0000000-0000-7000-8000-000000000001',1,
   '90000000-0000-7000-8000-000000000001',1,330000);
INSERT INTO sales.sale_payments (tenant_id, sale_id, payment_method_id, payment_channel_id, amount, reference) VALUES
  ('10000000-0000-7000-8000-00000000000a','b0000000-0000-7000-8000-000000000001',2,1,330000,'M12345');
INSERT INTO prepaid.packages (id, tenant_id, affiliation_id, package_type_id, sale_item_id, starts_at, expires_at, package_status_id)
VALUES ('b2000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a','80000000-0000-7000-8000-000000000001',
        '90000000-0000-7000-8000-000000000001','b1000000-0000-7000-8000-000000000001', now() - interval '2 hours', now() + interval '45 days', 1);
INSERT INTO ledger.movements (tenant_id, event_id, package_id, units_delta) VALUES
  ('10000000-0000-7000-8000-00000000000a','b0000000-0000-7000-8000-000000000001','b2000000-0000-7000-8000-000000000001',30);

SELECT pg_temp.expect_error('pago con Nequi registrado como efectivo',
  $$INSERT INTO sales.sale_payments (tenant_id, sale_id, payment_method_id, payment_channel_id, amount)
    VALUES ('10000000-0000-7000-8000-00000000000a','b0000000-0000-7000-8000-000000000001',1,1,1000)$$);

-- Consumo por escaneo de QR
INSERT INTO ledger.events (id, tenant_id, event_type_id, event_origin_id, affiliation_id, branch_id, actor_membership_id, device_id, occurred_at)
VALUES ('c0000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a',2,1,'80000000-0000-7000-8000-000000000001',
        '20000000-0000-7000-8000-00000000000a','50000000-0000-7000-8000-000000000002','70000000-0000-7000-8000-000000000001', now());
INSERT INTO consumptions.consumptions (event_id, tenant_id, capture_method_id, service_id, service_schedule_id, business_date, units_requested, affiliation_qr_code_id)
VALUES ('c0000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a',1,'a1000000-0000-7000-8000-000000000001',
        'a2000000-0000-7000-8000-000000000001', current_date, 1,'81000000-0000-7000-8000-000000000001');
INSERT INTO ledger.movements (tenant_id, event_id, package_id, units_delta) VALUES
  ('10000000-0000-7000-8000-00000000000a','c0000000-0000-7000-8000-000000000001','b2000000-0000-7000-8000-000000000001',-1);

SELECT pg_temp.expect('saldo en caché = 29 tras vender 30 y consumir 1',
  (SELECT units_balance FROM prepaid.packages WHERE id = 'b2000000-0000-7000-8000-000000000001') = 29);
SELECT pg_temp.expect('balance_after del consumo = 29',
  (SELECT balance_after FROM ledger.movements WHERE event_id = 'c0000000-0000-7000-8000-000000000001') = 29);
SELECT pg_temp.expect('vista de saldo del cliente = 29',
  (SELECT available_units FROM customers.v_affiliation_balances WHERE affiliation_id = '80000000-0000-7000-8000-000000000001') = 29);
SELECT pg_temp.expect('dinero comprometido = 29 × 11.000 = 319.000',
  (SELECT pending_amount FROM prepaid.v_committed_liability) = 319000);

SELECT pg_temp.expect_error('reintento del mismo evento (idempotencia por PK)',
  $$INSERT INTO ledger.events (id, tenant_id, event_type_id, event_origin_id, affiliation_id, occurred_at)
    VALUES ('c0000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a',2,2,'80000000-0000-7000-8000-000000000001', now())$$);
SELECT pg_temp.expect_error('editar un evento del libro',
  $$UPDATE ledger.events SET occurred_at = now() WHERE id = 'c0000000-0000-7000-8000-000000000001'$$);
SELECT pg_temp.expect_error('borrar un movimiento',
  $$DELETE FROM ledger.movements WHERE event_id = 'c0000000-0000-7000-8000-000000000001'$$);

-- Reverso del consumo (evento nuevo con motivo)
INSERT INTO ledger.events (id, tenant_id, event_type_id, event_origin_id, affiliation_id, branch_id, actor_membership_id, occurred_at, reverses_event_id, event_reason_id, reason_note)
VALUES ('c1000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a',3,1,'80000000-0000-7000-8000-000000000001',
        '20000000-0000-7000-8000-00000000000a','50000000-0000-7000-8000-000000000001', now(),'c0000000-0000-7000-8000-000000000001',1,'Escaneó dos veces');
INSERT INTO ledger.movements (tenant_id, event_id, package_id, units_delta) VALUES
  ('10000000-0000-7000-8000-00000000000a','c1000000-0000-7000-8000-000000000001','b2000000-0000-7000-8000-000000000001',1);
SELECT pg_temp.expect('saldo vuelve a 30 tras el reverso',
  (SELECT units_balance FROM prepaid.packages WHERE id = 'b2000000-0000-7000-8000-000000000001') = 30);
SELECT pg_temp.expect('caché y libro coinciden',
  (SELECT bool_and(is_consistent) FROM prepaid.v_package_balance_check));
SELECT pg_temp.expect_error('reversar dos veces el mismo consumo',
  $$INSERT INTO ledger.events (id, tenant_id, event_type_id, event_origin_id, affiliation_id, occurred_at, reverses_event_id)
    VALUES (core.uuid_v7(),'10000000-0000-7000-8000-00000000000a',3,1,'80000000-0000-7000-8000-000000000001', now(),'c0000000-0000-7000-8000-000000000001')$$);
SELECT pg_temp.expect_error('movimiento con signo contrario al tipo de evento (consumo positivo)',
  $$WITH e AS (INSERT INTO ledger.events (id, tenant_id, event_type_id, event_origin_id, affiliation_id, occurred_at)
               VALUES ('c2000000-0000-7000-8000-000000000001','10000000-0000-7000-8000-00000000000a',2,1,'80000000-0000-7000-8000-000000000001', now()) RETURNING id)
    INSERT INTO ledger.movements (tenant_id, event_id, package_id, units_delta)
    SELECT '10000000-0000-7000-8000-00000000000a', id, 'b2000000-0000-7000-8000-000000000001', 5 FROM e$$);

-- Máquina de estados de la tiquetera
SELECT pg_temp.expect_error('tiquetera anulada no puede volver a activa',
  $$UPDATE prepaid.packages SET package_status_id = 4 WHERE id = 'b2000000-0000-7000-8000-000000000001';
    UPDATE prepaid.packages SET package_status_id = 1 WHERE id = 'b2000000-0000-7000-8000-000000000001'$$);

-- La app no escribe en la facturación de VECI
SELECT pg_temp.expect_error('el comercio intenta cambiarse de plan',
  $$UPDATE billing.subscriptions SET plan_id = 3$$);

-- Búsqueda global enmascarada
SELECT pg_temp.expect('búsqueda por documento devuelve datos enmascarados',
  (SELECT masked_document FROM customers.find_person_by_document('CC','1124000003')) = '****0003');

-- ------------------------------------------------- 3. Aislamiento entre comercios
SET app.tenant_id = '10000000-0000-7000-8000-00000000000b';
SELECT pg_temp.expect('comercio B no ve afiliaciones de A', (SELECT count(*) FROM customers.affiliations) = 0);
SELECT pg_temp.expect('comercio B no ve tiqueteras de A', (SELECT count(*) FROM prepaid.packages) = 0);
SELECT pg_temp.expect('comercio B no ve eventos de A', (SELECT count(*) FROM ledger.events) = 0);
SELECT pg_temp.expect('comercio B no ve a la clienta de A', (SELECT count(*) FROM identity.people WHERE document_number = '1124000003') = 0);
SELECT pg_temp.expect('comercio B solo se ve a sí mismo', (SELECT count(*) FROM tenancy.tenants) = 1);
SELECT pg_temp.expect_error('comercio B escribe una fila con tenant_id de A',
  $$INSERT INTO tenancy.services (tenant_id, name) VALUES ('10000000-0000-7000-8000-00000000000a','Intruso')$$);

-- ------------------------------------------------- 4. La clienta en su app
RESET app.tenant_id;
SET app.person_id = '30000000-0000-7000-8000-000000000003';
SELECT pg_temp.expect('la clienta ve su afiliación', (SELECT count(*) FROM customers.affiliations) = 1);
SELECT pg_temp.expect('la clienta ve su tiquetera', (SELECT count(*) FROM prepaid.packages) = 1);
SELECT pg_temp.expect('la clienta ve su historial', (SELECT count(*) FROM ledger.v_customer_history) >= 3);
SELECT pg_temp.expect('la clienta ve solo sus comercios', (SELECT count(*) FROM tenancy.tenants) = 1);
SELECT pg_temp.expect('sin contexto de comercio no ve facturación', (SELECT count(*) FROM billing.subscriptions) = 0);
RESET app.person_id;
SELECT pg_temp.expect('sin contexto no se ve nada', (SELECT count(*) FROM customers.affiliations) = 0);
RESET ROLE;

-- ------------------------------------------------- 5. Integridad entre comercios (llaves compuestas)
SELECT pg_temp.expect_error('tiquetera de B colgada de una afiliación de A',
  $$INSERT INTO prepaid.packages (id, tenant_id, affiliation_id, package_type_id, sale_item_id, starts_at, expires_at, package_status_id)
    VALUES (core.uuid_v7(),'10000000-0000-7000-8000-00000000000b','80000000-0000-7000-8000-000000000001',
            '90000000-0000-7000-8000-000000000001','b1000000-0000-7000-8000-000000000001', now(), now() + interval '1 day', 1)$$);
SELECT pg_temp.expect('uuid_v7 genera versión 7', substr(core.uuid_v7()::text, 15, 1) = '7');
SELECT pg_temp.expect_error('ni siquiera el dueño del esquema edita el libro (trigger)',
  $$UPDATE ledger.movements SET units_delta = 100$$);
SELECT pg_temp.expect_error('ni siquiera el dueño del esquema borra la auditoría (trigger)',
  $$INSERT INTO audit.audit_log (action_id, entity_table) VALUES (10, 'sales.sales');
    DELETE FROM audit.audit_log$$);
