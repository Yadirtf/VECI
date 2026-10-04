# 2. Comercios y sedes (`tenancy`)

El comercio (*tenant*) es la raíz del aislamiento: casi toda fila de negocio lleva su `tenant_id`. Aquí viven también el personal, los horarios de servicio y los ajustes que cada comercio puede cambiar sin tocar código.

DDL: [03_tenancy.sql](sql/03_tenancy.sql) · Decisión: [ADR-0002](../adr/0002-multi-comercio-con-rls.md)

```mermaid
erDiagram
    business_types ||--o{ tenants : "tipo de negocio"
    tenant_statuses ||--o{ tenants : ""
    tenants ||--o{ tenant_contacts : ""
    tenants ||--o{ branches : "sedes"
    municipalities ||--o{ branches : ""
    tenants ||--o{ memberships : "personal"
    users ||--o{ memberships : ""
    membership_statuses ||--o{ memberships : ""
    memberships ||--o{ membership_roles : ""
    roles ||--o{ membership_roles : ""
    memberships ||--o{ membership_branches : ""
    branches ||--o{ membership_branches : ""
    tenants ||--o{ tenant_devices : "celulares de caja"
    devices ||--o{ tenant_devices : ""
    tenants ||--o{ services : "desayuno, almuerzo"
    services ||--o{ service_schedules : ""
    branches ||--o{ service_schedules : ""
    weekdays ||--o{ service_schedules : ""
    setting_definitions ||--o{ tenant_settings : ""
    tenants ||--o{ tenant_settings : ""
    tenants ||--o{ tenant_signing_keys : "firma QR"
```

## Tablas

| Tabla | Qué guarda | Reglas clave |
| --- | --- | --- |
| `business_types` | Restaurante, cafetería, panadería, colegio, tienda, otro. | Nuevo sector = nueva fila (RF-COM-04, RNF-ESC-02). |
| `tenants` | Comercio: nombre, documento (NIT o cédula), tipo, estado, moneda, zona horaria, logo. | `slug` único para el enlace público. El estado es administrativo (alta, activo, suspendido, cerrado); el estado de pago vive en `billing.subscriptions`. |
| `tenant_contacts` | Teléfonos y correos del comercio. | Uno principal por tipo. |
| `branches` | Sede con municipio (DIVIPOLA) y dirección. | Una sola sede principal por comercio; nace con el comercio (HU-03-01). |
| `memberships` | <a id="membresías"></a>Intermedia usuario ↔ comercio para el personal. | Única por `(tenant_id, user_id)`. Estados: invitado, activo, suspendido, retirado (RF-AUT-05). |
| `membership_roles` | Intermedia membresía ↔ rol, con vigencia. | Solo roles `assignable_to_membership`. Revocar un rol cierra la fila: queda la historia de permisos (RNF-SEG-05). |
| `membership_branches` | Intermedia membresía ↔ sede: dónde trabaja cada cajero. | Sin filas = todas las sedes (decisión de la aplicación en el plan Básico, que tiene una sola). |
| `tenant_devices` | Celulares autorizados como caja de un comercio. | Revocar uno cierra sus sesiones (HU-02-06). |
| `services` | Servicios que el comercio ofrece (desayuno, almuerzo, cena; en un colegio, recreo). | Nombre único por comercio. |
| `service_schedules` | Horario de cada servicio por sede y día de la semana. | Restricción de exclusión: dos horarios activos de la misma sede no se solapan el mismo día dentro del mismo periodo de vigencia (HU-03-02). Un turno que pasa la medianoche se registra en dos filas. |
| `setting_definitions` | Parámetros configurables: tipo de dato, valor por defecto, mínimo y máximo. | Aviso de renovación en N unidades, días de inactividad, minutos para reversar, hora del resumen diario... |
| `tenant_settings` | Valor que un comercio da a un parámetro. | Sin fila, aplica el valor por defecto. |
| `tenant_signing_keys` | Claves con que se firman los QR del comercio. | La pública baja al celular del cajero para verificar sin internet; la privada vive en el gestor de secretos y aquí solo su referencia. Una activa a la vez, rotables ([ADR-0005](../adr/0005-qr-firmado-por-comercio.md)). |

## Alta de un comercio (HU-03-01)

En una sola transacción: `tenants` (estado `ONBOARDING`) → `branches` (principal) → `memberships` + `membership_roles` (propietario) → `tenant_signing_keys` → `billing.subscriptions` (plan `TRIAL`). Al terminar la configuración, el comercio pasa a `ACTIVE`.
