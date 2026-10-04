# 0007 · Persona, usuario, rol, membresía y afiliación separados

- **Estado:** Aceptada
- **Fecha:** 2026-10-04
- **Requerimientos:** RF-AUT-01 a RF-AUT-05, RF-CLI-01 a RF-CLI-06, RF-EXP-03 · Pedido explícito del dueño del producto

## Contexto

En VECI la misma persona puede ser cliente en un restaurante y cajera en una panadería (RF-AUT-04); un cliente registrado por el cajero existe aunque nunca instale la app (RF-CLI-04); y más adelante un acudiente pagará por un estudiante (RF-EXP-03). Mezclar "quién es", "cómo entra" y "qué puede hacer" en una sola tabla `usuarios` con una columna `rol` lo hace imposible sin duplicar personas.

## Decisión

| Concepto | Tabla | Responde |
| --- | --- | --- |
| Persona | `identity.people` (+ `person_contacts`) | Quién es: documento y nombres. Única en toda la plataforma. |
| Usuario | `identity.users` (+ `user_login_identifiers`, `user_credentials`) | Con qué cuenta entra: celular o correo, PIN o contraseña. 0 o 1 por persona. |
| Rol | `identity.roles` | Un conjunto de permisos con nombre (Propietario, Cajero...). |
| Permiso | `identity.permissions` | Una acción atómica que exige un endpoint. |
| Rol ↔ permiso | `identity.role_permissions` | Qué puede hacer cada rol. |
| Membresía | `tenancy.memberships` | Usuario que **trabaja** en un comercio. |
| Membresía ↔ rol | `tenancy.membership_roles` | Con qué rol(es), con vigencia e historia. |
| Membresía ↔ sede | `tenancy.membership_branches` | En qué sedes. |
| Usuario ↔ rol de plataforma | `identity.user_platform_roles` | Administradores y soporte de VECI. |
| Afiliación | `customers.affiliations` | Persona que es **cliente** de un comercio (no requiere usuario). |

Reglas:

- El personal se relaciona por **usuario** (necesita entrar); el cliente por **persona** (puede no tener cuenta).
- `roles.assignable_to_platform` y `assignable_to_membership`, con llaves foráneas compuestas, impiden asignar un rol de VECI dentro de un comercio o al revés.
- El guard autoriza por **permiso**, no por nombre de rol: cambiar lo que hace un cajero es editar `role_permissions`.
- Las asignaciones se revocan con fecha, no se borran: la historia de permisos queda (RNF-SEG-05).

## Alternativas consideradas

| Alternativa | Por qué no |
| --- | --- |
| Tabla `users` con columna `role` | Un rol por persona en toda la plataforma: incumple RF-AUT-04. |
| `users` con `tenant_id` | Duplica a la persona en cada comercio: incumple RF-CLI-06 y rompe el QR personal. |
| Clientes como membresías con rol Cliente | Obligaría a crear cuenta para clientes sin app y mezclaría personal con clientela en las mismas consultas y límites del plan. |

## Consecuencias

- Agregar un rol (Supervisor, Acudiente) es insertar filas en `roles` y `role_permissions`.
- Una persona puede tener cualquier combinación: cliente en tres comercios, cajera en uno y propietaria en otro, con una sola cuenta y un solo PIN.
- La supresión de datos (habeas data) se hace sobre `people` y se propaga a sus contactos, credenciales y QR, sin tocar los registros contables.
