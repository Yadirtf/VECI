# 0011 · Librerías para escanear, verificar y guardar sin internet

- **Estado:** Propuesta
- **Fecha:** 2026-10-04
- **Requerimientos:** RNF-REN-01, RNF-CON-01, RNF-CON-02, RF-OFF-01 a RF-OFF-03, HU-00-04

## Contexto

La caja de VECI tiene que leer el QR del cliente, comprobar la firma del comercio (ADR-0005) y guardar el consumo en una bandeja de salida (ADR-0004) en 3 segundos o menos, en un Android de 2 GB y sin internet. La prueba de concepto de la HU-00-04 ([resultados](../poc/hu-00-04-escaneo-offline.md)) comparó opciones y midió las elegidas.

## Decisión

| Necesidad | Librería | Versión probada | Por qué |
| --- | --- | --- | --- |
| Leer QR con la cámara | [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) | 7.4.2 | Usa ML Kit en Android (detección nativa, rápida en gama baja), permite limitar a formato QR y fijar 640x480, mantenimiento activo. |
| Verificar la firma Ed25519 | [`cryptography`](https://pub.dev/packages/cryptography) | 2.9.0 | Ed25519 en Dart puro: funciona igual en Android, iOS y pruebas; solo se usa la clave pública. |
| Base local y bandeja de salida | [`drift`](https://pub.dev/packages/drift) + [`drift_flutter`](https://pub.dev/packages/drift_flutter) | 2.35.1 / 0.3.1 | SQLite tipado, transacciones, consultas reactivas para el contador de pendientes y migraciones. `drift_flutter` reemplaza a `sqlite3_flutter_libs`, que quedó descontinuado. |
| Ids generados en el celular | [`uuid`](https://pub.dev/packages/uuid) | 4.6.0 | Genera UUID v7 (`Uuid().v7()`), ordenados por tiempo, como exige ADR-0004. |
| Inyección de dependencias y estado | [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) | 3.4.3 | Ya elegido en la sección 5.3.4; permite cambiar la base o la red por dobles en las pruebas. |
| Llamadas al servidor | [`http`](https://pub.dev/packages/http) | 1.6.0 | Suficiente para la prueba; el cliente generado desde OpenAPI llega con HU-01-01. |

Configuraciones que forman parte de la decisión:

1. **Formato del token del QR, versión 1:** `V1.<base64url(JSON)>.<base64url(firma)>`, con JSON de llaves cortas (`k` clave, `t` comercio, `a` afiliación, `q` id del QR, `v` versión). La firma cubre los bytes ASCII de `V1.<base64url(JSON)>`. Un token mide 292 caracteres: QR versión 13 con corrección de errores M (69x69 módulos). Si la lectura en gama baja resulta lenta, la versión 2 del formato puede usar bytes en vez de JSON y bajar a unos 165 caracteres (versión 8 aprox.).
2. **Drift guarda las fechas como texto ISO-8601** (`store_date_time_values_as_text`), porque el modo por defecto pierde los milisegundos de la hora real del consumo.
3. **SQLite en modo WAL** con `synchronous = NORMAL`: escrituras rápidas sin bloquear la lectura del contador de pendientes.
4. **Lotes de 100 eventos con id propio.** Un lote sin respuesta se reenvía igual (mismo id, mismos eventos) hasta que el servidor responde.

## Alternativas consideradas

| Alternativa | Por qué no |
| --- | --- |
| `qr_code_scanner` | Descontinuado y sin soporte para las versiones recientes de Android. |
| `flutter_zxing` | Lee bien, pero decodifica en Dart/C++ propio; ML Kit es más rápido en celulares de gama baja y viene probado por Google. |
| `sqflite` | Funciona, pero sin tipos ni consultas reactivas; habría que escribir a mano lo que Drift ya da. |
| `isar` / `hive` | No son SQL: complican el orden por hora real, las transacciones de la bandeja y las migraciones. |
| `pointycastle` para Ed25519 | API de bajo nivel y más código propio para un caso que `cryptography` resuelve en una llamada. |
| NestJS 12 en el servidor de prueba | Es solo ESM y Jest no lo carga en Node 22; la prueba usa NestJS 11. HU-01-01 decide si el backend arranca en ESM con Vitest o en NestJS 11. |

## Consecuencias

- La validación de un QR y el guardado del consumo toman milisegundos (p95 de 6 ms medido en la prueba); casi todo el presupuesto de 3 segundos queda para abrir la cámara y enfocar.
- `mobile_scanner` empaqueta el modelo de ML Kit en el APK (unos 3 MB por arquitectura). Si el tamaño importa, la propiedad de Gradle `dev.steenbakker.mobile_scanner.useUnbundled=true` lo baja de Google Play Services, a cambio de una descarga la primera vez.
- `mobile_scanner` exige Android 6 (API 23) o superior.
- La medición final en un Android de 2 GB de RAM queda pendiente en el documento de resultados; si no cumple, la primera palanca es la resolución de la cámara, no la criptografía.
