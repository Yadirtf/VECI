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
| `VECI_ENTORNO` | `desarrollo` | Entorno que se reporta a Sentry |
| `SENTRY_DSN` | vacío (apagado) | Proyecto `veci-mobile` de Sentry |

## Entrar (EP-02)

Con los datos de ejemplo de la semilla, Jhon (cajero de Restaurante La Vecina) entra con el celular **310 000 0102** y el PIN **246813**; Marta (propietaria) con **310 000 0101** y el mismo PIN.

- La sesión se guarda cifrada en el celular (`flutter_secure_storage`, Keystore de Android) y la caja sigue abierta aunque se cierre la app o se vaya el internet. El token de acceso dura 15 minutos y vive en memoria; se renueva solo, una vez aunque varias peticiones lo pidan (`features/sesion/domain/usecases/gestor_sesion.dart`).
- Si la propietaria cierra la sesión del celular desde el panel, al conectarse la app vuelve a la pantalla de ingreso y avisa si hay registros guardados sin enviar (la cuenta real llega con la cola de envío de EP-07).
- El respaldo automático de Android está apagado para que la sesión no viaje a otro celular.

## Clientes y caja (EP-04)

Luz Marina (clienta de la semilla) entra con **310 000 0103** y el PIN **246813**.

- Quien no tiene cuenta la crea desde "¿Primera vez? Crea tu cuenta": una pregunta por pantalla, la política "en corto" y su PIN. Al terminar ve **Mi QR**, un carnet que se guarda en el celular y se muestra sin internet; "Cambiar mi QR" invalida el anterior. **Tus negocios** muestra el QR de cada negocio donde es cliente.
- En la caja, "Atender a quien sigue" abre la ranura: un solo campo para nombre, celular o documento que busca en la copia local (Drift, versión 3 de la base) y un botón para escanear (`mobile_scanner`). Afiliar y registrar necesitan señal; buscar no.
- La copia local guarda solo datos tapados y los últimos 4 números; se actualiza con `If-None-Match` y responde 304 si nada cambió.

## Tiqueteras (EP-05)

- En la caja, la ficha del cliente tiene "Vender tiquetera" y "Ver saldo e historia". Vender usa el catálogo guardado en Drift (versión 4 de la base): sin señal la venta entra a `ventas_pendientes`, se avisa que no se cobre otra vez y se envía sola cada 2 minutos o al volver a vender. Si el servidor la rechaza, queda con su motivo para quitarla.
- El cliente ve "Mis tiqueteras" desde Inicio y Tus negocios: el saldo por negocio, con una copia cifrada para verlo sin internet que se borra al cerrar sesión.
- Cerrar sesión avisa si quedan ventas por enviar.

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
