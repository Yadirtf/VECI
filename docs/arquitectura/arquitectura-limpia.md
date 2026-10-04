# Arquitectura limpia en el código (HU-01-10)

Esta guía baja a carpetas concretas la sección 5.3 de los [requerimientos](../requerimientos-y-recomendaciones-tecnologicas.md). Si hay duda sobre dónde va un archivo, la respuesta está aquí; si no está, se agrega aquí en el mismo PR.

## La regla de dependencias

```
presentación ──► aplicación ──► dominio ◄── infraestructura
```

El dominio no conoce a nadie. La aplicación conoce al dominio y define **puertos** (interfaces) para lo que necesita de afuera. La infraestructura implementa esos puertos. La presentación recibe los casos de uso ya conectados y no toca la infraestructura.

Así, la regla “un cliente no puede consumir sin saldo” vive en un solo lugar, se prueba sin base de datos ni pantallas, y cambiar Prisma, Drift o el proveedor de errores no obliga a tocar el negocio.

## Límites que revisa el CI

| Regla | Herramienta | Dónde se configura |
| --- | --- | --- |
| Archivo ≤ 300 líneas, función ≤ 50, ≤ 5 parámetros (TS) | ESLint | `backend/eslint/` y `web/eslint/reglas-arquitectura.mjs` |
| Archivo ≤ 300 líneas y función ≤ 50 (Dart) | Script Python | `mobile/tool/verificar_arquitectura.py` |
| El dominio no importa frameworks, base de datos ni red | ESLint, dependency-cruiser y el script de Flutter | `eslint.config.mjs` y `.dependency-cruiser.cjs` de cada app |
| La aplicación no importa NestJS, Prisma, Sentry, Express ni `pg` | ESLint y dependency-cruiser | `backend` |
| La presentación no importa infraestructura | dependency-cruiser | API y web; en Flutter, `presentation` no importa `data` |
| Un módulo usa a otro solo por su `index.ts` (o su `domain` en Flutter) | dependency-cruiser y el script de Flutter | regla `modulos-por-su-interfaz-publica` |
| Sin ciclos de importación | dependency-cruiser | regla `sin-ciclos` |

En `backend/` y `web/` se corren con `pnpm lint` y `pnpm arquitectura`; en `mobile/`, con `python3 tool/verificar_arquitectura.py`. Las pruebas pueden tener funciones largas (un `describe` agrupa muchos casos), pero no archivos de más de 300 líneas.

## API (NestJS) · `backend/src`

```
modules/<modulo>/
  domain/
    entities/            horario-servicio.entity.ts
    value-objects/       rango-horas.vo.ts
    rules/               horarios-no-se-cruzan.rule.ts
    errors/              horario-se-cruza.error.ts
    repositories/        horario-servicio.repository.ts   (interfaz + token)
  application/
    dto/                 crear-horario.input.ts, horario.output.ts
    use-cases/           crear-horario.use-case.ts (+ .spec.ts y fakes en memoria)
    puertos/             interfaces de servicios externos
  infrastructure/
    persistence/         prisma-horario-servicio.repository.ts, mapper
  presentation/http/     horarios.controller.ts, crear-horario.request.ts, horario.response.ts
  horarios.module.ts     conecta puertos con implementaciones (useFactory)
  index.ts               lo único que otros módulos pueden importar
shared/                  lo transversal, con las mismas cuatro capas
```

- Los errores del dominio extienden `ErrorDeDominio` y el filtro global los traduce a 404, 409 o 422 con un `codigo` estable. El dominio nunca lanza `HttpException`.
- Toda lectura o escritura de datos de un comercio pasa por `TransaccionComercio`, que fija `app.tenant_id` en la transacción para que PostgreSQL aplique RLS ([ADR 0002](adr/0002-multi-comercio-con-rls.md)).
- Los controladores de un comercio llevan `@RequiereComercio()`: exige la cabecera `x-veci-comercio` y una membresía activa del usuario.
- Las pruebas unitarias van junto al archivo (`*.spec.ts`); las de integración, contra PostgreSQL real, en `test/integracion/*.int-spec.ts`.

## Panel web (Next.js) · `web/src`

```
app/                         rutas de Next.js: solo componen pantallas de features
features/<funcionalidad>/
  domain/                    tipos y reglas puras (agrupar-por-dia.ts)
  application/               hooks de casos de uso (use-horarios.ts)
  infrastructure/            acceso a la API con el cliente de shared/api
  presentation/              componentes (horarios-semana.tsx)
  <funcionalidad>.composicion.tsx   conecta infraestructura y presentación
  index.ts                   interfaz pública
shared/ui/                   sistema de diseño: Boton, Tarjeta, Campo, Aviso, Saldo, tokens.css
shared/api                   cliente tipado generado desde docs/api/openapi.json (esquema.ts) y cabeceras
shared/config, shared/lib    configuración y utilidades
```

Las páginas de `app/` importan solo el `index.ts` de una funcionalidad o `shared`, nunca su infraestructura.

## App móvil (Flutter) · `mobile/lib`

```
features/<funcionalidad>/
  domain/
    entities/        horario.dart
    repositories/    horarios_repository.dart (abstracto)
    usecases/        obtener_horarios_semana.dart
  data/
    models/          horario_model.dart (desde el cliente generado)
    datasources/     remoto (veci_api) y local (Drift)
    repositories/    horarios_repository_impl.dart (red primero, copia local si no hay señal)
  presentation/
    providers/       Riverpod
    pages/, widgets/
core/
  database/          Drift: app_database.dart y tablas
  network/           configuración y cliente de la API
  di/                providers que conectan data con domain
  router/            go_router
  theme/, ui/        tokens generados y componentes base
  observabilidad/    Sentry y el vigilante de sincronización
  error/             Fallo: SinConexion, ServidorNoDisponible, PeticionRechazada
```

El dominio de Flutter solo importa su propio dominio (ni `package:flutter`, ni Drift, ni `http`). `core` no importa `features`, salvo `core/di` y `core/router`, que son el punto de ensamblaje.

## Crear un módulo nuevo

1. Copie la carpeta `horarios` de la app que corresponda y renombre.
2. Empiece por el dominio y sus pruebas; luego el caso de uso con un fake en memoria.
3. Implemente la infraestructura y conéctela en el módulo (`*.module.ts`, `*.composicion.tsx` o `core/di`).
4. Exponga en `index.ts` solo lo que otros módulos necesitan.
5. Si cambia el contrato HTTP, corra `pnpm generar` en `backend/` (actualiza `docs/api/openapi.json`) y luego regenere los clientes: `pnpm generar` en `web/` y `bash tool/generar_cliente.sh` en `mobile/`.
