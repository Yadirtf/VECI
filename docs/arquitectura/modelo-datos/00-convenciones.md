# 0. Convenciones del modelo

Estas reglas aplican a todas las tablas. Una migración que no las cumpla no se fusiona.

## 0.1 Nombres

| Elemento | Regla | Ejemplo |
| --- | --- | --- |
| Esquema | Un esquema por módulo, en inglés, singular o nombre del dominio. | `identity`, `prepaid`, `ledger` |
| Tabla | `snake_case`, en inglés, plural. | `affiliations`, `service_schedules` |
| Tabla intermedia | Nombre de las dos entidades. | `membership_roles`, `role_permissions` |
| Catálogo de estado | `<entidad>_statuses` + `<entidad>_status_transitions`. | `package_statuses` |
| Llave primaria | `id`. En subtipos, la PK es la del supertipo (`event_id`). | `sales.sales.event_id` |
| Llave foránea | `<entidad>_id`. Si hay dos hacia la misma tabla, con rol: `<rol>_<entidad>_id`. | `actor_membership_id`, `reverses_event_id` |
| Booleano | Prefijo `is_`, `allows_`, `can_`, `requires_`. | `allows_consumption` |
| Fecha y hora | Sufijo `_at` (`timestamptz`); solo fecha, `_on` o `_date`. | `occurred_at`, `due_on`, `business_date` |
| Índice | `<tabla>_<propósito>_ix`; único `_ux`; restricción única `_uk`. | `packages_affiliation_fifo_ix` |

Los nombres del dominio en español (Comercio, Tiquetera, Consumo) se usan en el código de dominio y en la interfaz; la tabla de correspondencia está en el [README](README.md#4-correspondencia-con-el-backlog).

## 0.2 Llaves

| Tipo de tabla | Llave primaria | Motivo |
| --- | --- | --- |
| Entidades de negocio | `uuid` versión 7 | Se generan en el celular sin conexión, son únicas globalmente y, al ordenarse por tiempo, no fragmentan los índices como un UUID v4. |
| Catálogos | `smallint` con valor fijo sembrado + `code` único | Ocupan 2 bytes en cada fila que los referencia. El código de la aplicación usa `code` (`'ACTIVE'`), nunca el número. |
| Intermedias sin historia | Compuesta por las dos llaves | `role_permissions (role_id, permission_id)`. |
| Intermedias con vigencia | `uuid` + índice único parcial "vigente" | `membership_roles`: un rol se otorga, se revoca y se puede volver a otorgar, y queda la historia. |

**Llaves foráneas compuestas por comercio.** Toda tabla de negocio declara `UNIQUE (tenant_id, id)` y sus hijas la referencian con `(tenant_id, <padre>_id)`. Así la base de datos rechaza, por ejemplo, una tiquetera del comercio B colgada de un cliente del comercio A, aunque el código tenga un error.

## 0.3 Tipos de dato

| Dato | Tipo | Nota |
| --- | --- | --- |
| Dinero | `core.money_amount` = `numeric(14,2)` ≥ 0 | Nunca `float`. La moneda está en el comercio (`currency_code`). |
| Unidades | `integer` | Los asientos llevan signo (`units_delta`). |
| Instantes | `timestamptz` | Se guarda en UTC; se muestra con `tenants.time_zone` (America/Bogota). |
| Horarios | `core.time_range` (rango de `time`) | Permite impedir solapes con una restricción de exclusión. |
| Códigos de catálogo | `core.catalog_code` | `MAYUSCULAS_CON_GUION_BAJO`, máximo 40. |
| Celular | `varchar` en E.164 (`+573101234567`) | Validado con la expresión regular del catálogo `core.contact_types`. |
| Secretos | `text`/`bytea` con hash | PIN y contraseña con Argon2id; tokens (QR, sesión, enlace) solo como hash. |
| JSON | `jsonb` solo en sobres técnicos | Carga cruda de sincronización, variables de plantilla y antes/después de auditoría. Ningún dato de negocio vive en JSON. |

## 0.4 Columnas estándar

| Columna | Dónde | Regla |
| --- | --- | --- |
| `created_at`, `updated_at` | Tablas que cambian | `updated_at` lo pone el trigger `core.touch_updated_at`. |
| `<x>_status_id`, `status_changed_at` | Entidades con ciclo de vida | El trigger `core.enforce_status_transition` valida el cambio contra la tabla de transiciones y fecha el cambio. |
| `revoked_at` (+ `revocation_reason_id`) | Credenciales, sesiones, QR, asignaciones de rol o sede | Son vigencias, no estados: una fila vigente tiene `revoked_at IS NULL`. |
| `sync_version` | Tablas que bajan al celular | Número creciente global asignado por `core.bump_sync_version`; el celular pide "cambios desde N". |
| `tenant_id` | Toda tabla de negocio | Obligatorio, primera columna de los índices, filtrado por RLS. |

## 0.5 Qué es estado y qué es vigencia

| Si el dato... | Se modela como | Ejemplos |
| --- | --- | --- |
| tiene un ciclo de vida que el negocio nombra y del que dependen reglas | **Estado**: FK a `<entidad>_statuses` + transiciones permitidas | Comercio, sede, membresía, usuario, afiliación, tipo de tiquetera, tiquetera, venta, suscripción, conflicto, notificación, solicitud de datos |
| solo dice desde cuándo y hasta cuándo algo es válido | **Vigencia**: `granted_at`/`issued_at` y `revoked_at` + motivo en catálogo | PIN, sesión, QR, rol asignado, sede asignada, token push |
| se deduce de otros datos | **Nada**: se calcula | "Vencida hace 3 días", "consumo tardío" (`recorded_at - occurred_at`) |

## 0.6 Integridad garantizada por la base

La base no confía en que el código acierte. Estas reglas viven en PostgreSQL y las comprueba la [prueba de humo](sql/90_prueba_de_humo.sql):

- Un comercio no lee ni escribe filas de otro (RLS) y no puede enlazar filas de otro (FK compuestas).
- Libro, ventas, consumos, pagos y auditoría son inmutables (trigger y ausencia de permiso `UPDATE`/`DELETE`).
- Un evento se reversa una sola vez; un evento repetido choca con su llave (idempotencia).
- El signo de un asiento coincide con su tipo de evento (`event_types.balance_effect`).
- Los cambios de estado siguen las transiciones permitidas.
- Los horarios de una sede no se solapan el mismo día.
- Un celular o correo vigente pertenece a un solo usuario; solo los tipos de contacto marcados `can_login` sirven para entrar.
- Un rol de plataforma no se asigna a una membresía de comercio, ni al revés.
- El canal de pago pertenece a su medio (Nequi es transferencia, no efectivo).
