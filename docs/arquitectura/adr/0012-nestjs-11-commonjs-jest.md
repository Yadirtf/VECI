# 0012 · NestJS 11 en CommonJS con Jest, Prisma 7 y migraciones desde el DDL

- **Estado:** Propuesta
- **Fecha:** 2026-10-04
- **Requerimientos:** RNF-MAN-01, RNF-MAN-03, HU-01-01, HU-01-02, HU-01-03, HU-01-04

## Contexto

La HU-01-01 arma el monorepo. Al iniciar, NestJS 12 se publica solo como ESM y su paquete de pruebas no corre con Jest sin banderas experimentales (`--experimental-vm-modules`), mocks que fallan en ESM y una configuración frágil de `ts-jest`. Vitest sí funciona con ESM, pero los decoradores de NestJS necesitan `emitDecoratorMetadata`, que el transformador de Vitest no emite sin un complemento adicional (SWC).

Además, el modelo de datos ya existe como DDL de referencia validado (HU-00-03): 13 esquemas, RLS, triggers, vistas y particiones que Prisma no sabe expresar en su lenguaje de esquema.

## Decisión

1. **NestJS 11 compilado a CommonJS** (`module: node16`) con **Jest 30 + ts-jest**. Es la combinación que el ecosistema de NestJS documenta y prueba; pasar a NestJS 12/ESM se evalúa cuando su paquete de pruebas soporte Jest o Vitest sin trucos.
2. **TypeScript 6** en el backend y el panel (TS 7 todavía no es compatible con `ts-jest`).
3. **Prisma 7** con `prisma.config.ts`, el generador `prisma-client` en CommonJS y el adaptador `@prisma/adapter-pg`.
4. **El DDL manda y Prisma lo refleja:** la primera migración es el DDL de referencia concatenado; `schema.prisma` se obtiene por introspección (`db:esquema`) y nunca se edita a mano. Cada cambio de modelo es una migración SQL nueva y su espejo en `docs/arquitectura/modelo-datos/sql`.
5. **El CI comprueba la paridad:** `db:verificar` levanta un PostgreSQL temporal, aplica el DDL en una base y las migraciones en otra, compara los volcados y corre la prueba de humo. `db:esquema --verificar` falla si `schema.prisma` quedó viejo.

## Alternativas consideradas

- **NestJS 12 + Jest en modo ESM:** banderas experimentales, `jest.mock` no funciona con ESM sin `unstable_mockModule`; se descartó por fragilidad.
- **NestJS 12 + Vitest con SWC:** viable, pero suma una herramienta de compilación más y difiere del ejemplo oficial; se puede revisar más adelante.
- **Modelar en `schema.prisma` y generar el SQL con `prisma migrate dev`:** perderíamos RLS, triggers, exclusiones, vistas y particiones, o habría que reescribirlos a mano en cada migración.

## Consecuencias

- Hay que mantener dos piezas en sincronía (DDL de referencia y migraciones), pero el CI lo vigila.
- Los tipos de Prisma reflejan exactamente la base real, incluidos los esquemas y nombres físicos en inglés.
- La migración a ESM queda como deuda conocida y acotada a `backend/`.
