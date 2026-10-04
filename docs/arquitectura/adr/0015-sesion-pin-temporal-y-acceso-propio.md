# 0015 · Sesión con PIN, token corto validado contra la sesión y PIN temporal

- **Estado:** Propuesta
- **Fecha:** 2026-10-04
- **Requerimientos:** RF-AUT-01 a RF-AUT-06, RNF-SEG-01, RNF-SEG-04

## Contexto

EP-02 pide entrar con celular y PIN de 6 dígitos (y con correo en el panel), bloquear tras 5 intentos, tokens de 15 minutos con renovación, roles por comercio, invitar y suspender cajeros, restablecer PIN (propietario y Soporte VECI) y cerrar a distancia la sesión de un celular perdido. La caja trabaja sin internet en celulares de gama baja ([ADR-0004](0004-offline-first-outbox-uuid-v7.md)) y cada comercio está aislado con RLS ([ADR-0002](0002-multi-comercio-con-rls.md)). El modelo de datos ya traía `identity.user_credentials`, `identity.user_sessions`, `identity.login_attempts`, `identity.credential_types` (con los intentos y minutos de bloqueo) y `identity.role_permissions`.

Siguiendo la [guía de mejor solución](../../guias/ssot-mejor-solucion-no-generica.md), cada decisión abierta se comparó con al menos tres alternativas de ejes distintos (fraude, cajera en hora pico, reutilizar el modelo, costo de operar).

## Decisión

1. **Token de acceso HS256 de 15 minutos, validado contra `identity.user_sessions` en cada petición.** El token lleva `sid` (sesión) y `dev` (dispositivo); el guard consulta la sesión (una lectura por índice) y rechaza si está cerrada o vencida. Así el cierre remoto (HU-02-06) y la salida surten efecto de inmediato, sin listas negras.
2. **Token de renovación opaco `"<sesión>.<secreto>"`**, del que solo se guarda el sha256. Rota en cada renovación; si alguien usa uno viejo se cierra la sesión entera (detección de reuso). La sesión se desliza 30 días.
3. **Un solo mecanismo de PIN temporal con cambio obligatorio** para invitar cajeros (HU-02-04), restablecer el PIN de un cajero desde el panel y el de un cliente desde Soporte VECI (HU-02-05). Entrar con un PIN temporal no abre sesión: entrega un token de cambio de 10 minutos y solo al crear el PIN propio se abre la sesión. Todo queda en auditoría.
4. **Reglas en datos:** intentos y minutos de bloqueo salen de `identity.credential_types`; permisos de `identity.role_permissions` (`@RequierePermiso`); el cupo de cajeros del límite `CASHIERS` del plan ([ADR-0006](0006-estados-y-tipos-como-catalogos.md)). Los PIN fáciles de adivinar (repetidos, secuencias, bloques, lista de comunes) se rechazan en el dominio.
5. **Acceso propio con RLS:** un contexto nuevo `app.user_id` y las políticas `staff_self` y `staff_reads_my_tenants` dejan que la persona vea sus propias membresías antes de elegir negocio, sin abrir la tabla a nadie más.
6. **Clientes:** el panel usa un BFF (rutas `/api/sesion/*` de Next) que guarda el token de renovación en una cookie `httpOnly`, `SameSite=Strict`, limitada a `/api/sesion`; el token de acceso vive en memoria. La app guarda la sesión cifrada con `flutter_secure_storage` (Keystore) y abre sin internet con la sesión guardada.

## Alternativas consideradas

- **Tokens opacos consultados en cada petición** (sin JWT): igual de revocables, pero sin `sid` ni `dev` firmados y con más lógica propia; el JWT corto más la consulta de la sesión da lo mismo con una sola lectura.
- **JWT puro sin consultar la sesión:** más barato, pero el cierre remoto tardaría hasta 15 minutos; un celular perdido en hora pico seguiría vendiendo.
- **Librería de autenticación (Passport, Auth0, Firebase Auth):** suma dependencias y costo, y no conoce PIN de 6 dígitos, membresías por comercio ni RLS.
- **Primer ingreso abierto (el cajero define su PIN sin código):** cualquiera con el celular de otra persona tomaría la cuenta.
- **OTP por SMS o WhatsApp:** es lo ideal, pero el dueño del producto lo dejó para después del MVP (HU-14-01). El PIN temporal se reemplaza por OTP sin tocar el resto.
- **Función `SECURITY DEFINER` para listar mis negocios:** evita políticas nuevas, pero en Neon el dueño de la función y `FORCE RLS` la vuelven frágil; las políticas `staff_self` son explícitas y se prueban igual que las demás.
- **Token de renovación en `localStorage`:** cualquier script inyectado lo robaría; la cookie `httpOnly` lo deja fuera del alcance de JavaScript.

## Consecuencias

- Cada petición autenticada hace una lectura extra (sesión). Es por clave primaria; si algún día pesa, se cachea unos segundos sin perder el cierre remoto práctico.
- `VECI_TOKENS_SECRETO` (32+ caracteres) es obligatorio en staging y producción; cambiarlo cierra todas las sesiones de acceso, no las de renovación.
- La cabecera `x-veci-usuario` queda solo para desarrollo y pruebas locales; en staging y producción se ignora.
- El aviso de registros sin enviar al cerrar la sesión remota usa un puerto que hoy cuenta 0; EP-07 lo conecta a la cola de envío.
