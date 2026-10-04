# 0013 · Infraestructura: Render, Vercel, Neon y GitHub Actions

- **Estado:** Propuesta
- **Fecha:** 2026-10-04
- **Requerimientos:** RNF-DIS-01, RNF-DIS-02, RNF-OBS-01, RNF-COS-01, HU-01-07, HU-01-08

## Contexto

La HU-01-08 pide API, panel y PostgreSQL administrado con copias diarias de 30 días, despliegue automático a staging y a producción con aprobación, todo por menos de $150.000 COP al mes hasta 30 comercios. La sección 6 de los requerimientos sugiere Railway, Render o Fly.io para la API, Vercel para el panel y Neon o Supabase para la base.

## Decisión

- **API en Render** a partir de `backend/Dockerfile` (blueprint en `backend/render.yaml`): staging en el plan gratuito y producción en Starter (US$7). El contenedor aplica `prisma migrate deploy` al arrancar, con el usuario dueño, y luego sirve con `veci_api`, sujeto a RLS. Render revisa `/salud` antes de pasar tráfico.
- **Panel en Vercel** (plan Hobby mientras el uso lo permita).
- **PostgreSQL 16 en Neon**, un proyecto con una rama para staging y otra para producción, en EE. UU. Este junto a la API.
- **GitHub Actions orquesta todo** (`despliegue.yml`): corre el CI completo y luego llama el deploy hook de Render con el commit exacto y despliega el panel con la CLI de Vercel. `develop` va a staging; `main` espera la aprobación del entorno `produccion`.
- **Copias:** además del historial de Neon, `respaldo-diario.yml` saca un `pg_dump` cifrado cada noche y lo retiene 30 días; `prueba-restauracion.yml` lo restaura cada mes en una base limpia y comprueba estructura, saldos y RLS.
- **Errores y alertas en Sentry** (plan gratuito) para las tres apps, más `vigilancia.yml` como respaldo del monitor de disponibilidad.

## Alternativas consideradas

- **Railway:** cobra por uso desde el primer día y no tiene capa gratuita estable para staging.
- **Fly.io:** buena latencia, pero exige tarjeta y más configuración de red para un equipo pequeño.
- **Supabase:** incluye mucho que no usamos (auth, storage) y sus copias diarias requieren el plan Pro.
- **Despliegue automático desde Render y Vercel:** desplegaría aunque el CI esté en rojo y sin aprobación de producción.

## Consecuencias

- Costo estimado en el piloto: US$7 (Render producción) + US$0 a 19 (Neon) + US$0 (Vercel, Sentry, GitHub) ≈ US$7 a 26 al mes, es decir entre $30.000 y $110.000 COP a $4.200 por dólar. El detalle está en `docs/operacion/costos.md`.
- El staging gratuito de Render se duerme sin tráfico: la primera petición tarda unos segundos.
- Si Render o Vercel cambian de precios, cambiar de proveedor solo toca `backend/render.yaml` y `despliegue.yml`: la imagen Docker es portable.
