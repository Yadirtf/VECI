# 0001 · Backend NestJS separado, como monolito modular

- **Estado:** Aceptada
- **Fecha:** 2026-10-04
- **Requerimientos:** RNF-MAN-03, RNF-COS-01, RNF-ESC-01 · Requerimientos §5 y §5.3

## Contexto

VECI tiene dos clientes (app Flutter con modos Cajero y Cliente, panel Next.js) y un único desarrollador. Necesita reglas de negocio en un solo lugar, costos de infraestructura mínimos y la posibilidad de crecer a otros sectores.

## Decisión

Un backend NestJS + TypeScript separado, **un solo servicio desplegable** organizado en módulos por funcionalidad (auth, comercios, clientes, tiqueteras, consumos, sincronizacion, notificaciones, reportes, suscripciones, cumplimiento), cada uno con capas dominio, aplicación, infraestructura y presentación (§5.3). La API es la única que toca PostgreSQL y los servicios externos.

Cada módulo es dueño de su esquema de PostgreSQL ([ADR-0008](0008-esquemas-por-modulo-y-convenciones.md)): solo su capa de infraestructura escribe en sus tablas. Otro módulo que necesite sus datos los pide por la interfaz que el módulo exporta, nunca leyendo sus tablas directamente.

## Alternativas consideradas

| Alternativa | Por qué no |
| --- | --- |
| Microservicios | Varios despliegues, red entre servicios y transacciones distribuidas para una sola persona: costo y complejidad sin beneficio a esta escala. |
| Lógica en Next.js (API routes) | Mezcla panel y negocio; la app Flutter dependería del despliegue del panel. |
| Backend como servicio (Supabase/Firebase directo desde la app) | Las reglas del saldo y la sincronización offline quedarían repartidas en el cliente; difícil de probar y de asegurar. |

## Consecuencias

- Una transacción de base de datos cubre un caso de uso completo (evento + asientos + notificación), sin coordinación distribuida.
- Los límites entre módulos se respetan por convención y por CI (dependency-cruiser), no por la red. Si un módulo necesita escalar aparte en el futuro, ya tiene su esquema y su interfaz: extraerlo es mover código, no rediseñar datos.
- Un despliegue único simplifica operación y costos (RNF-COS-01).
