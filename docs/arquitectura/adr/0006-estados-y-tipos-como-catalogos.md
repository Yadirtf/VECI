# 0006 · Estados y tipos como catálogos con transiciones en datos, no enums

- **Estado:** Aceptada
- **Fecha:** 2026-10-04
- **Requerimientos:** RNF-ESC-02, RNF-MAN-01, RF-COM-04 · Pedido explícito del dueño del producto

## Contexto

Los estados (tiquetera activa, suscripción en gracia, cajero suspendido) y los tipos (medio de pago, tipo de negocio, tipo de evento) cambian con el negocio. Escritos en código (`enum`, constantes) o en la base (`ENUM`, `CHECK (... IN ...)`), cada cambio exige migración y despliegue, las reglas asociadas quedan dispersas en `if` por todo el código, y no hay forma de saber desde la base qué cambios de estado son válidos.

## Decisión

1. **Cada estado es una fila** en un catálogo propio de su entidad (`<entidad>_statuses`), con `id smallint` estable, `code` único para el código, `name` para la interfaz y **columnas de regla** (`allows_consumption`, `allows_writes`, `allows_login`, `counts_as_revenue`...).
2. **Cada máquina de estados es una tabla** (`<entidad>_status_transitions`) con los pares permitidos. Un trigger genérico (`core.enforce_status_transition`) rechaza cualquier cambio fuera de ella. Son 14 máquinas de estado ([catálogo completo](../modelo-datos/09-catalogos-y-estados.md)).
3. **Cada tipo o motivo es una fila** en su catálogo: tipos de evento (con el signo del asiento), medios y canales de pago, tipos de negocio, motivos de revocación, de rechazo, de ajuste...
4. **Un catálogo por entidad, no una tabla genérica de estados**, para conservar la integridad referencial (una tiquetera no puede quedar con el estado de una membresía).
5. **Vigencias no son estados.** Lo que solo es "válido desde / hasta" (PIN, sesión, QR, rol asignado) usa `revoked_at` + motivo en catálogo ([convenciones §0.5](../modelo-datos/00-convenciones.md#05-qué-es-estado-y-qué-es-vigencia)).
6. **El código usa `code`, nunca `id`,** y lee las columnas de regla en vez de comparar estados: `if (status.allowsConsumption)`, no `if (status === 'ACTIVE' || ...)`.

## Alternativas consideradas

| Alternativa | Por qué no |
| --- | --- |
| `ENUM` de PostgreSQL | Agregar es fácil, pero quitar o renombrar exige recrear el tipo; no admite columnas de regla ni transiciones. |
| `CHECK (estado IN (...))` | Igual de rígido y repite la lista en cada tabla. |
| Enums en TypeScript/Dart | La base no los conoce: un dato inválido escrito por SQL directo o por otra app pasa sin control. |
| Una tabla `statuses (domain, code)` | Pierde la integridad referencial por entidad. |

## Consecuencias

- Agregar un estado, una transición, un medio de pago o un tipo de negocio es una migración de datos (un `INSERT` revisado en PR), sin cambiar esquema ni, en la mayoría de los casos, código.
- Hay más tablas (71 catálogos y tablas de referencia), pero son diminutas, se cargan una vez y se cachean en la API y en el celular.
- Las reglas del negocio ligadas a estados quedan visibles y consultables en la base, no escondidas en el código.
