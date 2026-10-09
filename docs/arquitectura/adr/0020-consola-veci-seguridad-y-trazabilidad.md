# 0020 · Consola VECI: segundo factor, lectura entre negocios sin `BYPASSRLS`, bitácora encadenada y detección en datos

- **Estado:** Propuesta
- **Fecha:** 2026-10-09
- **Requerimientos:** RF-PLA-01 a RF-PLA-09, RNF-SEG-05 a RNF-SEG-10, RNF-LEG-02
- **Épica:** [EP-16](../../backlog.md#ep-16--consola-veci-control-seguridad-y-trazabilidad)
- **Amplía:** [ADR-0010](0010-auditoria-y-particionamiento.md) (auditoría) y [ADR-0019](0019-roles-solicitudes-de-negocio-y-cobertura.md) (consola y solicitudes)

## Contexto

El dueño de VECI pidió una consola propia, profesional y segura para controlar toda la plataforma: los negocios y sus clientes, las sesiones, los fraudes, los registros sospechosos y los ataques, con trazabilidad de cada movimiento, porque VECI guarda datos personales y saldos de personas reales.

Hoy la consola VECI (`/plataforma`) solo revisa solicitudes de negocio. El análisis de `develop` encontró además:

- Un rol interno entra al panel solo con contraseña.
- `audit.audit_log` tiene `ip_address` y `request_id`, pero la aplicación no los llena y el API no genera id de petición.
- `identity.sessions` no guarda IP ni navegador.
- El API no limita peticiones ni envía cabeceras de seguridad.
- `audit.audit_log` e `identity.login_attempts` solo tienen la partición `DEFAULT`.
- Los estados `SUSPENDED` de negocio y de usuario existen en los catálogos, pero nada los usa.

La consola tiene que ver más que cualquier otro rol, así que también es el blanco más valioso. Las decisiones buscan que vea todo lo necesario, que nadie la use con una contraseña robada y que lo que hace quede tan registrado como lo que vigila.

## Decisión

1. **Segundo factor obligatorio para los roles internos.**
   - TOTP (RFC 6238) con secreto cifrado en la base y 10 códigos de recuperación guardados con hash.
   - `PrismaVerificadorPlataforma` no devuelve permisos de plataforma si la sesión no se verificó con segundo factor: sin segundo factor, la persona sigue siendo cliente, dueña o cajera, pero no ve la consola.
   - La sesión de consola vence a los 15 minutos sin uso y a las 8 horas en total.
   - **Re-autenticación** para acciones delicadas: el guarda `@RequiereReautenticacion()` exige un código de los últimos 5 minutos al suspender, revelar datos, cerrar sesiones ajenas, cambiar roles internos, aprobar solicitudes y exportar.
2. **Permisos de plataforma separados**, sembrados en `identity.permissions` y repartidos entre `VECI_ADMIN` y `VECI_SUPPORT`: `platform.view_tenants`, `platform.view_people`, `platform.reveal_personal_data`, `platform.manage_sessions`, `platform.suspend`, `platform.manage_team`, `security.view_events`, `security.manage_incidents`, `security.manage_rules`. `platform.manage_tenants` sigue siendo el de las solicitudes.
3. **Leer entre negocios sin `BYPASSRLS`.** Igual que ADR-0019, las políticas RLS suman un `OR identity.current_user_has_platform_permission('platform.view_tenants')` (o el permiso que toque) en las tablas que la consola lee. Las consultas grandes de la consola (directorio, fichas, tablero) van por vistas en un esquema `platform` que ya devuelven los datos enmascarados; el dato completo solo sale por un caso de uso que pide motivo y escribe `PERSONAL_DATA_REVEALED` en la misma transacción.
4. **Contexto de la petición en todo el rastro.**
   - Un middleware fija `X-Request-Id` (lo genera si no llega) y guarda id, IP y agente de usuario en un contexto por petición (`AsyncLocalStorage`).
   - `anotarEnBitacora` los toma de ese contexto, así que los repositorios que ya auditan no cambian.
   - `identity.sessions` suma `created_ip`, `last_ip` y `user_agent`.
   - Sentry recibe el mismo id de petición.
5. **Bitácora encadenada.** `audit.audit_log` suma `prev_hash` y `row_hash` (SHA-256 del contenido más el hash anterior), calculados por un trigger `BEFORE INSERT` que toma un candado consultivo por partición para mantener el orden. Un proceso diario recalcula la cadena y abre un incidente crítico si no cuadra. Sigue siendo inmutable por trigger y sin permisos de `UPDATE` o `DELETE` (ADR-0010).
6. **Esquema `security` para la detección y la respuesta.**
   - `security.events`: solo inserción, particionada por mes. Guarda cada señal (bloqueo por límite, regla que saltó, segundo factor fallido).
   - `security.detection_rules`: código, umbral, ventana, severidad y si está activa. Los valores están en datos y se cambian sin desplegar (ADR-0006).
   - `security.incidents`: estado como catálogo con transiciones; `security.incident_entries` es la línea de tiempo, solo inserción; `security.incident_links` liga negocios, personas, sesiones y entradas de la bitácora.
   - `security.ip_blocks`: IP o rango, motivo, vencimiento y quién lo puso.
7. **Límite de peticiones en PostgreSQL.** Contadores de ventana fija en una tabla `UNLOGGED` (`security.rate_counters`) con `INSERT … ON CONFLICT DO UPDATE`, consultados por un guarda en las rutas de ingreso, registro, solicitudes y PIN. Sirven aunque haya varias instancias, no suman otra pieza que pagar y una pérdida de la tabla tras una caída solo reinicia los contadores. Las cabeceras de seguridad van con `helmet` en el API y con `headers()` en el panel.
8. **Detección por lotes, fuera del camino crítico.** Un proceso cada 5 minutos (cron del API con candado consultivo para que corra una sola vez) evalúa las reglas con SQL sobre `identity.login_attempts`, `security.events`, `audit.audit_log` y, con EP-06, el libro. Agrupa por cuenta, IP o negocio y abre o actualiza incidentes. El ingreso y la caja nunca esperan a la detección.
9. **Alertas por correo** con un proveedor transaccional elegido con la guía SSoT. Los incidentes altos y críticos salen al momento por una bandeja de salida (`security.alert_outbox`) con reintentos; el resumen diario sale a la hora configurada. Los correos no llevan datos personales, solo el enlace a la consola.
10. **Suspender no borra.** Suspender un negocio o una cuenta usa los estados `SUSPENDED` que ya existen, revoca las sesiones con el motivo `PLATFORM_SUSPENSION` y escribe la bitácora. Los eventos que la caja guardó sin señal antes de la suspensión se reciben y quedan marcados para revisión.

## Alternativas consideradas

- **Un SIEM externo (Wazuh, Datadog, Elastic):** más reglas listas, pero es otra pieza que operar y pagar, saca datos personales de la base y rompe el tope de costo (RNF-COS-01). Se puede enviar `security.events` a uno después, sin cambiar el modelo.
- **Un rol de base de datos con `BYPASSRLS` para la consola:** más simple de escribir, pero un error en una consulta expondría todos los negocios a la vez. Con políticas por permiso, cada lectura se puede justificar.
- **Una aplicación de administración aparte:** aísla el código, pero duplica despliegue, sesión y diseño para una sola persona. La consola sigue dentro del panel, con su propio guarda y su propia sesión corta.
- **Segundo factor por SMS:** cuesta por mensaje, depende de un operador y es vulnerable a la duplicación de SIM. Las llaves de acceso (passkeys) son más fuertes, pero su recuperación es más delicada; quedan como segundo factor alterno a futuro.
- **Límite de peticiones en memoria o en Redis:** en memoria no sirve con varias instancias; Redis suma una pieza. PostgreSQL alcanza para el volumen del piloto y de la meta de 500 negocios.
- **Detección en línea en cada petición:** reacciona en segundos, pero hace más lento el ingreso y la caja. Cinco minutos cumplen la meta de alerta (RNF-SEG-09).
- **Auditar las lecturas con triggers:** PostgreSQL no tiene triggers de `SELECT`, y auditar cada lectura llenaría la bitácora de ruido. Se registra lo que importa: revelar un dato completo, abrir una ficha de persona y exportar.

## Consecuencias

- Hay que sembrar los permisos y las acciones de auditoría nuevas y migrar `audit.audit_log`, `identity.sessions` y el esquema `security`. Las entradas viejas de la bitácora empiezan la cadena con `prev_hash` vacío.
- Quien hoy tiene `VECI_ADMIN` debe activar el segundo factor antes de volver a ver la consola. La semilla de acceso de demostración debe incluir un secreto TOTP de prueba.
- El menú del panel pasa a filtrarse por permisos de plataforma (pendiente que dejó ADR-0019).
- El modelo de datos suma una página `12-seguridad-de-plataforma.md` y su DDL cuando se implemente HU-16-02.
- El proceso de particiones que pedía ADR-0010 se hace en HU-16-16 y cubre también `security.events`.
- La consola puede ver datos personales de todos los negocios: la política de tratamiento de datos debe decir que VECI, como encargado, accede a ellos solo para soporte, seguridad y cumplimiento, y que cada acceso queda registrado. El abogado debe revisarlo antes del piloto.
