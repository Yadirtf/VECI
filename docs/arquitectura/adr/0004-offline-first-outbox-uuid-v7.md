# 0004 · Offline primero: bandeja de salida, UUID v7 e idempotencia

- **Estado:** Aceptada
- **Fecha:** 2026-10-04
- **Requerimientos:** RF-OFF-01 a RF-OFF-06, RNF-CON-01, RNF-CON-02, RNF-DIS-01

## Contexto

El internet en Mocoa y alrededores es intermitente. La caja no puede detenerse: el cajero vende y descuenta sin conexión hasta por 7 días, y al volver la señal nada puede perderse ni duplicarse.

## Decisión

1. **Ids generados en el celular, UUID v7.** Eventos, tiqueteras, lotes y dispositivos nacen con su id en el celular. UUID v7 es único sin coordinación y ordenado por tiempo (bueno para los índices). En PostgreSQL 16 lo genera `core.uuid_v7()`; desde la versión 18, `uuidv7()` nativo.
2. **Bandeja de salida (outbox) en Drift/SQLite.** Cada operación se guarda localmente con su id y su hora real, y se envía en orden.
3. **Idempotencia por llave primaria.** `sync.inbound_events.id` = id del celular. Un reintento choca con la PK y la API responde con el resultado ya guardado. El evento del libro usa **el mismo id**, así que tampoco puede duplicarse por otra vía.
4. **Hora real y hora de llegada.** `occurred_at` (cuando pasó) y `recorded_at` (cuando llegó). Los eventos se aplican por hora real y la diferencia decide si la notificación explica el retraso (RF-OFF-06).
5. **Conflictos registrados, no rechazados.** Lo que pasó offline ya pasó. Si al juntar celulares aparece un doble consumo o un saldo negativo, el evento se guarda, se marca `APPLIED_WITH_CONFLICT` y se abre un conflicto para que el propietario lo acepte o lo reverse.
6. **Bajada incremental.** Las tablas que necesita el celular llevan `sync_version`; el celular pide los cambios desde su último número. Como nada se borra, no hacen falta lápidas.

## Alternativas consideradas

| Alternativa | Por qué no |
| --- | --- |
| Ids secuenciales del servidor | El celular no puede crear registros sin conexión. |
| UUID v4 | Funciona, pero fragmenta índices B-tree en tablas de millones de filas. |
| Rechazar en el servidor lo que viola reglas | Borraría hechos reales (el almuerzo ya se sirvió) y el comercio perdería el registro. |
| Sincronización por "última escritura gana" | Pierde datos en silencio; inaceptable para saldos. |

## Consecuencias

- La regla "un consumo por horario" no puede ser una restricción única de la base: se aplica en el caso de uso y se detecta en la sincronización.
- `sync.inbound_events` es el registro de idempotencia y por eso no se particiona (su PK debe ser solo el id). Su carga cruda se vacía a los 90 días.
- La prueba HU-07-07 (7 días, 1.000 eventos, cortes a mitad de lote) se apoya en estas garantías.
