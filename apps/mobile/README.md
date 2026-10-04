# VECI · App móvil

Una sola app de Flutter con dos modos (Cajero y Cliente), pensada para Android de gama baja y para trabajar sin internet (offline primero, [ADR 0004](../../docs/arquitectura/adr/0004-offline-first-outbox-uuid-v7.md)).

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
flutter analyze                                   # análisis estático estricto
flutter test                                      # pruebas
dart format $(find lib test -name "*.dart" ! -name "*.g.dart")   # formato (ancho 100)
dart run build_runner build --delete-conflicting-outputs   # código de Drift
python3 ../../tools/arquitectura/verificar-flutter.py .    # reglas de capas y tamaños
```

## Estructura

- `lib/features/<funcionalidad>/{domain,data,presentation}`: cada funcionalidad con sus capas. `horarios` es la plantilla.
- `lib/core`: base de datos local (Drift), red, inyección de dependencias (Riverpod), rutas (go_router), tema y componentes del sistema de diseño, y observabilidad.
- `packages/veci_api`: cliente Dart **generado** del contrato OpenAPI. No se edita: se regenera con `pnpm generar` desde la raíz.

La guía completa de capas está en [docs/arquitectura/arquitectura-limpia.md](../../docs/arquitectura/arquitectura-limpia.md).
