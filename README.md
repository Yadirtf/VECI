# VECI

El vecino aliado de los negocios del Putumayo: tiqueteras prepagadas (almuerzos, panes, lavadas…) que se venden y se consumen con un QR, aunque no haya internet.

El repositorio tiene tres proyectos independientes y su documentación. Cada proyecto tiene sus propias dependencias, configuración, pruebas y CI, y se abre, se corre y se despliega por separado:

| Carpeta | Qué es | Tecnología | Cómo empezar |
| --- | --- | --- | --- |
| [`backend/`](backend) | API central, monolito modular con arquitectura limpia | NestJS 11, Prisma 7, PostgreSQL 16 | [backend/README.md](backend/README.md) |
| [`web/`](web) | Panel administrativo en el navegador | Next.js 16, Tailwind 4 | [web/README.md](web/README.md) |
| [`mobile/`](mobile) | App única (modos Cajero y Cliente), offline primero | Flutter 3.47, Riverpod, Drift | [mobile/README.md](mobile/README.md) |
| [`docs/`](docs) | Requerimientos, backlog, arquitectura, operación, diseño y el contrato de la API | Markdown, JSON | [docs/](docs) |

`.github/` solo guarda los workflows de CI y despliegue, y [`render.yaml`](render.yaml) es el blueprint que despliega la API y el panel de staging en Render. Los dos van en la raíz porque GitHub y Render los buscan ahí.

## Cómo se conectan

Ningún proyecto importa código de otro. Se unen por dos archivos publicados en `docs/`:

- [`docs/api/openapi.json`](docs/api/README.md): el contrato HTTP. El backend lo genera; el panel y la app generan su cliente desde él.
- [`docs/diseno/tokens.json`](docs/diseno/sistema-de-diseno.md): colores y medidas del sistema de diseño. El panel genera su CSS y la app su Dart.

Los CI fallan si el contrato no coincide con el backend o si un cliente o los tokens quedaron desactualizados. Las decisiones están en el [ADR 0014](docs/arquitectura/adr/0014-proyectos-independientes-backend-web-mobile.md).

## Arrancar todo en local

```bash
# 1. API y base de datos
cd backend && pnpm install && docker compose up -d postgres && pnpm db:migrar && pnpm db:semilla && pnpm dev

# 2. Panel (otra terminal)
cd web && pnpm install && pnpm dev            # http://localhost:3001

# 3. App (otra terminal, con un emulador abierto)
cd mobile && flutter pub get && flutter run
```

## Arquitectura limpia

Los tres proyectos siguen la sección 5.3 de los [requerimientos](docs/requerimientos-y-recomendaciones-tecnologicas.md): carpetas por funcionalidad y, dentro de cada una, cuatro capas. Las dependencias apuntan siempre hacia el dominio.

```
presentación ──► aplicación ──► dominio ◄── infraestructura
```

| Capa | Qué va aquí | No puede importar |
| --- | --- | --- |
| `domain` | Entidades, objetos de valor, reglas de negocio, errores y los contratos (interfaces) de repositorios. | Frameworks, base de datos, red ni otras capas. |
| `application` | Casos de uso: orquestan el dominio y hablan con el exterior solo por puertos (interfaces). | NestJS, Prisma, Sentry, Flutter, HTTP. |
| `infrastructure` (`data` en Flutter) | Implementaciones de los puertos: Prisma, HTTP, Drift, Sentry. | Presentación. |
| `presentation` | Controladores HTTP, páginas, componentes y widgets. | Infraestructura (la recibe ya conectada). |

Lo que comparten varios módulos de un mismo proyecto vive en su `shared/` (backend y web) o `core/` (mobile), y un módulo solo usa a otro por su interfaz pública. El módulo **horarios** existe en los tres proyectos como plantilla.

El CI falla si un archivo pasa de 300 líneas o una función de 50 (y, en TypeScript, si una función recibe más de 5 parámetros), si el dominio importa un framework, o si un módulo entra a las carpetas internas de otro. La guía completa, con dónde va cada tipo de archivo, está en [docs/arquitectura/arquitectura-limpia.md](docs/arquitectura/arquitectura-limpia.md).

## Flujo de trabajo

0. Antes de implementar una épica o historia se aplica la [guía de mejor solución (SSoT)](docs/guias/ssot-mejor-solucion-no-generica.md): comparar alternativas distintas en cada decisión abierta y dejar constancia en el PR.
1. Se trabaja en una rama desde `develop` y se abre el PR contra `develop`.
2. Corren los tres CI (`CI backend`, `CI web`, `CI mobile`) y deben quedar en verde.
3. Al fusionar en `develop` se despliega solo a **staging**.
4. Cuando `develop` está listo, un PR de `develop` a `main` lleva el cambio a **producción**, que espera la aprobación del entorno `produccion`.

## Más documentación

- [Backlog](docs/backlog.md) y [requerimientos](docs/requerimientos-y-recomendaciones-tecnologicas.md).
- [Arquitectura](docs/arquitectura/README.md): modelo de datos, ADR y pruebas de concepto.
- [Operación](docs/operacion/README.md): despliegue, copias de seguridad, observabilidad y costos.
- [Diseño](docs/diseno/README.md): sistema de diseño y guía de tono.
