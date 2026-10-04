-- =============================================================================
-- 09 · ledger (movimientos): asientos por tiquetera, inmutables
-- Un evento genera 1..n movimientos (un consumo de 2 unidades puede tocar
-- dos tiqueteras si la primera se agota). El saldo es la suma de movimientos.
-- =============================================================================

CREATE TABLE ledger.movements (
  id            uuid PRIMARY KEY DEFAULT core.uuid_v7(),
  tenant_id     uuid NOT NULL,
  event_id      uuid NOT NULL,
  package_id    uuid NOT NULL,
  units_delta   integer NOT NULL CHECK (units_delta <> 0),
  balance_after integer NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (event_id, package_id),
  FOREIGN KEY (tenant_id, event_id) REFERENCES ledger.events (tenant_id, id),
  FOREIGN KEY (tenant_id, package_id) REFERENCES prepaid.packages (tenant_id, id)
);
COMMENT ON TABLE ledger.movements IS 'Asiento del libro de unidades: +compra, -consumo, +reverso, ±ajuste, -vencimiento. Nunca se edita ni se borra.';
COMMENT ON COLUMN ledger.movements.balance_after IS 'Saldo de la tiquetera justo después de aplicar el asiento en el servidor.';

CREATE INDEX movements_package_ix ON ledger.movements (tenant_id, package_id, created_at);

-- -----------------------------------------------------------------------------
-- Aplica el asiento a la caché de saldo en la misma transacción.
-- El UPDATE bloquea la fila de la tiquetera: dos consumos simultáneos se serializan.
-- El signo del asiento debe coincidir con el definido para el tipo de evento.
-- -----------------------------------------------------------------------------
CREATE FUNCTION ledger.apply_movement() RETURNS trigger
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

  RETURN NEW;
END $$;

CREATE TRIGGER movements_apply BEFORE INSERT ON ledger.movements
  FOR EACH ROW EXECUTE FUNCTION ledger.apply_movement();
CREATE TRIGGER movements_immutable BEFORE UPDATE OR DELETE ON ledger.movements
  FOR EACH ROW EXECUTE FUNCTION core.forbid_mutation();
