# 10. Escalabilidad y rendimiento

Meta: 500 comercios y 50.000 clientes sin rediseño, solo aumentando recursos (RNF-ESC-01); escanear y ver el saldo en 3 segundos o menos (RNF-REN-01); el 95 % de las peticiones en menos de 500 ms (RNF-REN-02).

## 10.1 Volumen esperado

Supuesto conservador a la meta de RNF-ESC-01: cada cliente activo consume 20 veces al mes y compra una tiquetera al mes.

| Tabla | Filas por mes | Filas al año | Tamaño aprox. al año (con índices) |
| --- | --- | --- | --- |
| `ledger.events` | ~1,05 M | ~12,6 M | ~4 GB |
| `ledger.movements` | ~1,1 M | ~13 M | ~3 GB |
| `consumptions.consumptions` | ~1 M | ~12 M | ~2,5 GB |
| `sync.inbound_events` | ~0,7 M (lo que llega offline) | ~8 M | ~3 GB (la carga cruda se vacía a 90 días) |
| `notifications.notifications` + intentos | ~2,2 M | ~26 M | ~6 GB |
| `audit.audit_log` | ~1,5 M | ~18 M | ~6 GB (particionada, archivable) |
| `prepaid.packages`, `sales.*` | ~50 mil | ~0,6 M | < 1 GB |
| Catálogos y configuración | — | miles | despreciable |

Unos 25 GB al año en el peor caso de la meta: cabe con holgura en un PostgreSQL administrado de gama media. En el piloto (5 restaurantes) son unos pocos MB.

## 10.2 Por qué el camino crítico es rápido

Escanear un QR y descontar hace, dentro de una transacción:

1. Buscar el QR por PK en `affiliation_qr_codes` (comprobar vigencia).
2. Leer las tiqueteras del cliente con `packages_affiliation_fifo_ix (tenant_id, affiliation_id, expires_at)`: pocas filas.
3. Comprobar la regla del horario con `consumptions_service_day_ix`.
4. Insertar evento, consumo, 1 o 2 movimientos (el trigger actualiza la caché de saldo con un `UPDATE` por PK) y la notificación.

Son búsquedas por índice sobre conjuntos diminutos, del orden de milisegundos, sin importar cuántos comercios haya. El saldo nunca se suma desde el historial en línea: se lee de la caché.

## 10.3 Decisiones que sostienen la escala

| Decisión | Efecto |
| --- | --- |
| UUID v7 como llave | Se inserta al final del índice (ordenado por tiempo): sin fragmentación ni páginas partidas como con UUID v4. |
| `tenant_id` primero en todos los índices compuestos | Cada consulta de un comercio recorre solo su parte del índice; RLS filtra sin costo extra. |
| Catálogos `smallint` | 2 bytes por referencia en tablas de millones de filas. |
| Caché de saldo con bloqueo de fila | Dos cajeros escaneando al mismo cliente se serializan solo sobre esa tiquetera; no hay bloqueos globales. |
| Totales derivados en vistas | Los reportes no dependen de contadores que se desincronicen. Si un reporte se vuelve lento, se agrega una vista materializada por comercio y día, sin cambiar el modelo. |
| Particiones mensuales en `audit_log` y `login_attempts` | Son solo inserción, crecen sin límite y se archivan por mes con `DETACH PARTITION`. |
| Sin `DELETE` | No hay huecos ni `VACUUM` agresivo por borrados; el crecimiento es predecible. |

## 10.4 Umbrales para la siguiente etapa

| Señal | Acción prevista |
| --- | --- |
| Más de 200 conexiones simultáneas | PgBouncer en modo transacción. Compatible con RLS porque el contexto se fija con `SET LOCAL`, que vive solo en la transacción. |
| Reportes que compiten con la caja | Réplica de lectura para el panel y las exportaciones. |
| `ledger.events` supera ~100 M filas o 50 GB | Particionar `events`, `movements` y `consumptions` por mes de `occurred_at` (la PK pasa a incluir la fecha y las FK compuestas también) o por hash de `tenant_id`. Se decide con datos reales; el modelo no cambia de forma. |
| `notifications` crece sin uso | Particionar por mes y archivar las enviadas de más de 6 meses. |
| Un comercio muy grande afecta a los demás | Mover ese comercio a su propia base: es posible porque todo lo suyo está marcado con `tenant_id` y las FK compuestas no cruzan comercios. |

## 10.5 Mantenimiento

- **Particiones:** un proceso mensual crea la partición del mes siguiente (o `pg_partman`). La partición `DEFAULT` evita perder filas si se olvida.
- **Conciliación diaria:** `prepaid.v_package_balance_check` debe devolver cero filas inconsistentes; si no, alerta en Sentry.
- **Copias:** diarias, retención de 30 días y prueba de restauración mensual (RNF-DIS-02).
- **Índices sin uso:** revisión trimestral con `pg_stat_user_indexes`.
