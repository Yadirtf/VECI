# HU-00-04 · Resultados de la prueba de concepto de escaneo offline

- **Fecha:** 2026-10-04
- **Código:** [`docs/arquitectura/poc/escaneo-offline/`](escaneo-offline/README.md) (código de referencia, no es parte del producto)
- **Librerías elegidas:** [ADR-0011](../adr/0011-librerias-escaneo-offline.md)
- **Requerimientos:** RNF-REN-01, RNF-CON-01

## Qué se quería saber

El mayor riesgo técnico de VECI es la caja sin internet: ¿puede un celular barato leer el QR del cliente, saber que es auténtico y guardar el consumo en 3 segundos o menos, y después entregar todo lo acumulado sin perder ni duplicar nada?

## Qué se construyó

| Pieza | Qué hace |
| --- | --- |
| App Flutter (`app_movil/`) | Pantalla **Cobrar**: lee el QR, valida la firma Ed25519 con la clave pública guardada, revisa comercio y revocación, y guarda el consumo en la bandeja de salida (Drift/SQLite) con id UUID v7 y hora real. Mide cada escaneo. Pantalla **Sincronizar**: baja claves y revocados, envía la bandeja en lotes y corre la prueba de 1.000 eventos. |
| Servidor de prueba (`servidor-prueba/`) | NestJS. Firma QR con una clave Ed25519 por comercio, sirve una hoja imprimible de QR de prueba y recibe lotes de forma idempotente (la llave es el id del evento, como `sync.inbound_events`). Puede cortar a propósito la respuesta de un porcentaje de lotes. |

Ambas siguen la sección 5.3 (carpetas por funcionalidad y capas). `verificar-arquitectura.py` revisa largo de archivos y funciones y que el dominio no importe librerías.

## Resultados

### Criterio 1 · Escanear y validar en 3 segundos o menos

| Medición | Dónde | Resultado |
| --- | --- | --- |
| Validar firma + revisar revocación + guardar en SQLite, 300 escaneos | Dart VM, contenedor de CI (`test/rendimiento`) | p50 **3,7 ms**, p95 **6,0 ms**, máximo 92 ms |
| De abrir la cámara a ver el resultado, 20 escaneos | Android de 2 GB de RAM | **Pendiente**: lo mide Ing. Yadir con la app (ver procedimiento) |

Lectura: la parte que depende de nuestro código usa menos del 1 % del presupuesto. El tiempo real lo dominan encender la cámara y enfocar, que solo se puede medir en el celular. La pantalla Cobrar muestra p50, p95, máximo y cuántos escaneos cumplieron los 3 segundos.

**Procedimiento en el celular de 2 GB**

1. Instalar la app en modo release (ver el README del POC) con el servidor en la misma red Wi-Fi.
2. En **Sincronizar**, tocar *Bajar datos del negocio*. Luego apagar Wi-Fi y datos.
3. Abrir `http://<ip-del-servidor>:3000/poc/qr-de-prueba` en otro equipo o imprimir la hoja.
4. En **Cobrar**, escanear 20 veces los QR (válidos y rechazados), tocando *Escanear otro* entre cada uno.
5. Copiar la barra inferior en la tabla:

| Celular (modelo, RAM, Android) | Escaneos | En 3 s o menos | p50 cámara→resultado | p95 | Máximo |
| --- | --- | --- | --- | --- | --- |
| _por medir_ | | | | | |

Si el p95 pasa de 3 s, la primera palanca es reducir el QR (versión 2 del token, ver ADR-0011) y la resolución de la cámara; la criptografía no es el cuello de botella.

### Criterio 2 · 1.000 eventos offline enviados sin duplicados

| Prueba | Cortes | Resultado |
| --- | --- | --- |
| App (Drift real) contra el servidor de prueba real, lotes de 100 (`test/integration`) | 30 % de respuestas cortadas después de guardar | **1.000 únicos**, 1.000 aplicados, 0 fuera de orden. En la corrida: 2 cortes, 200 reenvíos reconocidos por el servidor, 1.200 entregas en total, 0,3 s. |
| App contra servidor simulado (`test/features/sincronizacion`) | Sin cortes | 10 lotes, 1.000 únicos, 1.000 entregas. |
| Ídem | 30 % de cortes | 1.000 únicos; reenvíos = cortes × 100; orden por hora real intacto. |
| Ídem | Red caída en todo el intento | Nada se pierde: 1.000 siguen pendientes. Al volver la red se reenvía el mismo lote; el servidor reconoce los 100 que ya tenía. |
| Servidor (`servidor-prueba/test`) | Cada lote enviado dos veces | 1.000 únicos de 2.000 entregas; el mismo id con otro contenido se rechaza sin tocar el original. |

Los 1.000 eventos simulan 7 días sin internet (uno cada 10 minutos), como pide RNF-CON-01.

### Criterio 3 · Resultados y librerías documentados

Este documento y [ADR-0011](../adr/0011-librerias-escaneo-offline.md).

## Lo que aprendimos y pasa al MVP

1. **El caso que más duplica no es el error, es el éxito sin respuesta**: el servidor guarda y la señal se cae antes de responder. Por eso el lote conserva su id y sus eventos hasta recibir respuesta, y el servidor responde "ya lo tenía" con el resultado guardado (HU-07-02, HU-07-03).
2. **El mismo id con contenido distinto es un error, no un reintento.** El servidor compara la huella SHA-256 del contenido y lo rechaza sin tocar lo guardado (`payload_sha256` del modelo de datos).
3. **Drift pierde los milisegundos por defecto.** Guardar fechas como texto ISO-8601 conserva la hora real exacta, necesaria para ordenar y para avisar consumos tardíos (RF-OFF-06).
4. **La validación se hace en este orden:** formato → comercio → clave → firma → revocación. Así un QR de otro negocio se explica con un mensaje claro aunque el celular no tenga su clave.
5. **NestJS 12 es solo ESM.** El servidor de prueba usa NestJS 11; HU-01-01 debe decidir ESM + Vitest o NestJS 11 para el backend.
6. **El token de 292 caracteres genera un QR denso (versión 13).** Funciona, pero un formato binario lo reduce a la mitad si la medición en gama baja lo pide.

## Lo que la prueba no cubre

- Login, permisos y comercio en solo lectura: el comercio del cajero es fijo.
- Saldos, tiqueteras y la regla de un consumo por horario: el evento lleva lo necesario, pero el servidor de prueba no aplica reglas de negocio ni abre conflictos.
- Bajada incremental por `sync_version`: el celular baja la lista completa de claves y revocados.
- Persistencia del servidor: guarda en memoria; PostgreSQL llega con HU-01-03 y HU-07-03.
