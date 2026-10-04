# Contrato de la API

[`openapi.json`](openapi.json) es el contrato HTTP de la API de VECI (HU-01-06). Es el único punto de unión entre los tres proyectos:

- **backend/** lo produce: `pnpm generar` lo exporta desde los controladores de NestJS. Su CI falla si el archivo no coincide con el código.
- **web/** lo consume: `pnpm generar` crea `src/shared/api/esquema.ts` (tipos de `openapi-typescript`).
- **mobile/** lo consume: `bash tool/generar_cliente.sh` crea `packages/veci_api` (cliente Dart de `openapi-generator`).

Los CI de web y mobile fallan si su cliente no está al día con este archivo. En desarrollo y staging, la API también lo publica en `/docs` (navegable) y `/docs/openapi.json`.

No se edita a mano: cambie el controlador y regenere.
