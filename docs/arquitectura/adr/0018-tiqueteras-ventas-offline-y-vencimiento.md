# 0018 · Tiqueteras: pizarra de tipos, venta idempotente sin señal y vencimiento por negocio

- **Estado:** Propuesta
- **Fecha:** 2026-10-08
- **Requerimientos:** RF-TIQ-01 a RF-TIQ-06, RF-OFF-01, RF-APC-01, RNF-SEG-05

## Contexto

EP-05 pide que el propietario escriba los tipos de tiquetera que vende, que el cajero venda una en menos de 30 segundos con o sin internet registrando cómo pagó, que el saldo sume las tiqueteras vigentes y se gaste primero la que vence antes, que las vencidas se marquen solas y que el propietario pueda anular o ajustar con motivo sin borrar nada. El modelo ya existía ([ADR-0003](0003-saldos-como-libro-de-eventos.md): el saldo es un libro de eventos; [ADR-0004](0004-offline-first-outbox-uuid-v7.md): ids UUID v7 hechos en el celular). Faltaba decidir qué manda cuando una venta llega tarde, cuándo vence una tiquetera, quién corre el vencimiento y cómo vende la caja sin señal antes del outbox general de EP-07.

Siguiendo la [guía de mejor solución](../../guias/ssot-mejor-solucion-no-generica.md), se compararon alternativas desde tres miradas (la cajera con fila y sin señal, el dueño que revisa la plata, y el cliente que quiere saber cuánto le queda). Las decisiones se tomaron en este orden: correcto y seguro, sirve sin internet y en gama baja, cercano y fácil, simple de mantener, barato.

## Decisión

1. **La pizarra de tipos.** `/tiqueteras/tipos` (permiso `prepaid.manage_package_types`) crea, edita y deja de vender tipos con nombre, unidad del catálogo, cantidad, precio en pesos y vigencia de 1 a 365 días. Un tipo con ventas no cambia de cantidad ni de unidad: lo vendido no se toca. Desactivar no afecta las tiqueteras vendidas.
2. **Catálogo de venta con ETag.** `GET /ventas/catalogo` baja a la caja los tipos activos y los medios de pago con sus canales; responde 304 con `If-None-Match`. La app lo guarda en Drift y vende con lo guardado cuando no hay señal.
3. **Venta idempotente, en línea manda la pizarra y sin señal manda lo que pasó.** El celular genera el `ventaId` (UUID v7). En línea (`sinConexion: false`) el tipo debe estar activo y el precio debe ser el de la pizarra; si no, la cajera ve el precio nuevo y vuelve a cobrar. Sin señal (`sinConexion: true`) la venta ya ocurrió: se guarda con el precio cobrado y la hora del celular (`ocurridaEn`, hasta 5 minutos en el futuro y 30 días atrás) y origen `OFFLINE_SYNC`. Reenviar el mismo id con los mismos datos responde la misma venta (`repetida: true`); con otros datos es `409 VENTA_DISTINTA`.
4. **Vence a la medianoche del negocio.** El día de la compra cuenta como el primero; una de 30 días comprada el 8 de octubre sirve todo el 6 de noviembre, en la zona horaria del negocio. Así nunca vence a media mañana ni depende de la hora del servidor.
5. **El estado se mueve con el libro.** El trigger que mantiene `units_balance` también pasa una tiquetera activa a agotada al llegar a cero y la devuelve a activa si recibe unidades (ajuste o reverso). Vencida y anulada solo las deciden el vencimiento y la anulación.
6. **Vencimiento en el mismo proceso, por negocio.** Un programador dentro de la API corre al arrancar y cada hora: la función `SECURITY DEFINER` `prepaid.tenants_with_due_packages` entrega solo los ids de los negocios con tiqueteras activas ya vencidas, y cada uno se vence en su propia transacción con RLS, con un evento `EXPIRATION` (origen `SYSTEM_JOB`) por el saldo que quedaba. Es idempotente y si un negocio falla sigue con los demás. `VECI_VENCIMIENTO_AUTOMATICO=false` lo apaga (las pruebas lo usan).
7. **Correcciones sin borrar.** Anular (`SALE_VOID`) deja la venta y la tiquetera anuladas y quita el saldo restante; ajustar (`ADJUSTMENT`) suma o resta hasta 500 unidades a una tiquetera vigente sin dejar su saldo en negativo. Ambas exigen los permisos del propietario (`prepaid.void_sale`, `prepaid.adjust_balance`) y un motivo del catálogo (con "Otro" la nota es obligatoria) y quedan en la bitácora con usuario, dispositivo, fecha y hora.
8. **Saldo para cada quien.** En la caja, `/tiqueteras/cliente/:clienteId` da el saldo por unidad, la pila de cartones (arriba el que se gasta primero) y la historia. En la app del cliente, `/mis-tiqueteras` agrupa por negocio con el contexto de la persona y la app guarda una copia cifrada para verla sin internet.
9. **Cola de ventas propia en la caja.** Mientras llega el outbox general de EP-07, cada venta entra primero a la tabla `ventas_pendientes` de Drift y sale cuando el servidor la confirma. Si no hay señal queda guardada con el aviso de no cobrarla otra vez y se reenvía sola cada 2 minutos y al abrir la venta. Si el servidor la rechaza queda marcada con su motivo para que la cajera la quite. Cerrar sesión cuenta esta cola como pendientes.
10. **Diseño propio.** En el panel, la "pizarra" de lo que se vende (lo que ya no se vende se ve borroso) y la cuenta del cliente dentro de su ficha. En la app, vender es una sola pantalla con el botón "Cobrar $ 220.000" y un sello "VENDIDA" al confirmar; el saldo es una colilla con cartones de casillas perforadas.

## Alternativas consideradas

- **Rechazar una venta sin señal si el precio cambió:** el dinero ya se recibió; rechazarla dejaría al cliente pagado y sin saldo. Se respeta lo que pasó y queda marcada como `OFFLINE_SYNC` para revisar.
- **Que el servidor genere el id de la venta:** un reintento después de un corte crearía dos ventas. El id del celular es la llave de idempotencia ([ADR-0004](0004-offline-first-outbox-uuid-v7.md)).
- **Vencer a las 24 horas exactas de la compra:** se vencería a media mañana del último día, en plena hora de almuerzo.
- **`pg_cron` o un cron externo (Render Cron Job):** `pg_cron` no está en todos los Postgres administrados y el cron de Render cobra aparte y necesita otro despliegue. El programador en el proceso es gratis e idempotente; si hay varias instancias, correrlo dos veces no hace daño.
- **Recorrer todas las tiqueteras con un usuario que salta RLS:** más simple pero rompe el aislamiento de [ADR-0002](0002-multi-comercio-con-rls.md). La función definer solo revela ids de negocios.
- **Guardar el saldo solo como columna editable:** se pierde la historia y no hay cómo auditar un ajuste. El libro manda y la columna es caché.
- **Borrar o editar la venta al anular:** RF-TIQ-06 pide corregir sin borrar.
- **Construir ya el outbox genérico de EP-07:** traería sincronización incremental, conflictos y orden causal que EP-05 no necesita. La cola de ventas es pequeña y la reemplazará el outbox sin cambiar la API.
- **Bajar el saldo de todos los clientes a la caja:** gasta datos y expone saldos; el saldo se consulta con señal y sin ella se puede vender igual.

## Consecuencias

- La primera venta sin señal necesita haber bajado el catálogo una vez con internet.
- Una venta sin señal con un precio viejo entra con ese precio; el panel la muestra en la lista de ventas y el propietario puede anularla.
- El vencimiento depende de que la API esté corriendo; al arrancar se pone al día, así que un apagado largo no deja tiqueteras vencidas como activas por más de una vuelta.
- Las unidades vencidas quedan en el libro (`EXPIRATION`) para los reportes de EP-10.
- El descuento FIFO por consumo llega con EP-06; EP-05 ya ordena la pila por vencimiento.
- EP-07 debe migrar `ventas_pendientes` al outbox general.
