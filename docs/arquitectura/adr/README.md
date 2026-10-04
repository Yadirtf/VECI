# Registro de decisiones de arquitectura (ADR)

Un ADR deja escrito una decisión que cuesta cambiar: el contexto, lo que se eligió, lo que se descartó y lo que implica. Así quien llegue después entiende el porqué sin tener que adivinarlo.

| ADR | Decisión | Estado |
| --- | --- | --- |
| [0001](0001-backend-nestjs-monolito-modular.md) | Backend NestJS separado, como monolito modular | Aceptada |
| [0002](0002-multi-comercio-con-rls.md) | Multi-comercio en esquema compartido con `tenant_id`, RLS y llaves compuestas | Aceptada |
| [0003](0003-saldos-como-libro-de-eventos.md) | Saldos como libro de eventos inmutables con caché transaccional | Aceptada |
| [0004](0004-offline-first-outbox-uuid-v7.md) | Offline primero: bandeja de salida, UUID v7 e idempotencia | Aceptada |
| [0005](0005-qr-firmado-por-comercio.md) | QR con token firmado por comercio, sin datos sensibles | Aceptada |
| [0006](0006-estados-y-tipos-como-catalogos.md) | Estados y tipos como catálogos con transiciones en datos, no enums | Aceptada |
| [0007](0007-persona-usuario-rol-membresia.md) | Persona, usuario, rol, membresía y afiliación separados | Aceptada |
| [0008](0008-esquemas-por-modulo-y-convenciones.md) | Un esquema de PostgreSQL por módulo, nombres en inglés y convenciones | Aceptada |
| [0009](0009-nucleo-generico-multisector.md) | Núcleo genérico multisector (unidades, tipos de negocio y ajustes en datos) | Aceptada |
| [0010](0010-auditoria-y-particionamiento.md) | Auditoría inmutable y particionamiento selectivo | Aceptada |
| [0011](0011-librerias-escaneo-offline.md) | Librerías para escanear, verificar y guardar sin internet (HU-00-04) | Propuesta |
| [0012](0012-nestjs-11-commonjs-jest.md) | NestJS 11 en CommonJS con Jest, Prisma 7 y migraciones desde el DDL | Propuesta |
| [0013](0013-infraestructura-y-despliegue.md) | Infraestructura: Render, Vercel, Neon y GitHub Actions | Propuesta |

## Cómo proponer uno nuevo

1. Copiar la plantilla de abajo en `NNNN-titulo-corto.md` con el siguiente número.
2. Abrir un PR con estado **Propuesta**; al fusionarlo pasa a **Aceptada**.
3. Un ADR no se edita para cambiar la decisión: se escribe otro que lo **reemplaza** y se marca el anterior como **Reemplazada por NNNN**.

```markdown
# NNNN · Título

- **Estado:** Propuesta | Aceptada | Reemplazada por NNNN
- **Fecha:** AAAA-MM-DD
- **Requerimientos:** RF-…, RNF-…

## Contexto
## Decisión
## Alternativas consideradas
## Consecuencias
```
