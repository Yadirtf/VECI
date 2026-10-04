# 0009 · Núcleo genérico multisector

- **Estado:** Aceptada
- **Fecha:** 2026-10-04
- **Requerimientos:** RF-COM-04, RNF-ESC-02, RF-EXP-01 a RF-EXP-04 · Requerimientos §1.3

## Contexto

VECI empieza con restaurantes de corrientazo, pero su visión es ser el aliado de cafeterías, panaderías, tiendas, colegios y gimnasios. Si el modelo dice "almuerzo" o "restaurante" en sus columnas, cada sector nuevo es un rediseño.

## Decisión

El núcleo es **comercio + cliente (afiliación) + paquete prepagado + evento de consumo**, y todo lo que depende del sector es dato:

| Lo que cambia por sector | Dónde vive |
| --- | --- |
| Tipo de negocio | `tenancy.business_types` |
| Qué se descuenta (almuerzo, café, pan, lavada) | `prepaid.consumption_units`, globales o propias del comercio |
| Paquetes que se venden | `prepaid.package_types` |
| Servicios y horarios (desayuno, almuerzo, recreo) | `tenancy.services` y `tenancy.service_schedules` |
| Parámetros de operación | `tenancy.setting_definitions` y `tenancy.tenant_settings` |
| Funciones por plan | `billing.features` y `billing.plan_features` |
| Textos de los avisos | `notifications.templates` |

Los ajustes usan definiciones tipadas (`setting_definitions` con tipo de dato, mínimo y máximo) en lugar de un `jsonb` libre: cada parámetro está documentado, validado y tiene un valor por defecto.

## Alternativas consideradas

| Alternativa | Por qué no |
| --- | --- |
| Tablas por sector (`restaurant_tickets`, `bakery_tickets`) | Duplica lógica y reportes por cada sector. |
| `jsonb` de configuración por comercio | Sin validación ni documentación; cada lector interpreta el JSON a su manera. |

## Consecuencias

- Abrir una cafetería en VECI es configurar filas, no programar ([extensiones futuras](../modelo-datos/11-extensiones-futuras.md)).
- Las funciones realmente nuevas (inventario, fiado, acudientes) llegan como módulos con su esquema, que referencian el núcleo sin modificarlo.
