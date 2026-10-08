# 0019 · Roles acotados: solicitud de registro de negocio, cobertura por municipio y PIN temporal con límites

- **Estado:** Propuesta
- **Fecha:** 2026-10-08
- **Requerimientos:** RF-COM-01, RNF-SEG-02, RNF-ESC-02
- **Reemplaza:** la decisión 1 de [ADR-0016](0016-alta-de-comercios-horarios-y-sedes.md) (el dueño ya no crea el negocio solo)

## Contexto

Antes de seguir con la siguiente épica, el dueño del producto pidió revisar roles, seguridad e integridad con tres reglas:

- Un **cliente** que un negocio afilia actúa como cliente y nunca administra ese negocio.
- Un **cajero** que registra un negocio actúa como cajero y no hace ajustes que no le tocan.
- Una persona **también puede ser dueña** de un negocio: lo pide desde Ajustes de la app.

VECI arranca solo en **Mocoa** y luego crecerá a otros municipios del Putumayo, así que los límites deben quedar desde ya en datos.

La auditoría encontró que los guardas del API (`@RequiereComercio` + `@RequierePermiso`, `@RequierePlataforma`) y la RLS por `app.tenant_id` ya separan bien al cliente, al cajero y al dueño: un cajero recibe 403 en equipo, ajustes, sedes y tiqueteras, y un cliente no entra al contexto de un negocio. Los huecos estaban en tres lugares:

1. **El PIN temporal tomaba cuentas ajenas.** Un dueño que "restablece el PIN" de su cajero, o invita a alguien que ya existe, le pone un PIN temporal a toda la cuenta. Si esa persona era dueña o cajera de otro negocio, o del equipo VECI, el dueño quedaba con acceso a negocios que no son suyos. Soporte VECI también podía restablecer el PIN de una cuenta de Administración.
2. **Cualquiera con sesión creaba negocios** (`POST /comercios`) sin revisión, en cualquier municipio.
3. **No había cobertura:** nada impedía negocios fuera de Mocoa.

## Decisión

1. **El negocio se pide, no se crea.** `POST /solicitudes-de-negocio` radica una solicitud (`tenancy.business_applications`) con los mismos datos del alta, más el municipio. La persona sigue siendo cliente mientras tanto y ve en qué va desde Ajustes (`GET /solicitudes-de-negocio`).
   - Hay una sola solicitud abierta por persona (índice único parcial).
   - Los estados son un catálogo con transiciones ([ADR-0006](0006-estados-y-tipos-como-catalogos.md)): `PENDING` → `APPROVED` (marca `creates_tenant`) o `REJECTED`.
2. **VECI aprueba o rechaza** con `platform.manage_tenants`, en la consola VECI del panel (`/plataforma`).
   - **Aprobar** crea el negocio completo con el mismo alta de ADR-0016, en una sola transacción, y deja al solicitante como `OWNER` activo.
   - **Rechazar** exige un motivo (mínimo 10 letras) que la persona lee.
   - Ambas quedan en la auditoría (`BUSINESS_APPLICATION_SUBMITTED` y `BUSINESS_APPLICATION_REVIEWED`).
   - El registro directo por Administración VECI (`POST /plataforma/comercios`) se mantiene.
3. **RLS para las solicitudes, sin `BYPASSRLS`.**
   - El solicitante ve e inserta solo las suyas, y solo en el estado inicial.
   - La plataforma las ve y decide con la función `identity.current_user_has_platform_permission(...)`, que lee `app.user_id`.
   - Quien decide queda como `reviewed_by_user_id = app.user_id`.
   - La plataforma lee el nombre del solicitante por una política de personas igual de estrecha.
4. **Cobertura en datos.** `core.municipalities.is_served` marca dónde opera VECI; hoy solo Mocoa (86001).
   - Tanto el alta como la solicitud responden 422 (`MUNICIPIO_FUERA_DE_COBERTURA`) fuera de cobertura.
   - El catálogo de municipios que ven el panel y la app trae solo los atendidos.
   - Crecer a otro municipio es un `UPDATE`, sin despliegue.
5. **El PIN temporal no cruza negocios.** Antes de emitir un PIN temporal (restablecer, bienvenida o invitación) se revisa el alcance de la cuenta.
   - Desde un negocio: si la persona es del equipo VECI, o tiene membresía vigente en **otro** negocio, se responde 403 `PIN_TEMPORAL_NO_PERMITIDO`. La persona recupera su acceso por sí misma o con Soporte VECI.
   - Desde Soporte VECI: nunca sobre cuentas del equipo VECI.
6. **Ajustes en la app y la consola VECI en el panel.**
   - La app suma **Ajustes** (desde el inicio de cliente, de cajero y la elección de negocio) con el estado de la solicitud y el botón "Solicitar el registro de mi negocio". Al aprobarse, "Entrar a mi negocio" renueva la sesión y lo deja activo.
   - El panel muestra "Consola VECI" solo a quien tiene `platform.manage_tenants` (`GET /cuenta/permisos-de-plataforma`).

## Alternativas consideradas

- **Dejar el alta libre y revisar después:** crece más rápido, pero en un piloto de un solo municipio no hay presión de volumen y se abriría la puerta a negocios falsos que afilian clientes reales.
- **Rol `BUSINESS_APPLICANT` en vez de una tabla de solicitudes:** mezcla un trámite con permisos y no guarda la historia de rechazos ni quién decidió.
- **Función `SECURITY DEFINER` para aprobar:** evitaría las políticas nuevas, pero en Neon con `FORCE RLS` es frágil (ADR-0015); se prefiere fijar `app.user_id` y `app.tenant_id` en la misma transacción.
- **PIN temporal por negocio (credencial separada por membresía):** aislaría del todo, pero duplica el ingreso y confunde a quien trabaja en dos negocios. Negar el PIN temporal en ese caso cubre el riesgo con mucho menos.
- **Cobertura en una lista del código:** obliga a desplegar para crecer y no la ve la base.

## Consecuencias

- `POST /comercios` desaparece; los clientes que lo usaban pasan a `POST /solicitudes-de-negocio`.
- Un dueño no puede dar PIN temporal a un cajero que también trabaja en otro negocio: ese cajero entra con su propio PIN.
- Falta avisar al solicitante cuando se decide su solicitud (correo o push, con EP-11). Mientras tanto, la persona lo ve en Ajustes.
- El menú del panel aún no se filtra por permiso porque hoy solo entra el `OWNER`. Si se abre el panel a cajeros, hay que filtrar el menú con los permisos de la sesión.
