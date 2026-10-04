-- =============================================================================
-- VECI · Datos de ejemplo (2 de 3): comercios, personal, oferta, venta y consumo.
-- Cada comercio se inserta con su contexto fijado, igual que lo haría la API,
-- para que las políticas RLS se cumplan aunque el usuario no sea superusuario.
-- =============================================================================

DO $$
DECLARE
  a constant uuid := 'd1000000-0000-7000-8000-000000000001';  -- Restaurante La Vecina (Mocoa)
  b constant uuid := 'd1000000-0000-7000-8000-000000000002';  -- Panadería El Trigal (Sibundoy)
BEGIN
  IF EXISTS (SELECT 1 FROM tenancy.tenants WHERE slug = 'la-vecina') THEN
    RETURN;
  END IF;

  -- ------------------------------------------------- comercio A: restaurante
  PERFORM set_config('app.tenant_id', a::text, true);
  INSERT INTO tenancy.tenants (id, slug, display_name, document_type_id, document_number, business_type_id, tenant_status_id)
  SELECT a, 'la-vecina', 'Restaurante La Vecina', dt.id, '1124500001', bt.id, ts.id
    FROM core.document_types dt, tenancy.business_types bt, tenancy.tenant_statuses ts
   WHERE dt.code = 'CC' AND bt.code = 'RESTAURANT' AND ts.code = 'ACTIVE';
  INSERT INTO tenancy.branches (id, tenant_id, name, is_main, branch_status_id, municipality_id, address_line)
  SELECT 'd2000000-0000-7000-8000-000000000001', a, 'Principal', true, bs.id, 86001, 'Barrio San Agustín, Mocoa'
    FROM tenancy.branch_statuses bs WHERE bs.code = 'ACTIVE';

  INSERT INTO tenancy.memberships (id, tenant_id, user_id, membership_status_id, joined_at)
  SELECT v.id::uuid, a, v.user_id::uuid, ms.id, now()
    FROM (VALUES ('d5000000-0000-7000-8000-000000000001','d4000000-0000-7000-8000-000000000001'),
                 ('d5000000-0000-7000-8000-000000000002','d4000000-0000-7000-8000-000000000002')) AS v (id, user_id)
    JOIN tenancy.membership_statuses ms ON ms.code = 'ACTIVE';
  INSERT INTO tenancy.membership_roles (tenant_id, membership_id, role_id)
  SELECT a, v.membership_id::uuid, r.id
    FROM (VALUES ('d5000000-0000-7000-8000-000000000001','OWNER'),
                 ('d5000000-0000-7000-8000-000000000002','CASHIER')) AS v (membership_id, rol)
    JOIN identity.roles r ON r.code = v.rol;

  INSERT INTO tenancy.services (id, tenant_id, name, sort_order) VALUES
    ('d6000000-0000-7000-8000-000000000001', a, 'Desayuno', 1),
    ('d6000000-0000-7000-8000-000000000002', a, 'Almuerzo', 2);
  INSERT INTO tenancy.service_schedules (tenant_id, service_id, branch_id, weekday_id, hours)
  SELECT a, s.id, 'd2000000-0000-7000-8000-000000000001', w.id,
         CASE s.name WHEN 'Desayuno' THEN '[06:30,09:30)'::core.time_range ELSE '[11:30,15:00)'::core.time_range END
    FROM tenancy.services s CROSS JOIN core.weekdays w
   WHERE s.tenant_id = a AND w.code <> 'SUNDAY';

  INSERT INTO prepaid.package_types (id, tenant_id, name, consumption_unit_id, units_quantity, price_amount, validity_days, package_type_status_id)
  SELECT v.id::uuid, a, v.nombre, u.id, v.unidades, v.precio, v.dias, st.id
    FROM (VALUES ('d7000000-0000-7000-8000-000000000001','Tiquetera 20 almuerzos',20,220000,30),
                 ('d7000000-0000-7000-8000-000000000002','Tiquetera 30 almuerzos',30,330000,45)) AS v (id, nombre, unidades, precio, dias)
    JOIN prepaid.consumption_units u ON u.tenant_id IS NULL AND u.code = 'LUNCH'
    JOIN prepaid.package_type_statuses st ON st.code = 'ACTIVE';

  INSERT INTO billing.subscriptions (tenant_id, plan_id, subscription_status_id, current_period_ends_at)
  SELECT a, p.id, s.id, now() + interval '30 days'
    FROM billing.plans p, billing.subscription_statuses s WHERE p.code = 'TRIAL' AND s.code = 'TRIAL';

  -- ------------------------------------------------- comercio B: panadería
  PERFORM set_config('app.tenant_id', b::text, true);
  INSERT INTO tenancy.tenants (id, slug, display_name, document_type_id, document_number, business_type_id, tenant_status_id)
  SELECT b, 'el-trigal', 'Panadería El Trigal', dt.id, '1124500004', bt.id, ts.id
    FROM core.document_types dt, tenancy.business_types bt, tenancy.tenant_statuses ts
   WHERE dt.code = 'CC' AND bt.code = 'BAKERY' AND ts.code = 'ACTIVE';
  INSERT INTO tenancy.branches (id, tenant_id, name, is_main, branch_status_id, municipality_id)
  SELECT 'd2000000-0000-7000-8000-000000000002', b, 'Principal', true, bs.id, 86749
    FROM tenancy.branch_statuses bs WHERE bs.code = 'ACTIVE';
  INSERT INTO tenancy.memberships (id, tenant_id, user_id, membership_status_id, joined_at)
  SELECT 'd5000000-0000-7000-8000-000000000003', b, 'd4000000-0000-7000-8000-000000000004', ms.id, now()
    FROM tenancy.membership_statuses ms WHERE ms.code = 'ACTIVE';
  INSERT INTO tenancy.membership_roles (tenant_id, membership_id, role_id)
  SELECT b, 'd5000000-0000-7000-8000-000000000003', r.id FROM identity.roles r WHERE r.code = 'OWNER';
  INSERT INTO prepaid.package_types (id, tenant_id, name, consumption_unit_id, units_quantity, price_amount, validity_days, package_type_status_id)
  SELECT 'd7000000-0000-7000-8000-000000000003', b, 'Tiquetera 30 panes', u.id, 30, 30000, 30, st.id
    FROM prepaid.consumption_units u, prepaid.package_type_statuses st
   WHERE u.tenant_id IS NULL AND u.code = 'BREAD' AND st.code = 'ACTIVE';
END $$;
