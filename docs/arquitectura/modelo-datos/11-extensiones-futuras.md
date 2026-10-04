# 11. Extensiones futuras

Cómo crece el modelo para las fases 2 y 3 sin tocar el núcleo (RNF-ESC-02). Ninguna de estas tablas se crea en el MVP; se dejan descritas para comprobar que el diseño actual las admite.

| Necesidad | Requerimiento | Cómo entra en el modelo | Qué cambia en el núcleo |
| --- | --- | --- | --- |
| Cafetería, panadería, lavadero con paquetes propios | RF-EXP-01 | Filas en `business_types` y `consumption_units` (globales o del comercio). | Nada. |
| Varias sedes | RF-COM-03 | Ya modelado: `branches`, `membership_branches`, `service_schedules` por sede, `branch_id` en eventos. Se habilita con la función `MULTI_BRANCH` del plan. | Nada. |
| Venta de productos sueltos con inventario | RF-EXP-02 | Nuevo esquema `catalog`: `products`, `product_categories`, `stock_movements` (mismo patrón de libro inmutable). `sale_items` gana `product_id` opcional con un `CHECK` de exactamente uno entre `package_type_id` y `product_id`. | Una columna opcional en `sale_items`. |
| Colegios: acudiente que recarga y consulta | RF-EXP-03 | `identity.person_relationships (person_id, related_person_id, relationship_type_id, valid_from, valid_to)` con catálogo de tipos (acudiente, padre, madre). Rol `GUARDIAN` con permisos `me.*` extendidos a las afiliaciones de sus acudidos. `people` gana `birth_date` si el colegio la exige. | Filas en `roles` y `permissions`; una política RLS adicional. |
| Fiado con límite | RF-EXP-04 | Nuevo esquema `credit`: `credit_accounts (affiliation_id, limit_amount)` y `credit_entries` como libro inmutable en pesos (cargo, abono), con su tipo de evento en `ledger.event_types`. | Filas en catálogos. |
| Pago en línea (Wompi) | RF-APC-04, RF-SUS-04 | Activar `ONLINE_GATEWAY` y `WOMPI` en `core`; nueva tabla `payment_transactions` (intento, referencia de la pasarela, estado con su catálogo y transiciones). La venta se crea cuando la transacción queda aprobada. | Activar filas. |
| WhatsApp y OTP | RF-NOT-03, HU-14-01 | Activar el canal `WHATSAPP` y el tipo de credencial `OTP`; `user_credentials` ya admite secretos de un solo uso con expiración. | Activar filas. |
| Roles personalizados por comercio | — | `roles` gana `tenant_id` opcional (nulo = rol de VECI) y su id pasa a `uuid` en una migración controlada. | Una columna y una política RLS. |
| Preferencias de notificación | — | `notifications.person_channel_preferences (person_id, notification_type_id, channel_id, is_enabled)`. | Nada. |
| Facturación electrónica DIAN | Fuera del MVP | Esquema `invoicing` que referencia `sales.sales`; la venta no cambia. | Nada. |

La prueba de que el núcleo es genérico: ninguna fila de esta tabla exige renombrar una columna existente, partir una tabla o migrar datos del libro.
