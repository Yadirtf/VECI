# VECI

El vecino aliado de los negocios del Putumayo: tiqueteras prepagadas (almuerzos, panes, lavadas…) que se venden y se consumen con un QR, aunque no haya internet.

Este repositorio es un monorepo con todo el producto:

| Carpeta | Qué es | Tecnología |
| --- | --- | --- |
| [`apps/api`](apps/api) | API central, monolito modular | NestJS 11, Prisma 7, PostgreSQL 16 |
| [`apps/web`](apps/web) | Panel web de propietarios y administración | Next.js 16, Tailwind 4 |
| [`apps/mobile`](apps/mobile) | App única (modos Cajero y Cliente), offline primero | Flutter 3.47, Riverpod, Drift |
| [`packages/shared`](packages/shared) | Constantes y utilidades de TypeScript compartidas | TypeScript |
| [`packages/api-client`](packages/api-client) | Contrato OpenAPI y cliente TypeScript generado | openapi-typescript |
| [`apps/mobile/packages/veci_api`](apps/mobile/packages/veci_api) | Cliente Dart generado del mismo contrato | openapi-generator |
| [`tools`](tools) | Reglas de arquitectura, tokens de diseño y scripts de CI | Node, Python |
| [`infra`](infra) | Roles de PostgreSQL y comprobaciones de copias | SQL |
| [`docs`](docs) | Requerimientos, backlog, arquitectura, operación y diseño | Markdown |

## Requisitos

- Node 22 (`.nvmrc`) y pnpm 10 (`corepack enable`).
- Docker, para la base de datos local.
- Flutter 3.47 (solo para la app móvil).
- Java 17+ (solo para regenerar el cliente Dart con `pnpm generar`).

## Arrancar en local

```bash
pnpm install
pnpm db:levantar          # PostgreSQL 16 en localhost:5432 (docker compose)
pnpm db:migrar            # aplica apps/api/prisma/migrations
pnpm db:semilla           # comercio demo, cajero, clientes y tiqueteras
pnpm --filter @veci/shared build

pnpm --filter @veci/api dev   # API en http://localhost:3000 (contrato en /docs)
pnpm --filter @veci/web dev   # panel en http://localhost:3001
cd apps/mobile && flutter run --dart-define=VECI_API=http://10.0.2.2:3000
```

Los valores por defecto ya apuntan a la base local y al comercio demo; para cambiarlos copie `apps/api/.env.example` y `apps/web/.env.example`. La semilla crea **Restaurante La Vecina** (dueña Marta, cajero Jhon y la clienta Luz Marina con 19 almuerzos) y **Panadería El Trigal**, un segundo comercio para probar el aislamiento.

Mientras llega el inicio de sesión (EP-02), la API acepta en desarrollo y staging la cabecera `x-veci-usuario` con el id de un usuario demo; en producción esa puerta está cerrada.

## Comandos del día a día

| Comando | Qué hace |
| --- | --- |
| `pnpm lint` | ESLint en todo el monorepo (incluye tamaño de archivos y funciones). |
| `pnpm typecheck` | Tipos de TypeScript. |
| `pnpm arquitectura` | Reglas de capas e importaciones entre módulos (dependency-cruiser y el chequeo de Flutter). |
| `pnpm test` | Pruebas unitarias. |
| `pnpm --filter @veci/api test:cov` | Pruebas de la API con integración contra PostgreSQL y cobertura. |
| `pnpm build` | Compila API, panel y paquetes. |
| `pnpm format` | Prettier. En Flutter: `dart format lib test`. |
| `pnpm generar` | Regenera contrato OpenAPI, clientes TS/Dart y tokens de diseño. |
| `pnpm --filter @veci/api db:esquema` | Regenera `schema.prisma` desde la base migrada. |
| `pnpm --filter @veci/api db:verificar` | Comprueba que las migraciones reproducen el modelo de referencia. |

En la app móvil: `flutter analyze`, `flutter test` y `dart run build_runner build` (Drift).

## Arquitectura limpia

Todo el código sigue la sección 5.3 de los [requerimientos](docs/requerimientos-y-recomendaciones-tecnologicas.md): carpetas por funcionalidad y, dentro de cada una, cuatro capas. Las dependencias apuntan siempre hacia el dominio.

```
presentación ──► aplicación ──► dominio ◄── infraestructura
```

| Capa | Qué va aquí | No puede importar |
| --- | --- | --- |
| `domain` | Entidades, objetos de valor, reglas de negocio, errores y los contratos (interfaces) de repositorios. | Frameworks, base de datos, red ni otras capas. |
| `application` | Casos de uso: orquestan el dominio y hablan con el exterior solo por puertos (interfaces). | NestJS, Prisma, Sentry, Flutter, HTTP. |
| `infrastructure` (`data` en Flutter) | Implementaciones de los puertos: Prisma, HTTP, Drift, Sentry. | Presentación. |
| `presentation` | Controladores HTTP, páginas, componentes y widgets. | Infraestructura (la recibe ya conectada). |

Lo que comparten varios módulos vive en `shared` (API y web) o `core` (Flutter), y un módulo solo usa a otro por su `index.ts` público. El módulo **horarios** existe en las tres apps como plantilla: para crear uno nuevo, copie su estructura.

El CI falla si un archivo pasa de 300 líneas o una función de 50 (y, en TypeScript, si una función recibe más de 5 parámetros), si el dominio importa un framework, o si un módulo entra a las carpetas internas de otro. La guía completa, con dónde va cada tipo de archivo, está en [docs/arquitectura/arquitectura-limpia.md](docs/arquitectura/arquitectura-limpia.md).

## Flujo de trabajo

1. Se trabaja en una rama desde `develop` y se abre el PR contra `develop`.
2. El CI (lint, tipos, arquitectura, pruebas con cobertura, migraciones, contrato y app Flutter) debe quedar en verde.
3. Al fusionar en `develop` se despliega solo a **staging**.
4. Cuando `develop` está listo, un PR de `develop` a `main` lleva el cambio a **producción**, que espera la aprobación del entorno `produccion`.

## Más documentación

- [Backlog](docs/backlog.md) y [requerimientos](docs/requerimientos-y-recomendaciones-tecnologicas.md).
- [Arquitectura](docs/arquitectura/README.md): modelo de datos, ADR y pruebas de concepto.
- [Operación](docs/operacion/README.md): despliegue, copias de seguridad, observabilidad y costos.
- [Diseño](docs/diseno/README.md): sistema de diseño y guía de tono.
