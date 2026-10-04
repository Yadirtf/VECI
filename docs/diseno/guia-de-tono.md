# Guía de tono de VECI

VECI habla como **un vecino que ayuda**: cercano, respetuoso y claro. Español colombiano del día a día, sin tecnicismos ni regaños. Quien lee puede tener prisa, poca experiencia con el celular o un cliente esperando en la caja.

## Principios

1. **Primero lo importante.** El resultado o la acción va al comienzo: “Te quedan 12 almuerzos”, no “Su saldo actual de unidades disponibles es…”.
2. **Cercano, no confianzudo.** Tuteamos y usamos “veci” para saludar o celebrar, no en cada frase. Nada de “mi amor”, “reina” ni chistes.
3. **Palabras del negocio.** Almuerzos, panes, tiquetera, cliente, caja. Nunca “unidades”, “entidad”, “transacción”, “sincronización” ni códigos de error en pantalla.
4. **Frases cortas.** Una idea por frase y, si cabe, menos de 12 palabras. Números en cifras.
5. **Cuando algo sale mal, decimos qué hacer.** Sin culpar a la persona: “No pudimos leer el QR. Pídele al cliente que suba el brillo”, no “QR inválido”.
6. **Sin internet no es un error.** La caja sigue funcionando; lo decimos con calma: “Guardado en el celular. Lo enviamos cuando vuelva la señal”.
7. **Respeto por los datos.** Nunca mostramos la cédula o el celular completos de un cliente a quien no le corresponde.

## Ejemplos

| Situación | Así sí | Así no |
| --- | --- | --- |
| Consumo registrado | ¡Listo, veci! Te quedan 12 almuerzos. | Transacción exitosa. Saldo: 12. |
| Último consumo | ¡Listo! Este fue el último almuerzo de la tiquetera. | Saldo agotado (0). |
| Saldo bajo | Te quedan 2 almuerzos. ¿Renovamos la tiquetera? | Advertencia: saldo inferior al umbral. |
| Sin saldo | Este cliente ya no tiene almuerzos. Puedes venderle una tiquetera nueva. | Error 422: saldo insuficiente. |
| Tiquetera vencida | Esta tiquetera venció el 3 de octubre. | Paquete expirado. |
| Sin internet | Guardado en el celular. Lo enviamos cuando vuelva la señal. | Error de red. Reintente. |
| Servicio fuera de horario | El almuerzo se sirve de 11:30 a. m. a 3:00 p. m. | Horario no válido para el servicio. |
| QR no se lee | No pudimos leer el QR. Pídele al cliente que suba el brillo. | Código ilegible. |
| QR de otro negocio | Este QR es de otro negocio. Pide el QR de esta tiquetera. | Tenant inválido. |
| Sin acceso | No tienes acceso a este negocio. | 403 Forbidden. |
| Sesión vencida | Primero inicia sesión, veci. | No autenticado. |
| Venta de tiquetera | ¡Listo! Luz Marina tiene 20 almuerzos hasta el 3 de noviembre. | Paquete creado con éxito. |
| Bienvenida | ¡Bienvenido a VECI, veci! Empecemos por tus servicios. | Configuración inicial del sistema. |
| Algo falló del lado de VECI | Algo nos falló. Ya nos avisaron y lo estamos revisando. | Internal Server Error. |

## Botones

Verbo en infinitivo o imperativo corto que diga qué pasa al tocar: **Registrar almuerzo**, **Vender tiquetera**, **Escanear QR**, **Guardar**. Nada de “Aceptar” o “OK” cuando se puede decir la acción.

## Números, fechas y plata

- Plata: `$220.000` (punto de miles, sin decimales; `formatearPesos` de `@veci/shared`).
- Fechas: “3 de octubre” o “hoy”, “mañana”; nunca `2026-10-03` en pantalla.
- Horas: “11:30 a. m.”.
- Singular y plural siempre correctos: “1 almuerzo”, “2 almuerzos” (`VeciSaldo` y `Saldo` ya lo hacen).

## En el código

- Los mensajes que ve una persona (incluidos los de la API, como `message` en los errores) siguen esta guía. El `codigo` del error (`HORARIO_SE_CRUZA`) es para el programa, no para la pantalla.
- Ningún mensaje lleva datos personales (ver [observabilidad](../operacion/observabilidad.md)).
