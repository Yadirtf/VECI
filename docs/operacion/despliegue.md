# Despliegue (HU-01-08)

## Entornos

| Entorno | Rama | API | Panel | Base de datos | Cómo se despliega |
| --- | --- | --- | --- | --- | --- |
| Local | cualquiera | `pnpm --filter @veci/api dev` | `pnpm --filter @veci/web dev` | Docker Compose | a mano |
| Staging | `develop` | Render `veci-api-staging` (gratuito) | Vercel, vista previa | Neon, rama `staging` | automático al fusionar en `develop` |
| Producción | `main` | Render `veci-api-produccion` (Starter) | Vercel, producción | Neon, rama `main` | al fusionar en `main`, después de aprobar el entorno `produccion` |

El workflow [`despliegue.yml`](../../.github/workflows/despliegue.yml) corre el CI completo y, si pasa:

1. Llama el *deploy hook* de Render con el commit exacto. El contenedor aplica las migraciones pendientes (`prisma migrate deploy`, con `DATABASE_URL`) y arranca la API con `DATABASE_APP_URL` (usuario `veci_api`, sujeto a RLS).
2. Espera a que `/salud` responda `ok` con la versión de ese commit.
3. Construye y publica el panel con la CLI de Vercel.

Si faltan secretos, el despliegue se salta con un aviso; el CI sigue protegiendo los PR.

## Configuración inicial (una sola vez)

### 1. Base de datos en Neon

1. Crear el proyecto `veci` con **PostgreSQL 16** en *AWS US East (N. Virginia)*.
2. Crear la rama `staging` a partir de `main`.
3. En cada rama, con la cadena de conexión del dueño (`neondb_owner`), crear el usuario de la API:

   ```bash
   psql "$URL_DUENO" -v clave_api='una-clave-larga' -f infra/postgres/crear-roles.sql
   ```

   Las migraciones crean `veci_app` y `veci_platform`; si se corre antes, el script crea `veci_app`.
4. Anotar dos cadenas por rama: la del dueño (`DATABASE_URL`, solo migraciones) y la de `veci_api` (`DATABASE_APP_URL`). Use la conexión directa, no la del *pooler*, para `DATABASE_URL`.

### 2. API en Render

1. *New → Blueprint* y elegir este repositorio: Render lee [`render.yaml`](../../render.yaml) y crea los dos servicios.
2. En cada servicio, llenar `DATABASE_URL`, `DATABASE_APP_URL`, `VECI_ORIGENES` (URL del panel) y `SENTRY_DSN`.
3. En *Settings → Build & Deploy*, ramas: `develop` para staging y `main` para producción. Copiar el **Deploy Hook** de cada servicio.

### 3. Panel en Vercel

1. Importar el repositorio con *Root Directory* `apps/web` y desactivar los despliegues automáticos de Git (*Settings → Git → Ignored Build Step*: `exit 0`), porque los hace GitHub Actions.
2. Variables: `NEXT_PUBLIC_VECI_API_URL`, `NEXT_PUBLIC_VECI_ENTORNO`, `NEXT_PUBLIC_SENTRY_DSN` (por entorno *Preview* y *Production*); `SENTRY_AUTH_TOKEN`, `SENTRY_ORG` y `SENTRY_PROJECT_WEB` para subir mapas de fuente.
3. Crear un token en *Account Settings → Tokens* y anotar `orgId` y `projectId` (`vercel link` los deja en `.vercel/project.json`).

### 4. GitHub

En *Settings → Environments* crear:

| Entorno | Protección | Secretos | Variables |
| --- | --- | --- | --- |
| `staging` | solo rama `develop` | `RENDER_DEPLOY_HOOK`, `VERCEL_TOKEN` | `API_URL`, `PANEL_URL`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` |
| `produccion` | rama `main` y **revisores requeridos** | los mismos, de producción | los mismos, de producción |
| `respaldos` | solo rama `main` | `DATABASE_URL_RESPALDO`, `RESPALDO_CLAVE` | `PG_VERSION` (opcional, 16) |

Variables del repositorio para la vigilancia: `API_URL_STAGING` y `API_URL_PRODUCCION`.

En *Settings → Branches* (o *Rules*), proteger `main` y `develop`: exigir PR, exigir los checks del CI (`Lint, tipos, arquitectura, pruebas y build`, `Migraciones, RLS y pruebas de integración`, `Contrato OpenAPI y clientes generados al día`, `App Flutter`) y bloquear *force push*.

## Imagen de la API en local

```bash
docker build -f apps/api/Dockerfile -t veci-api .
docker compose --profile api up
```

## Volver a una versión anterior

- **API:** en Render, *Deploys → Rollback* sobre el despliegue anterior. Las migraciones no se revierten solas: si la versión nueva cambió la base, escriba una migración correctiva y despliéguela.
- **Panel:** en Vercel, *Deployments → Promote to Production* sobre el anterior.
