# 0002 · Multi-comercio en esquema compartido con `tenant_id`, RLS y llaves compuestas

- **Estado:** Aceptada
- **Fecha:** 2026-10-04
- **Requerimientos:** RNF-SEG-02, RNF-ESC-01, RNF-COS-01, RF-CLI-06, RF-AUT-04

## Contexto

Cientos de comercios comparten VECI y ninguno puede ver datos de otro: una fuga sería un problema legal y destruiría la confianza. A la vez, un cliente debe ver sus saldos en todos los comercios donde está afiliado, y una persona puede trabajar en uno y ser cliente en otro.

## Decisión

1. **Una base, esquemas compartidos, `tenant_id` en toda tabla de negocio.** Es lo más barato de operar y escala a miles de comercios.
2. **Row Level Security forzado** en esas tablas. La API se conecta como `veci_app` (sin `BYPASSRLS`) y fija el contexto por transacción:
   - `SET LOCAL app.tenant_id` para propietario y cajero (comercio activo);
   - `SET LOCAL app.person_id` para el cliente en su app (ve solo sus afiliaciones y lo que cuelga de ellas, en todos sus comercios).
   Sin contexto, las políticas no devuelven nada.
3. **Llaves foráneas compuestas `(tenant_id, id)`.** Cada tabla de negocio declara `UNIQUE (tenant_id, id)` y sus hijas la referencian con ambas columnas. La base rechaza enlazar filas de comercios distintos aunque el código se equivoque.
4. **Datos personales globales protegidos.** `identity.people` no tiene `tenant_id` (una persona, muchos comercios); su política muestra a un comercio solo las personas afiliadas a él o que trabajan en él. La búsqueda de "¿ya existe esta cédula?" se hace con una función `SECURITY DEFINER` que devuelve solo datos enmascarados.
5. **Guard en NestJS** además del RLS: valida la membresía y fija el contexto; RLS es la segunda barrera, no la única.
6. **Con Prisma**, cada petición corre en una transacción interactiva que primero ejecuta `SET LOCAL` (extensión del cliente de Prisma). Con PgBouncer, en modo transacción.

## Alternativas consideradas

| Alternativa | Por qué no |
| --- | --- |
| Una base por comercio | Migraciones ×N, costo ×N, reportes de plataforma imposibles. |
| Un esquema por comercio | Mismo problema de migraciones; el catálogo de PostgreSQL se degrada con miles de esquemas. |
| Solo filtro en el código (`WHERE tenant_id = ?`) | Un olvido en una consulta es una fuga. RLS lo impide por defecto. |

## Consecuencias

- La [prueba de humo](../modelo-datos/sql/90_prueba_de_humo.sql) demuestra que un comercio no lee ni escribe datos de otro y que las FK compuestas impiden mezclarlos.
- Todo índice compuesto empieza por `tenant_id`.
- Los procesos que recorren todos los comercios (vencimientos, avisos) usan `veci_platform` o iteran fijando el contexto de cada comercio.
- Un comercio grande se puede mover a su propia base en el futuro, porque todos sus datos están marcados y no cruzan con otros.
