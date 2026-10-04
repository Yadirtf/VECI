# 0008 · Un esquema de PostgreSQL por módulo, nombres en inglés y convenciones

- **Estado:** Aceptada
- **Fecha:** 2026-10-04
- **Requerimientos:** RNF-MAN-02, RNF-MAN-03 · Requerimientos §5.3

## Contexto

La arquitectura limpia (§5.3) organiza el código por funcionalidad. Si la base es un solo saco de 121 tablas, esa separación se pierde en la capa de datos y cualquier módulo termina leyendo tablas de otro.

## Decisión

1. **Un esquema por módulo**: `core`, `identity`, `tenancy`, `customers`, `prepaid`, `ledger`, `sales`, `consumptions`, `sync`, `billing`, `notifications`, `compliance`, `audit`. Cada módulo NestJS escribe solo en el suyo.
2. **Nombres físicos en inglés**, `snake_case`, tablas en plural. Es el idioma del ecosistema (Prisma, PostgreSQL, librerías), evita tildes y eñes en identificadores y coincide con los términos que pidió el dueño del producto (`people`, `users`, `roles`). El dominio, la interfaz y la documentación siguen en español; la correspondencia está en el [README del modelo](../modelo-datos/README.md#4-correspondencia-con-el-backlog).
3. **Convenciones obligatorias** de llaves, tipos, columnas estándar e índices en [00-convenciones.md](../modelo-datos/00-convenciones.md).
4. **El DDL de referencia es la fuente** de la primera migración de Prisma. Lo que Prisma no expresa (RLS, triggers, exclusiones, índices parciales, dominios) va como SQL dentro de la migración (`prisma migrate dev --create-only` y edición). Prisma maneja varios esquemas con `schemas` en el `datasource`.
5. **Toda migración** mantiene en verde [validar.sh](../modelo-datos/sql/validar.sh) y agrega la comprobación de su nueva regla.

## Alternativas consideradas

| Alternativa | Por qué no |
| --- | --- |
| Todo en `public` con prefijos (`tiq_`, `cli_`) | Prefijos frágiles, sin permisos por módulo, difícil de leer. |
| Nombres en español | Mezcla con términos técnicos en inglés, problemas con tildes, y Prisma genera tipos en inglés de todos modos. |
| Esquema escrito solo en Prisma | No expresa las garantías de integridad que este modelo necesita. |

## Consecuencias

- Los permisos y el RLS se pueden razonar por esquema.
- Extraer un módulo a su propio servicio en el futuro es mover su esquema.
- Si Prisma resulta limitante con RLS y SQL avanzado, Drizzle (alternativa ya listada en §6.1) consume el mismo esquema sin cambiar el modelo.
