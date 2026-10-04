# Prueba de concepto · Escaneo offline (HU-00-04)

Código desechable para medir el mayor riesgo técnico de VECI antes del MVP. Resultados en [docs/arquitectura/poc/hu-00-04-escaneo-offline.md](../../docs/arquitectura/poc/hu-00-04-escaneo-offline.md); librerías en [ADR-0011](../../docs/arquitectura/adr/0011-librerias-escaneo-offline.md).

```text
poc/escaneo-offline/
├── app_movil/              # Flutter: cobrar con QR sin internet y sincronizar
│   ├── lib/core/           # Drift, bandeja de salida, ids, red, tema, DI
│   ├── lib/features/escaneo/        # validar QR y registrar consumo
│   ├── lib/features/sincronizacion/ # bajar datos y enviar la bandeja
│   └── test/               # dominio, datos, widgets, rendimiento e integración
├── servidor-prueba/        # NestJS: firma QR y recibe lotes idempotentes
│   └── src/modules/{qr,sincronizacion}/{domain,application,infrastructure,presentation}
└── verificar-arquitectura.py
```

## Requisitos

- Flutter 3.47 o superior (Dart 3.13) y Android SDK para instalar en un celular.
- Node.js 22.

## 1. Servidor de prueba

```bash
cd servidor-prueba
npm install
npm run dev            # http://0.0.0.0:3000
npm test               # unitarias y e2e (1.000 eventos con reenvíos)
npm run lint           # incluye máximo de 300 líneas por archivo y 50 por función
```

| Ruta | Para qué |
| --- | --- |
| `GET /poc/qr-de-prueba` | Hoja imprimible: 5 clientes válidos, uno revocado, uno de otro restaurante y uno con la firma alterada. |
| `GET /poc/datos-offline` | Claves públicas y QR revocados que baja el celular. |
| `POST /poc/sync/batches?simular_corte=0.3` | Recibe un lote; con `simular_corte` corta la respuesta de ese porcentaje de lotes después de guardarlos. |
| `GET /poc/sync/stats` · `POST /poc/sync/reset` | Conteo para comprobar "sin duplicados" y reinicio de la prueba. |

Las claves se crean al arrancar: si reinicias el servidor, vuelve a bajar los datos en la app.

## 2. App móvil

```bash
cd app_movil
flutter pub get
dart run build_runner build      # solo si cambias tablas de Drift (los .g.dart ya están)
flutter test                      # todo menos integración
flutter run --release --dart-define=VECI_API=http://<ip-de-tu-pc>:3000
```

Sin `VECI_API` la app usa `http://10.0.2.2:3000` (el computador visto desde el emulador de Android). El celular y el computador deben estar en la misma red Wi-Fi.

Prueba de punta a punta contra el servidor (necesita el servidor corriendo):

```bash
VECI_API=http://localhost:3000 flutter test test/integration
```

## 3. Probar en el celular

1. **Sincronizar → Bajar datos del negocio** (con internet).
2. Apagar Wi-Fi y datos.
3. **Cobrar**: escanear los QR de la hoja. Los válidos dicen "¡Listo, buen provecho!"; los demás explican por qué no sirven. La barra inferior acumula los tiempos.
4. **Sincronizar → Guardar 1.000 consumos sin internet**, encender la red, activar *Simular cortes de señal* y tocar **Enviar pendientes**. El informe debe mostrar 1.000 eventos únicos en el servidor aunque haya reintentos.

## Arquitectura

```bash
python3 verificar-arquitectura.py   # archivos ≤ 300 líneas, funciones ≤ 50, dominio sin librerías
```
