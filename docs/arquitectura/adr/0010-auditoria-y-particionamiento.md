# 0010 · Auditoría inmutable y particionamiento selectivo

- **Estado:** Aceptada
- **Fecha:** 2026-10-04
- **Requerimientos:** RNF-SEG-05, RNF-ESC-01, RNF-LEG-01, RF-REP-04, HU-12-03

## Contexto

Toda venta, consumo, ajuste y cambio de permisos debe quedar registrado sin posibilidad de alterarlo. Algunas tablas crecen sin límite. Particionar ayuda a archivar, pero en PostgreSQL obliga a que la llave primaria incluya la columna de partición, lo que complica las llaves foráneas hacia esa tabla.

## Decisión

1. **Dos niveles de auditoría.**
   - Los hechos de saldo se auditan solos: `ledger.events` ya guarda quién, cuándo, dónde, desde qué celular y por qué.
   - `audit.audit_log` registra lo demás: accesos, bloqueos, cambios de rol, configuraciones, PIN restablecidos y datos personales, con datos antes y después en `jsonb`.
2. **Inmutabilidad doble:** trigger `core.forbid_mutation` (bloquea incluso al dueño del esquema) y ningún permiso `UPDATE`/`DELETE` para la aplicación.
3. **Particionar solo lo que es solo-inserción y nadie referencia:** `audit.audit_log` e `identity.login_attempts`, por mes, con partición `DEFAULT` de respaldo. Las particiones viejas se archivan con `DETACH PARTITION`.
4. **No particionar todavía el libro** (`events`, `movements`, `consumptions`) ni `sync.inbound_events`: sus llaves primarias simples sostienen la integridad referencial y la idempotencia, y su volumen esperado (unos 13 millones de filas al año en la meta de 500 comercios) está muy dentro de lo que PostgreSQL maneja con índices. Los umbrales para particionarlos están en [escalabilidad §10.4](../modelo-datos/10-escalabilidad-y-rendimiento.md#104-umbrales-para-la-siguiente-etapa).
5. `audit_log` no tiene llaves foráneas a datos de negocio (solo a su catálogo de acciones): nada debe impedir conservarla.

## Alternativas consideradas

| Alternativa | Por qué no |
| --- | --- |
| Auditoría por triggers genéricos en todas las tablas | Mucho ruido, poco significado; la acción de negocio ("ajustó el saldo") se pierde entre cambios de columnas. |
| Particionar todo desde el inicio | Complica FK e idempotencia sin necesidad real a esta escala. |
| Guardar la auditoría fuera de PostgreSQL | Otra pieza que operar y pagar para una sola persona. |

## Consecuencias

- La aplicación registra en `audit_log` dentro de la misma transacción de la acción, usando los códigos de `audit.actions`.
- Hace falta un proceso mensual (o `pg_partman`) que cree la partición siguiente.
- El historial del cliente (RF-REP-04) se arma desde el libro; la bitácora del comercio (HU-12-03), desde `audit_log` filtrada por su `tenant_id`.
