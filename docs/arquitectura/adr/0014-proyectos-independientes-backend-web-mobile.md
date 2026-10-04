# 0014 · Tres proyectos independientes: backend, web y mobile

- **Estado:** Propuesta
- **Fecha:** 2026-10-04
- **Requerimientos:** RNF-MAN-03, HU-01-01, HU-01-06, HU-01-09, HU-01-10

## Contexto

La primera versión de la EP-01 armó un monorepo con pnpm y Turborepo: `apps/api`, `apps/web`, `apps/mobile`, paquetes compartidos en `packages/` y herramientas en `tools/` e `infra/`. Funcionaba, pero la raíz quedaba llena de carpetas y archivos de configuración comunes, y los proyectos dependían entre sí por paquetes del workspace. El dueño del producto pidió una separación más clara para escalar: en la raíz solo el backend, el panel web, la app móvil y la documentación, cada uno con lo suyo y sin carpetas compartidas.

## Decisión

1. **La raíz tiene `backend/`, `web/`, `mobile/` y `docs/`.** Además, `.github/` (GitHub exige ahí los workflows) y los archivos sueltos `README.md`, `.gitignore` y `.editorconfig`.
2. **Cada proyecto es autónomo:** su gestor de paquetes y archivo de bloqueo, su configuración de lint y formato, sus reglas de arquitectura, sus scripts, sus pruebas y su forma de desplegarse. Se abre y se corre desde su carpeta sin instalar nada en la raíz.
3. **Ningún proyecto importa código de otro.** Las pocas piezas que antes estaban en `packages/shared` (nombres de cabeceras HTTP y el filtro de datos personales para Sentry) ahora viven en cada proyecto que las usa. Son pocas líneas, y el contrato las vigila.
4. **El único punto de unión es lo publicado en `docs/`:**
   - `docs/api/openapi.json`: el backend lo genera; web y mobile generan sus clientes desde él.
   - `docs/diseno/tokens.json`: web genera su CSS y mobile su Dart, cada uno con su propio generador.
5. **Un CI por proyecto** (`ci-backend.yml`, `ci-web.yml`, `ci-mobile.yml`). Cada uno corre dentro de su carpeta y comprueba que su parte del contrato y de los tokens esté al día.
6. **Lo que es de un solo proyecto se queda con él:** la base local (`docker-compose.yml`), la imagen Docker y los scripts de PostgreSQL y copias de seguridad están en `backend/`.
7. **La prueba de concepto de la HU-00-04** pasa a `docs/arquitectura/poc/escaneo-offline/` como código de referencia junto a sus resultados.

## Alternativas consideradas

- **Mantener el monorepo con Turborepo:** un solo `install` y un solo comando de CI, pero acopla las versiones de herramientas y deja la raíz cargada; para un equipo pequeño con tres tecnologías distintas (NestJS, Next.js y Flutter) aporta poco.
- **Tres repositorios:** separación total, pero el contrato, los issues y la documentación quedan dispersos y un cambio de API exige tres PR coordinados.

## Consecuencias

- Hay una pequeña duplicación intencional (cabeceras HTTP, filtro de Sentry, reglas de ESLint en backend y web). Si crece, se publica como contrato en `docs/` en lugar de volver a un paquete compartido.
- Cambiar un endpoint exige regenerar el contrato en `backend/` y los clientes en `web/` y `mobile/`; los CI lo exigen.
- Render despliega los dos servicios con un solo blueprint, `render.yaml` en la raíz (es lo único de despliegue que vive ahí, porque Render lo busca en la raíz). Cada servicio declara su *Root Directory* (`backend` o `web`) y se construye solo con su carpeta.
- Reemplaza la parte de “Monorepo” de la sección 6 de los requerimientos y de la HU-01-01.
