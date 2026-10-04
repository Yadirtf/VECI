-- =============================================================================
-- 16 · Vistas de lectura (security_invoker: respetan RLS de quien consulta)
-- =============================================================================

-- Conciliación: la caché de saldo debe ser igual a la suma del libro.
CREATE VIEW prepaid.v_package_balance_check WITH (security_invoker = true) AS
SELECT p.tenant_id,
       p.id                              AS package_id,
       p.units_balance                   AS cached_balance,
       coalesce(sum(m.units_delta), 0)   AS ledger_balance,
       p.units_balance = coalesce(sum(m.units_delta), 0) AS is_consistent
  FROM prepaid.packages p
  LEFT JOIN ledger.movements m ON m.package_id = p.id AND m.tenant_id = p.tenant_id
 GROUP BY p.tenant_id, p.id, p.units_balance;

-- Saldo del cliente en cada comercio: suma de tiqueteras que admiten consumo (RF-TIQ-04).
CREATE VIEW customers.v_affiliation_balances WITH (security_invoker = true) AS
SELECT a.tenant_id,
       a.id                                   AS affiliation_id,
       a.person_id,
       coalesce(sum(p.units_balance) FILTER (WHERE ps.allows_consumption AND p.expires_at > now()), 0)
                                              AS available_units,
       min(p.expires_at) FILTER (WHERE ps.allows_consumption AND p.expires_at > now())
                                              AS next_expiration_at
  FROM customers.affiliations a
  LEFT JOIN prepaid.packages p          ON p.affiliation_id = a.id AND p.tenant_id = a.tenant_id
  LEFT JOIN prepaid.package_statuses ps ON ps.id = p.package_status_id
 GROUP BY a.tenant_id, a.id, a.person_id;

-- Totales de venta derivados de sus líneas (no se guardan para no duplicar datos).
CREATE VIEW sales.v_sale_totals WITH (security_invoker = true) AS
SELECT s.tenant_id,
       s.event_id                      AS sale_id,
       e.occurred_at,
       e.branch_id,
       e.actor_membership_id,
       ss.counts_as_revenue,
       sum(si.line_total)              AS total_amount
  FROM sales.sales s
  JOIN ledger.events e        ON e.id = s.event_id
  JOIN sales.sale_statuses ss ON ss.id = s.sale_status_id
  JOIN sales.sale_items si    ON si.sale_id = s.event_id
 GROUP BY s.tenant_id, s.event_id, e.occurred_at, e.branch_id, e.actor_membership_id, ss.counts_as_revenue;

-- Dinero comprometido (RF-REP-01): unidades por servir × valor pagado por unidad.
CREATE VIEW prepaid.v_committed_liability WITH (security_invoker = true) AS
SELECT p.tenant_id,
       p.package_type_id,
       sum(greatest(p.units_balance, 0))                                          AS pending_units,
       round(sum(greatest(p.units_balance, 0) * si.unit_price / pt.units_quantity), 2) AS pending_amount
  FROM prepaid.packages p
  JOIN prepaid.package_statuses ps ON ps.id = p.package_status_id AND ps.counts_as_liability
  JOIN sales.sale_items si         ON si.id = p.sale_item_id
  JOIN prepaid.package_types pt    ON pt.id = p.package_type_id
 GROUP BY p.tenant_id, p.package_type_id;

-- Historial auditable por cliente (RF-REP-04, HU-10-04)
CREATE VIEW ledger.v_customer_history WITH (security_invoker = true) AS
SELECT e.tenant_id,
       e.affiliation_id,
       e.id                AS event_id,
       et.code             AS event_type_code,
       e.occurred_at,
       e.recorded_at,
       e.recorded_at - e.occurred_at AS sync_delay,
       e.branch_id,
       e.actor_membership_id,
       m.package_id,
       m.units_delta,
       m.balance_after,
       e.reverses_event_id,
       e.event_reason_id,
       e.reason_note
  FROM ledger.events e
  JOIN ledger.event_types et ON et.id = e.event_type_id
  LEFT JOIN ledger.movements m ON m.event_id = e.id AND m.tenant_id = e.tenant_id;

GRANT SELECT ON prepaid.v_package_balance_check, customers.v_affiliation_balances,
                sales.v_sale_totals, prepaid.v_committed_liability, ledger.v_customer_history
  TO veci_app, veci_platform;
