# 0003 · Saldos como libro de eventos inmutables con caché transaccional

- **Estado:** Aceptada
- **Fecha:** 2026-10-04
- **Requerimientos:** RF-CON-02, RF-TIQ-04, RF-TIQ-05, RF-TIQ-06, RF-REP-01, RF-REP-04, RNF-SEG-05

## Contexto

El saldo de una tiquetera es dinero del cliente. Un error de saldo es la falla más grave que puede tener VECI (la puerta del piloto exige "cero errores de saldo"). Además hay que resolver reclamos ("yo no comí ese día") y consumos que llegan horas después desde un celular sin internet.

## Decisión

1. **Todo cambio de saldo es un evento** en `ledger.events` (venta, consumo, reverso, anulación, ajuste, vencimiento) con quién, dónde, desde qué celular, la hora real y la hora de llegada.
2. **Cada evento deja asientos** en `ledger.movements`, uno por tiquetera afectada, con `units_delta` firmado. Un consumo que agota una tiquetera y sigue en la siguiente deja dos asientos.
3. **Inmutable:** eventos, asientos, ventas, pagos y consumos no se editan ni se borran (trigger + sin permisos). Corregir es registrar un evento nuevo que apunta al original (`reverses_event_id`), y un evento se reversa una sola vez.
4. **Saldo = suma de asientos.** `prepaid.packages.units_balance` es una caché que actualiza un trigger en la misma transacción del asiento (bloqueando esa fila), y `balance_after` queda grabado en el asiento. La vista `v_package_balance_check` concilia caché y libro.
5. **Subtipos con la misma llave:** `sales.sales` y `consumptions.consumptions` comparten la PK del evento (herencia de tabla por clase). Lo común está una vez; lo propio de cada tipo, en su tabla.
6. El signo permitido de cada tipo de evento está en datos (`event_types.balance_effect`) y lo valida el trigger.

## Alternativas consideradas

| Alternativa | Por qué no |
| --- | --- |
| Columna `saldo` que se suma y resta | Pierde el porqué de cada cambio; un error no se puede reconstruir ni auditar. |
| Una sola tabla `movimientos` con todas las columnas posibles | Muchas columnas nulas según el tipo (pagos solo en ventas, horario solo en consumos): viola la normalización. |
| Event sourcing completo (estado solo derivado de eventos) | Exige proyecciones y reconstrucciones; demasiada infraestructura para un desarrollador. El libro + caché da la trazabilidad sin ese costo. |

## Consecuencias

- Cualquier saldo se explica asiento por asiento (RF-REP-04) y la caché se puede recalcular desde el libro en cualquier momento.
- Leer el saldo al escanear es una búsqueda por llave, no una suma.
- La caché puede quedar negativa cuando dos consumos offline chocan; se acepta a propósito y abre un conflicto ([ADR-0004](0004-offline-first-outbox-uuid-v7.md)).
- El libro crece siempre; su plan de crecimiento está en [escalabilidad](../modelo-datos/10-escalabilidad-y-rendimiento.md).
