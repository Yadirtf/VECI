# 0013 · Infraestructura: Render, Neon y GitHub Actions

- **Estado:** Propuesta
- **Fecha:** 2026-10-04
- **Requerimientos:** RNF-DIS-01, RNF-DIS-02, RNF-OBS-01, RNF-COS-01, HU-01-07, HU-01-08

## Contexto

La HU-01-08 pide API, panel y PostgreSQL administrado con copias diarias de 30 días, despliegue automático a staging y a producción con aprobación, todo por menos de $150.000 COP al mes hasta 30 comercios. La sección 6 de los requerimientos sugiere Railway, Render o Fly.io para la API, Vercel para el panel y Neon o Supabase para la base.

## Decisión

- **API en Render** a partir de `backend/Dockerfile` (blueprint en `backend/render.yaml`): staging en el plan gratuito y producción en Starter (US$7). El contenedor aplica `prisma migrate deploy` al arrancar, con el usuario dueño, y luego sirve con `veci_api`, sujeto a RLS. Render revisa `/salud` antes de pasar tráfico.
- **Panel también en Render**, como servicio Node con *Root Directory* `web` (blueprint en `web/render.yaml`). Al principio se eligió Vercel; se cambió (ver *Actualización*) para tener un solo proveedor.
- **PostgreSQL 16 en Neon**, un proyecto para staging y otro para producción, en EE. UU. junto a la API.
- **Staging lo despliega Render** en cada commit de `develop`, solo cuando pasan los CI de GitHub (`autoDeployTrigger: checksPass`). **Producción la orquesta GitHub Actions** (`despliegue.yml`): corre el CI, espera la aprobación del entorno `produccion` y llama los deploy hooks de Render con el commit exacto.
- **Copias:** además del historial de Neon, `respaldo-diario.yml` saca un `pg_dump` cifrado cada noche y lo retiene 30 días; `prueba-restauracion.yml` lo restaura cada mes en una base limpia y comprueba estructura, saldos y RLS.
- **Errores y alertas en Sentry** (plan gratuito) para las tres apps, más `vigilancia.yml` como respaldo del monitor de disponibilidad.

## Alternativas consideradas

- **Railway:** cobra por uso desde el primer día y no tiene capa gratuita estable para staging.
- **Fly.io:** buena latencia, pero exige tarjeta y más configuración de red para un equipo pequeño.
- **Supabase:** incluye mucho que no usamos (auth, storage) y sus copias diarias requieren el plan Pro.
- **Panel en Vercel:** gratis en Hobby, pero ese plan es para uso no comercial y Pro cuesta US$20; además suma un segundo proveedor y otra CLI en el despliegue.
- **Despliegue automático también en producción:** desplegaría sin aprobación. En staging sí se usa, porque Render espera a que el CI pase.

## Consecuencias

- Costo estimado en el piloto: US$14 (API y panel de producción en Render Starter) + US$0 a 19 (Neon) + US$0 (staging, Sentry, GitHub) ≈ US$14 a 33 al mes, es decir entre $59.000 y $139.000 COP a $4.200 por dólar. El detalle está en `docs/operacion/costos.md`.
- El staging gratuito de Render se duerme tras 15 minutos sin tráfico: la primera petición tarda cerca de un minuto.
- Si Render cambia de precios, cambiar de proveedor solo toca los `render.yaml` y `despliegue.yml`: la imagen Docker de la API es portable y el panel es un Next.js estándar.

## Actualización (2026-10-04)

El panel pasa de Vercel a Render y cada proyecto tiene su propio blueprint (`backend/render.yaml`, `web/render.yaml`), según el [ADR 0014](0014-proyectos-independientes-backend-web-mobile.md). La API crea su usuario `veci_api` al arrancar con la clave que Render genera, así que en staging solo hay que pegar `DATABASE_URL`. La app se prueba con un APK de staging que construye `apk.yml`.
