# Despliegue (HU-01-08)

## Entornos

| Entorno | Rama | API | Panel | Base de datos | Cómo se despliega |
| --- | --- | --- | --- | --- | --- |
| Local | cualquiera | `pnpm dev` en `backend/` | `pnpm dev` en `web/` | Docker Compose | a mano |
| Staging | `develop` | Render `veci-api-staging` (gratis) | Render `veci-web-staging` (gratis) | Neon, rama `main` del proyecto `veci-staging` | Render, solo, cuando el commit pasa el CI |
| Producción | `main` | Render `veci-api-produccion` (Starter) | Render `veci-web-produccion` | Neon, proyecto `veci` | [`despliegue.yml`](../../.github/workflows/despliegue.yml), después de aprobar el entorno `produccion` |

La app (`mobile/`) no se despliega en un servidor: el workflow [`apk.yml`](../../.github/workflows/apk.yml) construye un APK que apunta a la API de staging, para instalarlo en un celular.

### Staging

El blueprint [`render.yaml`](../../render.yaml) de la raíz crea los dos servicios de staging (cada uno se construye solo desde su carpeta) con `autoDeployTrigger: checksPass`: en cada commit de `develop`, Render espera a que pasen los CI de GitHub y despliega. Al arrancar, el contenedor de la API:

1. Aplica las migraciones pendientes (`prisma migrate deploy`, con `DATABASE_URL`, el dueño de la base).
2. Crea o actualiza el usuario `veci_api` (sin `BYPASSRLS`) con la clave `VECI_API_DB_PASSWORD`, que Render genera ([`scripts/preparar-base.ts`](../../backend/scripts/preparar-base.ts)).
3. Carga los datos de ejemplo si `VECI_SEMBRAR_DEMO=true` (nunca en producción).
4. Arranca la API conectada como `veci_api`, sujeta a RLS. La URL se arma con `DATABASE_URL` y esa clave, o se toma de `DATABASE_APP_URL` si existe.

Con los datos de ejemplo se entra al panel con el celular **310 000 0101** y el PIN **246813** (Marta, propietaria), o con `marta@lavecina.co` y `almuerzo2026`; a la app, como cajero, con **310 000 0102** y el mismo PIN.

El plan gratuito de Render se duerme tras 15 minutos sin tráfico: la primera petición después tarda cerca de un minuto.

### Producción

`despliegue.yml` corre los CI del backend y del panel y, cuando alguien aprueba el entorno `produccion`, llama los *deploy hooks* de Render con el commit exacto y espera a que `/salud` de la API responda `ok` con esa versión. Si faltan los secretos, el despliegue se salta con un aviso.

## Poner a andar staging (una sola vez)

### 1. Base de datos en Neon

1. En [neon.tech](https://neon.tech), crear el proyecto `veci-staging` con **PostgreSQL 16** en *AWS US East (Ohio)*, cerca de Render.
2. En *Connect*, copiar la cadena de conexión del dueño (`neondb_owner`) **sin** *connection pooling*. Termina en `?sslmode=require`.

### 2. API y panel en Render

1. En [render.com](https://render.com), *New → Blueprint*, elegir este repositorio y la rama `develop`. Render encuentra `render.yaml` en la raíz y muestra los dos servicios: `veci-api-staging` y `veci-web-staging`.
2. Pegar la cadena de Neon en `DATABASE_URL`. Render genera solo `VECI_API_DB_PASSWORD` y `VECI_TOKENS_SECRETO` (firma de las sesiones, EP-02). `SENTRY_DSN` y `NEXT_PUBLIC_SENTRY_DSN` son opcionales. Aplicar.
3. Cuando termine, abrir `https://<api>.onrender.com/salud` (debe decir `"estado":"ok"`), `/docs` para ver el contrato y la URL del panel.
4. Si Render dio URLs distintas de `https://veci-api-staging.onrender.com` o `https://veci-web-staging.onrender.com`, corregir `NEXT_PUBLIC_VECI_API_URL` (y redesplegar el panel, porque esa variable se usa al construir) o `VECI_ORIGENES` en la API.

### 3. App en el celular

1. En GitHub, *Actions → APK staging*. Si la API quedó con otra URL, crear antes la variable del repositorio `API_URL_STAGING` (*Settings → Secrets and variables → Actions → Variables*) y correr el workflow con *Run workflow*.
2. Abrir la ejecución más reciente en verde, descargar `veci-staging-apk` (un .zip con `app-release.apk`) y pasarlo al celular.
3. Instalarlo permitiendo “instalar apps desconocidas”. Cada APK sale firmado con una llave de depuración distinta, así que para instalar uno nuevo hay que desinstalar el anterior.

### 4. GitHub

En *Settings → Branches* (o *Rules*), proteger `main` y `develop`: exigir PR, exigir los checks de `CI backend`, `CI web` y `CI mobile`, y bloquear *force push*.

Variables del repositorio: `API_URL_STAGING` (la usan el APK y la vigilancia) y, cuando exista, `API_URL_PRODUCCION`.

## Producción (cuando llegue el momento)

1. En Neon, crear el proyecto `veci` (PostgreSQL 16) para producción.
2. En Render, crear `veci-api-produccion` (Docker, *Root Directory* `backend`, plan Starter) y `veci-web-produccion` (Node, *Root Directory* `web`) con los mismos comandos y variables de los blueprints, pero con `VECI_ENTORNO=produccion`, un `VECI_TOKENS_SECRETO` propio (32+ caracteres, distinto al de staging), sin `VECI_SEMBRAR_DEMO`, rama `main` y *Auto-Deploy* apagado. Copiar el **Deploy Hook** de cada uno.
3. En GitHub, *Settings → Environments*:

| Entorno | Protección | Secretos | Variables |
| --- | --- | --- | --- |
| `produccion` | rama `main` y **revisores requeridos** | `RENDER_DEPLOY_HOOK_API`, `RENDER_DEPLOY_HOOK_WEB` | `API_URL`, `PANEL_URL` |
| `respaldos` | solo rama `main` | `DATABASE_URL_RESPALDO`, `RESPALDO_CLAVE` | `PG_VERSION` (opcional, 16) |

## Imagen de la API en local

```bash
cd backend
docker build -t veci-api .
docker compose --profile api up
```

## Volver a una versión anterior

- **API y panel:** en Render, *Events → Rollback* sobre el despliegue anterior. Las migraciones no se revierten solas: si la versión nueva cambió la base, escriba una migración correctiva y despliéguela.
