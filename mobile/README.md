# VECI · mobile

App de Flutter, una sola con dos modos (Cajero y Cliente). Está pensada para Android de gama baja y para trabajar sin internet (offline primero, [ADR 0004](../docs/arquitectura/adr/0004-offline-first-outbox-uuid-v7.md)). Esta carpeta es un proyecto independiente: no usa nada de `backend/` ni de `web/`; solo lee el contrato y los tokens publicados en `docs/`.

## Requisitos

- Flutter 3.47.
- Java 17+ y Node 22 (con `npx`), solo para regenerar el cliente de la API.

## Correr

```bash
flutter pub get
flutter run \
  --dart-define=VECI_API=http://10.0.2.2:3000 \
  --dart-define=VECI_ENTORNO=desarrollo
```

| Variable (`--dart-define`) | Por defecto | Para qué |
| --- | --- | --- |
| `VECI_API` | `http://10.0.2.2:3000` | URL de la API (10.0.2.2 es el computador visto desde el emulador) |
| `VECI_COMERCIO` | comercio demo | Negocio activo hasta que llegue el inicio de sesión (EP-02) |
| `VECI_USUARIO_DESARROLLO` | cajero demo | Usuario de desarrollo, solo en desarrollo y staging |
| `VECI_ENTORNO` | `desarrollo` | Entorno que se reporta a Sentry |
| `SENTRY_DSN` | vacío (apagado) | Proyecto `veci-mobile` de Sentry |

## Comandos

```bash
flutter analyze                                            # análisis estático estricto
flutter test                                               # pruebas
dart format $(find lib test tool -name "*.dart" ! -name "*.g.dart")   # formato (ancho 100)
python3 tool/verificar_arquitectura.py                     # capas y tamaños (el CI falla si no cumple)
dart run build_runner build --delete-conflicting-outputs   # código de Drift
bash tool/generar_cliente.sh                               # cliente Dart desde docs/api/openapi.json
dart run tool/generar_tokens.dart                          # tokens desde docs/diseno/tokens.json
```

## Estructura

```
mobile/
├── lib/
│   ├── features/<funcionalidad>/{domain,data,presentation}   horarios es la plantilla
│   └── core/          base local (Drift), red, DI (Riverpod), rutas, tema, UI base, observabilidad
├── test/              pruebas, con la misma estructura de lib/
├── tool/              scripts de la app: arquitectura, tokens y cliente
├── packages/veci_api/ cliente Dart generado (no se edita a mano)
├── android/, ios/     proyectos nativos
└── pubspec.yaml
```

## Probar en el celular

El workflow `APK staging` construye un APK que apunta a la API de staging en Render. Descárguelo en *Actions → APK staging → Artifacts* e instálelo; los pasos están en [docs/operacion/despliegue.md](../docs/operacion/despliegue.md#3-app-en-el-celular). Para compilarlo en local contra otra URL:

```bash
flutter build apk --release --dart-define=VECI_API=https://veci-api-staging.onrender.com --dart-define=VECI_ENTORNO=staging
```

La guía completa de capas está en [docs/arquitectura/arquitectura-limpia.md](../docs/arquitectura/arquitectura-limpia.md).
