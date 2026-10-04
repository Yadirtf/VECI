# VECI · backend

API central de VECI: NestJS 11 como monolito modular con arquitectura limpia, Prisma 7 y PostgreSQL 16 con aislamiento por comercio (RLS). Esta carpeta es un proyecto independiente, con sus propias dependencias, configuración, base de datos local, imagen Docker y despliegue.

## Requisitos

- Node 22 (`.nvmrc`) y pnpm 10 (`corepack enable`).
- Docker, para la base de datos local.

## Correr en local

```bash
pnpm install
docker compose up -d postgres   # PostgreSQL 16 en localhost:5432 con los roles de la API
pnpm db:migrar                  # aplica prisma/migrations
pnpm db:semilla                 # comercio demo, cajero, clientes y tiqueteras
pnpm dev                        # http://localhost:3000 (contrato en /docs)
```

Los valores por defecto apuntan a la base local; para cambiarlos copie `.env.example` a `.env`. La semilla crea **Restaurante La Vecina** (dueña Marta, cajero Jhon y la clienta Luz Marina con 19 almuerzos) y **Panadería El Trigal**, un segundo comercio para probar el aislamiento. Todas las personas demo entran con el PIN **246813**: Marta `310 000 0101` (también `marta@lavecina.co` / `almuerzo2026`), Jhon `310 000 0102`, Luz Marina `310 000 0103` y Soporte VECI `310 000 0105`.

### Sesión (EP-02, [ADR-0015](../docs/arquitectura/adr/0015-sesion-pin-temporal-y-acceso-propio.md))

- `POST /sesion/con-pin` o `/sesion/con-contrasena` devuelve un token de acceso de 15 minutos (va en `Authorization: Bearer`) y uno de renovación que rota en cada `POST /sesion/renovar`. Cada petición revisa que la sesión siga abierta, así el cierre remoto surte efecto de inmediato.
- Con un PIN temporal (invitación o restablecimiento) la respuesta trae `requiereCambioDePin` y un `tokenCambio`; la sesión se abre en `POST /sesion/pin-nuevo`.
- Las rutas de un negocio exigen además `x-veci-comercio` y el permiso del rol (`@RequierePermiso`, desde `identity.role_permissions`).
- En desarrollo y pruebas, la cabecera `x-veci-usuario` con el id de un usuario demo sigue sirviendo para probar sin entrar; en staging y producción se ignora.
- `VECI_TOKENS_SECRETO` firma los tokens y es obligatorio fuera de local.

## Comandos

| Comando | Qué hace |
| --- | --- |
| `pnpm verificar` | Formato, lint, tipos, arquitectura y pruebas unitarias (lo mismo que el CI, sin base). |
| `pnpm lint` / `pnpm typecheck` | ESLint (incluye tamaño de archivos y funciones) y tipos. |
| `pnpm arquitectura` | Reglas de capas e importaciones entre módulos (dependency-cruiser). |
| `pnpm test` / `pnpm test:cov` | Unitarias / unitarias + integración contra PostgreSQL, con cobertura. |
| `pnpm build` | Compila a `dist/`. |
| `pnpm generar` | Exporta el contrato a `../docs/api/openapi.json`. |
| `pnpm db:esquema` | Regenera `prisma/schema.prisma` desde la base migrada. |
| `pnpm db:verificar` | Comprueba que las migraciones reproducen el modelo de referencia de `docs/`. |

## Estructura

```
backend/
├── src/
│   ├── modules/<modulo>/{domain,application,infrastructure,presentation}   horarios es la plantilla
│   └── shared/        lo transversal (contexto del comercio, Prisma, Sentry, errores, OpenAPI)
├── test/              pruebas de integración contra PostgreSQL
├── prisma/            migraciones, esquema introspectado y semilla demo
├── scripts/           exportar el contrato OpenAPI y preparar la base al arrancar en Render
├── infra/             roles de PostgreSQL y comprobación de copias de seguridad
├── eslint/            reglas de arquitectura
├── Dockerfile, docker-compose.yml
└── package.json
```

El contrato que consumen el panel y la app se publica en [`docs/api/openapi.json`](../docs/api/openapi.json). Si cambia un endpoint, corra `pnpm generar` y suba el contrato junto con el código. Staging se despliega en Render, con el blueprint [`render.yaml`](../render.yaml) de la raíz, cuando un commit de `develop` pasa el CI. La guía de capas está en [docs/arquitectura/arquitectura-limpia.md](../docs/arquitectura/arquitectura-limpia.md) y la operación (despliegue, copias, alertas) en [docs/operacion](../docs/operacion/README.md).
