# Observabilidad (HU-01-07, RNF-OBS-01)

## Qué se envía a Sentry

Un proyecto de Sentry por app: `veci-api` (NestJS), `veci-web` (Next.js) y `veci-mobile` (Flutter). Cada evento lleva:

| Dato | API | Panel | App |
| --- | --- | --- | --- |
| Versión (`release`) | `VECI_VERSION` o el commit de Render | `NEXT_PUBLIC_VECI_VERSION` (commit) | versión de `pubspec.yaml` |
| Entorno | `VECI_ENTORNO` | `NEXT_PUBLIC_VECI_ENTORNO` | `--dart-define=VECI_ENTORNO` |
| Comercio (etiqueta `comercio`) | el comercio activo de la petición | el comercio del panel | el comercio de la caja |

**Sin datos personales (Ley 1581).** Los SDK se configuran para no recoger usuario, IP, cookies, cabeceras, cuerpos, parámetros de consulta, parámetros SQL ni variables locales. Además hay una segunda red antes de enviar: `limpiarDatosPersonales` (en `@veci/shared`, usada por la API y el panel) deja de la petición solo la ruta sin consulta y el método, y borra el usuario y los datos extra; en la app, `beforeSend` borra el usuario y la petición. El comercio se identifica por su id, nunca por nombre ni NIT. Regla para quien escriba código: nunca poner nombres, cédulas, teléfonos ni correos en mensajes de error o en etiquetas.

## Variables

| App | Variable | Dónde |
| --- | --- | --- |
| API | `SENTRY_DSN`, `SENTRY_TRACES_SAMPLE_RATE` | Render |
| Panel | `NEXT_PUBLIC_SENTRY_DSN`, `SENTRY_DSN_WEB` (servidor), `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, `SENTRY_PROJECT_WEB` | Vercel |
| App | `--dart-define=SENTRY_DSN=...` al compilar | CI de la app / máquina de publicación |

Sin DSN, Sentry queda apagado: en local no se envía nada.

## Alertas

Configúrelas una vez en Sentry (*Alerts → Create Alert*):

1. **La sincronización falla de forma repetida** (proyecto `veci-mobile`). La app cuenta los fallos seguidos de sincronización y, al tercero (y cada tres después), envía un evento con la etiqueta `veci.alerta = sincronizacion` y la huella `veci-sincronizacion-falla`. Regla: *Issue alert* · cuando un evento tiene la etiqueta `veci.alerta` igual a `sincronizacion` · notificar por correo (y WhatsApp/Slack si se integra) · como máximo cada 30 minutos.
2. **La API no responde.** *Uptime Monitor* sobre `https://<api-produccion>/salud` cada minuto (el plan gratuito incluye uno). `/salud` responde 503 si la API no llega a la base. Respaldo: [`vigilancia.yml`](../../.github/workflows/vigilancia.yml) consulta staging y producción cada hora y abre un issue con la etiqueta `alerta` si fallan.
3. **Errores nuevos o en aumento** (los tres proyectos). La regla por defecto de Sentry para issues nuevos, más una de *Number of events > 20 in 1 hour*.

## Probar que llega

- API: con `SENTRY_DSN` puesto, forzar un error (por ejemplo, apagar la base y pedir `/horarios`).
- Panel: `global-error.tsx` reporta los errores de renderizado.
- App: la pantalla de horarios sin red y sin copia local registra el fallo en el vigilante; tres seguidos envían la alerta.
