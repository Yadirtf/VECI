# VECI · web

Panel administrativo de VECI para propietarios y administración, en el navegador: Next.js 16, React 19 y Tailwind 4. Esta carpeta es un proyecto independiente: no importa código de `backend/` ni de `mobile/`; habla con la API por HTTP usando el cliente generado desde el contrato publicado en `docs/api/openapi.json`.

## Requisitos

- Node 22 (`.nvmrc`) y pnpm 10 (`corepack enable`).
- La API corriendo (ver `backend/README.md`).

## Correr en local

```bash
pnpm install
pnpm dev     # http://localhost:3001
```

Por defecto apunta a `http://localhost:3000`. Para cambiarlo, copie `.env.example` a `.env.local`.

Para entrar con los datos de ejemplo de la semilla: celular **310 000 0101** y PIN **246813** (Marta, propietaria de Restaurante La Vecina), o el correo **marta@lavecina.co** con la contraseña **almuerzo2026**.

## Sesión (EP-02)

El panel nunca guarda tokens en `localStorage`. Las rutas `src/app/api/sesion/[accion]` son un pequeño servidor entre el navegador y la API (patrón BFF): guardan el token de renovación en una cookie `httpOnly` (`veci_renovacion`, solo para `/api/sesion`) y al navegador le entregan solo el token de acceso, que vive en memoria 15 minutos. Al recargar la página, el panel pide uno nuevo con esa cookie. Si dos peticiones encuentran el token vencido, se renueva una sola vez (`features/sesion/application/almacen-sesion.ts`). El negocio elegido sí se recuerda en `localStorage`, porque no es secreto.

## Clientes (EP-04)

- `/clientes` ("Tus clientes") es una libreta: busca mientras escribe sobre la copia de `GET /clientes/copia-local` y, desde 3 caracteres, también en la API; a la derecha, la ventanilla muestra la ficha o el registro asistido con el PIN de bienvenida para dictar (`shared/ui/pin-para-dictar.tsx`).
- El propietario ve documento y celular completos en la ficha; en la lista y en la caja van tapados (`****5678`).
- `/politica-de-datos` es pública e imprimible: el texto legal con su "en palabras de vecino".

## Tiqueteras y ventas (EP-05)

- `/tiqueteras` es la pizarra de lo que se vende: escribir, cambiar y dejar de vender tipos (lo que ya no se vende queda borroso).
- En la ficha de `/clientes`, la cuenta del cliente: saldo por unidad, pila de tiqueteras (arriba la que se gasta primero), historia, vender y ajustar con motivo.
- `/ventas` lista las últimas ventas para que el propietario anule una con motivo.

## Comandos

| Comando | Qué hace |
| --- | --- |
| `pnpm verificar` | Formato, lint, tipos, arquitectura y pruebas (lo mismo que el CI). |
| `pnpm lint` / `pnpm typecheck` | ESLint (incluye tamaño de archivos y funciones) y tipos. |
| `pnpm arquitectura` | Reglas de capas e importaciones entre funcionalidades (dependency-cruiser). |
| `pnpm test` / `pnpm test:cov` | Pruebas con Vitest, con o sin cobertura. |
| `pnpm build` | Build de producción. |
| `pnpm generar` | Regenera el cliente de la API (`src/shared/api/esquema.ts`) desde `../docs/api/openapi.json` y los tokens de diseño (`src/shared/ui/tokens.css`) desde `../docs/diseno/tokens.json`. |

## Estructura

```
web/
├── src/
│   ├── app/                    rutas de Next.js (solo componen pantallas) y api/sesion (BFF de la sesión)
│   ├── features/<funcionalidad>/{domain,application,infrastructure,presentation}   horarios es la plantilla
│   └── shared/                 api/ (cliente generado), ui/ (sistema de diseño), config/, lib/
├── scripts/                    generador de tokens de diseño
├── eslint/                     reglas de arquitectura
└── package.json
```

Staging se despliega en Render, con el blueprint [`render.yaml`](../render.yaml) de la raíz, cuando un commit de `develop` pasa el CI ([docs/operacion/despliegue.md](../docs/operacion/despliegue.md)).

La guía de capas está en [docs/arquitectura/arquitectura-limpia.md](../docs/arquitectura/arquitectura-limpia.md) y el sistema de diseño en [docs/diseno](../docs/diseno/README.md).
