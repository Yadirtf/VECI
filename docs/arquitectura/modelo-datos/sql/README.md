# DDL de referencia

Modelo completo de VECI en SQL para PostgreSQL 16 o superior, un archivo por módulo. Es la fuente de la primera migración de Prisma (HU-01-03 y HU-01-04): lo que Prisma no expresa en su esquema (RLS, triggers, restricciones de exclusión, índices parciales, dominios) se copia como SQL dentro de esa migración.

| Orden | Archivo | Contenido |
| --- | --- | --- |
| 00 | [00_extensiones_y_utilidades.sql](00_extensiones_y_utilidades.sql) | Extensiones, dominios, `uuid_v7()`, triggers genéricos (`updated_at`, `sync_version`, inmutabilidad, transiciones de estado) y contexto de la petición. |
| 01 | [01_core.sql](01_core.sql) | Catálogos compartidos. |
| 02 | [02_identity.sql](02_identity.sql) | Personas, usuarios, credenciales, roles, permisos, dispositivos y sesiones. |
| 03 | [03_tenancy.sql](03_tenancy.sql) | Comercios, sedes, membresías, horarios, ajustes y claves de firma. |
| 04 | [04_customers.sql](04_customers.sql) | Afiliaciones, QR y enlaces de saldo. |
| 05 | [05_prepaid_oferta.sql](05_prepaid_oferta.sql) | Unidades de consumo y tipos de tiquetera. |
| 06 | [06_ledger_eventos.sql](06_ledger_eventos.sql) | Eventos del libro. |
| 07 | [07_sales.sql](07_sales.sql) | Ventas, líneas, pagos y cierre de caja. |
| 08 | [08_prepaid_tiqueteras.sql](08_prepaid_tiqueteras.sql) | Tiqueteras vendidas. |
| 09 | [09_ledger_movimientos.sql](09_ledger_movimientos.sql) | Movimientos y trigger de saldo. |
| 10 | [10_consumptions.sql](10_consumptions.sql) | Consumos y autorizaciones. |
| 11 | [11_sync.sql](11_sync.sql) | Sincronización y conflictos. |
| 12 | [12_billing.sql](12_billing.sql) | Planes y suscripciones. |
| 13 | [13_notifications.sql](13_notifications.sql) | Notificaciones. |
| 14 | [14_compliance_audit.sql](14_compliance_audit.sql) | Habeas data y auditoría. |
| 15 | [15_seguridad_rls.sql](15_seguridad_rls.sql) | Roles de base de datos, permisos y políticas RLS. |
| 16 | [16_vistas.sql](16_vistas.sql) | Vistas de saldo, pasivo, ventas e historial. |
| 20 | [20_semillas_catalogos.sql](20_semillas_catalogos.sql) | Valores de catálogos y transiciones. |
| 21 | [21_semillas_seguridad_planes.sql](21_semillas_seguridad_planes.sql) | Roles, permisos, ajustes, planes, plantillas y acciones de auditoría. |
| 90 | [90_prueba_de_humo.sql](90_prueba_de_humo.sql) | Flujo completo y 36 comprobaciones de reglas. |

## Validar

```bash
./validar.sh            # usa initdb/pg_ctl de PostgreSQL 16+; no correr como root
```

Crea un clúster temporal, aplica los archivos en orden, corre la prueba de humo y lo borra. Resultado esperado: `✔ Modelo válido`. Cualquier cambio al modelo debe mantener la prueba en verde y agregar la comprobación de su nueva regla.

## Roles de base de datos

| Rol | Uso | RLS |
| --- | --- | --- |
| Dueño de los esquemas | Solo migraciones. La API nunca se conecta con él. | Sujeto a RLS en las tablas de negocio (`FORCE ROW LEVEL SECURITY`); no en `identity.people`, para que la búsqueda enmascarada por documento funcione. |
| `veci_app` | La API en cada petición, tras fijar `app.tenant_id` o `app.person_id` con `SET LOCAL`. | Aplica. Sin `DELETE` en ninguna tabla. |
| `veci_platform` | Consola de administración VECI y procesos programados (vencimientos, avisos). | `BYPASSRLS`. Uso restringido al módulo de plataforma. |
