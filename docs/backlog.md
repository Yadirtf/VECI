# VECI · Backlog del producto

Versión 1.11 · 9 de octubre de 2026 · Ing. Yadir

Este backlog convierte el [Documento de Requerimientos y Recomendaciones Tecnológicas](requerimientos-y-recomendaciones-tecnologicas.md) en épicas e historias de usuario listas para implementar por fases. Tiene **17 épicas** y **97 historias**; cada historia apunta a los requerimientos (RF/RNF) que cumple.

## 1. Cómo leer este backlog

| Elemento | Convención |
| --- | --- |
| Épica | `EP-NN`: un objetivo grande del producto que agrupa historias. |
| Historia | `HU-EE-NN`: EE es el número de la épica. Formato *Como … quiero … para …*. |
| Criterios de aceptación | Condiciones verificables; la historia está terminada solo si todas se cumplen. |
| Prioridad | **Debe** (imprescindible para su fase), **Debería** (antes del lanzamiento comercial), **Podría** (cuando el negocio lo justifique). Igual que en el documento de requerimientos. |
| Puntos | Esfuerzo relativo en escala Fibonacci (1, 2, 3, 5, 8, 13). Las tareas de validación de la Fase 0 no se estiman en puntos. |
| Fase | F0 a F3, según la hoja de ruta del documento de requerimientos. |
| Sprint | Sprint sugerido de 2 semanas para la Fase 1. "—" significa que aún no se planifica. |
| Trazabilidad | IDs de requerimientos (`RF-…`, `RNF-…`) del documento de requerimientos. |

### Definición de listo (antes de empezar una historia)

- Tiene criterios de aceptación claros y sus dependencias están terminadas.
- Si tiene pantalla, existe su diseño en Figma.
- Está estimada y cabe en un sprint (si pesa 13, se divide).
- Se aplicó la [guía de mejor solución (SSoT)](guias/ssot-mejor-solucion-no-generica.md): se compararon alternativas distintas en las decisiones abiertas antes de elegir.

### Definición de terminado

- Todos los criterios de aceptación se cumplen y se probaron en staging.
- Hay pruebas automáticas de la lógica de negocio y CI está en verde.
- Respeta la arquitectura limpia (sección 5.3 del documento de requerimientos): cada archivo en su funcionalidad y capa, sin pasar los límites de líneas.
- Respeta el aislamiento multi-comercio y registra en auditoría lo que corresponda.
- Funciona en un Android de gama baja si toca la app.
- Los textos usan el tono VECI y la documentación (README, OpenAPI) quedó al día.

## 2. Resumen por fases

| Fase | Periodo | Historias | Puntos | Puerta para avanzar |
| --- | --- | --- | --- | --- |
| Fase 0 · Validar | Meses 1 a 2 | 4 | — | Problema validado en entrevistas |
| Fase 1 · MVP y piloto | Meses 3 a 9 | 72 | 299 | Satisfacción de 4/5 o más y cero errores de saldo en el piloto |
| Fase 2 · Lanzamiento comercial | Meses 10 a 15 | 12 | 48 | 15 comercios pagos (punto de equilibrio) |
| Fase 3 · Expansión | Mes 16 en adelante | 9 | 68 | — |

## 3. Épicas

| Épica | Nombre | Fase principal | Objetivo | Historias | Puntos |
| --- | --- | --- | --- | --- | --- |
| [EP-00](#ep-00--validación-y-diseño) | Validación y diseño | Fase 0 | Confirmar el problema con restaurantes reales y dejar listo el diseño antes de escribir código de producto. | 4 | — |
| [EP-01](#ep-01--fundamentos-técnicos) | Fundamentos técnicos | Fase 1 | Dejar la base sobre la que se construye todo: repositorio, CI, base de datos multi-comercio, despliegue y diseño visual. | 10 | 46 |
| [EP-02](#ep-02--autenticación-y-roles) | Autenticación y roles | Fase 1 | Que cada persona entre con su celular y PIN y solo vea y haga lo que su rol permite en cada comercio. | 6 | 24 |
| [EP-03](#ep-03--comercios-sedes-y-horarios) | Comercios, sedes y horarios | Fase 1 | Dar de alta un negocio con su tipo y sus horarios de servicio. | 3 | 13 |
| [EP-04](#ep-04--clientes-y-afiliación-por-qr) | Clientes y afiliación por QR | Fase 1 | Que el cliente se registre solo, tenga su QR personal y quede afiliado a un negocio con un escaneo. | 5 | 21 |
| [EP-05](#ep-05--tiqueteras-y-ventas) | Tiqueteras y ventas | Fase 1 | Configurar los tipos de tiquetera y venderlas registrando el medio de pago. | 5 | 17 |
| [EP-06](#ep-06--consumos-y-escaneo-qr) | Consumos y escaneo QR | Fase 1 | Registrar cada consumo en segundos, de forma trazable y con control antifraude. | 7 | 25 |
| [EP-07](#ep-07--modo-sin-conexión-y-sincronización) | Modo sin conexión y sincronización | Fase 1 | Que la caja nunca se detenga por falta de internet y que todo cuadre al volver la señal. | 7 | 36 |
| [EP-08](#ep-08--app-del-cliente) | App del cliente | Fase 1 | Que el cliente vea sus comercios, su QR y su saldo en todo momento. | 3 | 16 |
| [EP-09](#ep-09--notificaciones) | Notificaciones | Fase 1 | Avisar al cliente de cada consumo y de cuándo renovar. | 4 | 11 |
| [EP-10](#ep-10--panel-del-propietario-y-reportes) | Panel del propietario y reportes | Fase 1 | Darle al dueño la información que hoy no tiene: lo que debe en comidas, lo que vende y quién deja de venir. | 6 | 24 |
| [EP-11](#ep-11--suscripciones-y-administración-veci) | Suscripciones y administración VECI | Fase 2 | Cobrar la suscripción y operar VECI como negocio. | 5 | 24 |
| [EP-12](#ep-12--protección-de-datos-y-auditoría) | Protección de datos y auditoría | Fase 1 | Cumplir la Ley 1581 de 2012 y dejar rastro de toda acción sensible. | 4 | 13 |
| [EP-13](#ep-13--piloto-y-lanzamiento) | Piloto y lanzamiento | Fase 1 | Llevar VECI a los 5 restaurantes piloto, medir y publicar. | 5 | 17 |
| [EP-14](#ep-14--integraciones-futuras) | Integraciones futuras | Fase 3 | Sumar WhatsApp, OTP y pagos en línea cuando el negocio lo justifique. | 3 | 18 |
| [EP-15](#ep-15--expansión-a-otros-sectores) | Expansión a otros sectores | Fase 3 | Llevar el mismo núcleo a cafeterías, panaderías, colegios y tiendas. | 4 | 34 |
| [EP-16](#ep-16--consola-veci-control-seguridad-y-trazabilidad) | Consola VECI: control, seguridad y trazabilidad | Fase 1 | Darle al dueño de VECI control y rastro de toda la plataforma, y defenderla de fraudes y ataques. | 16 | 76 |

## 4. Plan de sprints de la Fase 1

La Fase 1 suma **226 puntos** en 11 sprints de 2 semanas (unas 22 semanas, cerca de 5 meses) a unos 20 puntos por sprint, que es un ritmo realista para una sola persona. Por eso la Fase 1 se amplió de 4 a 7 meses (meses 3 a 9): los 11 sprints de construcción van de los meses 3 a 7 y el piloto con 5 restaurantes dura los meses 8 y 9. Las fases 2 y 3 se corren 3 meses (Fase 2: meses 10 a 15; Fase 3: desde el mes 16). Las suscripciones (EP-11) y el flujo formal de habeas data (HU-12-02) ya se movieron a la Fase 2 porque el piloto es gratuito y esas tareas pueden hacerse a mano.

| Sprint | Objetivo | Historias | Puntos |
| --- | --- | --- | --- |
| S1 | Repositorio, arquitectura limpia, CI, base de datos y diseño visual | HU-01-01, HU-01-02, HU-01-03, HU-01-06, HU-01-09, HU-01-10 | 22 |
| S2 | Modelo de datos, aislamiento multi-comercio e inicio de sesión | HU-01-04, HU-01-05, HU-02-01 | 21 |
| S3 | Roles, cajeros y alta de comercios | HU-02-02, HU-02-03, HU-02-04, HU-02-05, HU-03-01 | 21 |
| S4 | Horarios, política de datos, registro de clientes y QR personal | HU-03-02, HU-04-01, HU-04-02, HU-04-03, HU-12-01 | 19 |
| S5 | Registro asistido, tiqueteras, ventas y validación del QR | HU-04-04, HU-05-01, HU-05-02, HU-05-03, HU-06-02 | 21 |
| S6 | Búsqueda, escaneo, consumos y antifraude | HU-04-05, HU-06-01, HU-06-03, HU-06-04, HU-06-05, HU-06-06 | 21 |
| S7 | Copia local, bandeja de salida y sincronización | HU-07-01, HU-07-02, HU-07-03 | 21 |
| S8 | Conflictos, notificaciones y pruebas offline | HU-07-04, HU-07-05, HU-07-06, HU-07-07, HU-09-01, HU-09-02 | 21 |
| S9 | App del cliente, vencimientos y tablero del propietario | HU-05-04, HU-08-01, HU-08-02, HU-09-03, HU-10-01, HU-10-02 | 21 |
| S10 | Reportes, auditoría, ajustes, revocación de QR y observabilidad | HU-01-07, HU-05-05, HU-06-07, HU-10-03, HU-10-04, HU-12-03, HU-12-04 | 21 |
| S11 | Despliegue, Google Play, capacitación y métricas del piloto | HU-01-08, HU-13-01, HU-13-02, HU-13-03, HU-13-04 | 17 |

### Sprints de la consola VECI (EP-16)

EP-16 tiene prioridad alta: se construye ahora, antes de EP-06, porque el piloto va a manejar datos personales y saldos de clientes reales y hoy la plataforma no tiene segundo factor, límite de peticiones ni forma de suspender una cuenta. Suma 73 puntos en la Fase 1, en 4 sprints de 2 semanas (unas 8 semanas más de construcción). HU-16-10 se planifica junto con EP-06 y HU-16-15 queda para la Fase 2.

| Sprint | Objetivo | Historias | Puntos |
| --- | --- | --- | --- |
| C1 | Entrar seguro y dejar rastro completo | HU-16-01, HU-16-02, HU-16-03 | 18 |
| C2 | Ver y controlar negocios, personas y sesiones | HU-16-04, HU-16-05, HU-16-06, HU-16-07 | 20 |
| C3 | Revisar solicitudes con señales, detectar y alertar | HU-16-08, HU-16-09, HU-16-12 | 16 |
| C4 | Responder a incidentes, tablero, equipo VECI y retención | HU-16-11, HU-16-13, HU-16-14, HU-16-16 | 14 |

## 5. Historias de usuario por épica

### EP-00 · Validación y diseño

**Objetivo:** Confirmar el problema con restaurantes reales y dejar listo el diseño antes de escribir código de producto.

**Resultado esperado:** Entrevistas hechas, prototipo probado con cajeros y modelo de datos aprobado.

**Fase principal:** Fase 0 · Validar · **Historias:** 4 · **Puntos:** —

#### HU-00-01 · Entrevistas de validación

> **Como** fundador de VECI, **quiero** entrevistar a 20 restaurantes de Mocoa que manejan tiquetera, **para** confirmar el problema, cuánto pierden y cuánto pagarían.

**Criterios de aceptación**

- [ ] Existe un guion de entrevista con preguntas sobre control actual, pérdidas, disputas y disposición a pagar.
- [ ] Se registran al menos 20 entrevistas en una hoja con los mismos campos.
- [ ] Hay un resumen con hallazgos, precio validado y cambios a los requerimientos.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | — | F0 | — | — | Plan de negocio, objetivo 1 |

*Nota:* No es desarrollo; se estima en días, no en puntos.

#### HU-00-02 · Prototipo navegable en Figma

> **Como** fundador de VECI, **quiero** prototipar las 5 pantallas clave (escanear, vender, afiliar cliente, saldo del cliente y panel), **para** probar el flujo con cajeros reales antes de programar.

**Criterios de aceptación**

- [ ] El prototipo cubre el flujo completo de afiliar, vender y consumir.
- [ ] Lo prueban al menos 3 cajeros y se mide cuánto tardan sin ayuda.
- [ ] Los textos usan el tono cercano de VECI ("¡Listo, veci!").

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | — | F0 | — | HU-00-01 | RNF-USA-01, RNF-USA-02 |

#### HU-00-03 · Modelo de datos y decisiones de arquitectura

> **Como** desarrollador, **quiero** documentar el modelo de datos y las decisiones de arquitectura (ADR), **para** construir sobre una base acordada y versionada.

**Criterios de aceptación**

- [x] Diagrama entidad-relación con Comercio, Sede, Usuario, Membresía, Afiliación (cliente-comercio), TipoTiquetera, Tiquetera, Movimiento, HorarioServicio, Suscripción y Auditoría.
- [x] ADR para: multi-comercio con RLS, consumos como eventos, offline con outbox, QR firmado, backend NestJS separado.
- [x] Ambos quedan en docs/ del repositorio.

**Entregable:** [docs/arquitectura/](arquitectura/README.md): [modelo de datos](arquitectura/modelo-datos/README.md) con DDL de referencia validado en PostgreSQL y [10 ADR](arquitectura/adr/README.md).

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | — | F0 | — | — | Sección 5.2 del documento |

#### HU-00-04 · Prueba de concepto de escaneo offline

> **Como** desarrollador, **quiero** una prueba de concepto en Flutter que escanee un QR firmado, lo valide y lo guarde en SQLite sin internet, **para** reducir el mayor riesgo técnico antes del MVP.

**Criterios de aceptación**

- [ ] Escanea y valida un QR firmado en 3 segundos o menos en un Android de 2 GB de RAM.
- [x] Guarda 1.000 eventos offline y los envía a un endpoint de prueba sin duplicados.
- [x] Se documentan resultados y librerías elegidas.

Resultados: [docs/arquitectura/poc/hu-00-04-escaneo-offline.md](arquitectura/poc/hu-00-04-escaneo-offline.md). Validar y guardar toma 6 ms (p95); falta medir cámara→resultado en el Android de 2 GB.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | — | F0 | — | — | RNF-REN-01, RNF-CON-01 |

### EP-01 · Fundamentos técnicos

**Objetivo:** Dejar la base sobre la que se construye todo: repositorio, CI, base de datos multi-comercio, despliegue y diseño visual.

**Resultado esperado:** Un cambio en cualquier app pasa por CI y llega a staging sin pasos manuales; ningún comercio puede leer datos de otro.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 10 · **Puntos:** 46

#### HU-01-01 · Monorepo y estructura base

> **Como** desarrollador, **quiero** un repositorio con backend (NestJS), web (Next.js) y mobile (Flutter) como proyectos independientes, **para** tener todo el código, issues y CI en un solo lugar.

**Criterios de aceptación**

- [x] Proyectos independientes backend/, web/ y mobile/, cada uno con sus dependencias (ADR 0014).
- [x] Lint y formato configurados en las tres apps (ESLint, Prettier, flutter analyze).
- [x] README con cómo correr cada app en local.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S1 | HU-00-03 | RNF-MAN-01 |

#### HU-01-02 · Integración continua

> **Como** desarrollador, **quiero** que cada PR ejecute lint, pruebas y build de las tres apps en GitHub Actions, **para** detectar errores antes de fusionar.

**Criterios de aceptación**

- [x] Un PR con lint, pruebas o build fallando queda en rojo.
- [x] Se reporta la cobertura del núcleo (tiqueteras, consumos, sincronización); la meta es 70 % o más.
- [ ] La rama principal está protegida y exige CI en verde.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S1 | HU-01-01 | RNF-MAN-01 |

#### HU-01-03 · Base de datos y migraciones

> **Como** desarrollador, **quiero** PostgreSQL con migraciones versionadas (Prisma) y entornos dev, staging y producción, **para** cambiar el esquema sin perder datos.

**Criterios de aceptación**

- [x] Docker Compose levanta PostgreSQL local con datos de ejemplo.
- [x] Las migraciones corren automáticamente en staging y producción al desplegar.
- [x] Existe un script de datos semilla (comercio demo, cajero, cliente, tiqueteras).

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S1 | HU-01-01 | RNF-MAN-02 |

#### HU-01-04 · Modelo de datos núcleo

> **Como** desarrollador, **quiero** implementar las entidades del núcleo genérico, **para** que restaurantes y futuros sectores usen el mismo modelo.

**Criterios de aceptación**

- [x] Están las tablas Comercio, Sede, Usuario, Membresía, Afiliación, TipoTiquetera, Tiquetera, Movimiento, HorarioServicio, Suscripción y Auditoría.
- [x] El saldo de una tiquetera se calcula desde sus movimientos (compra, consumo, reverso, ajuste) y se guarda en caché transaccional.
- [x] El tipo de negocio y la unidad (almuerzo, café, pan) son datos configurables.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 8 | F1 | S2 | HU-00-03, HU-01-03 | RNF-ESC-02, RF-COM-04 |

#### HU-01-05 · Aislamiento multi-comercio

> **Como** propietario, **quiero** tener la garantía de que ningún otro negocio ve mis datos, **para** confiar mis clientes y ventas a VECI.

**Criterios de aceptación**

- [x] Toda tabla de negocio tiene comercio_id y una política RLS en PostgreSQL.
- [x] Un guard de NestJS fija el comercio activo en cada petición.
- [x] Pruebas automáticas intentan leer y escribir datos de otro comercio y fallan.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 8 | F1 | S2 | HU-01-04 | RNF-SEG-02 |

#### HU-01-06 · Contrato OpenAPI y clientes generados

> **Como** desarrollador, **quiero** generar el contrato OpenAPI desde NestJS y los clientes de Dart y TypeScript, **para** que app y panel nunca se desalineen con el backend.

**Criterios de aceptación**

- [x] El contrato se publica en /docs del API en dev y staging.
- [x] CI regenera los clientes y falla si quedaron desactualizados.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S1 | HU-01-01 | RNF-MAN-01 |

#### HU-01-07 · Observabilidad

> **Como** desarrollador, **quiero** registrar errores de app, panel y API en Sentry con alertas, **para** enterarme de un fallo antes que el cliente.

**Criterios de aceptación**

- [x] Los errores de las tres apps llegan a Sentry con versión y comercio (sin datos personales).
- [ ] Hay una alerta cuando la sincronización falla de forma repetida o la API no responde.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S10 | HU-01-01 | RNF-OBS-01 |

#### HU-01-08 · Despliegue y copias de seguridad

> **Como** desarrollador, **quiero** desplegar API, panel y base de datos administrada con copias diarias, **para** operar con bajo costo y sin miedo a perder datos.

**Criterios de aceptación**

- [ ] API y panel en Render; PostgreSQL administrado en Neon.
- [x] Copia diaria retenida 30 días y una prueba de restauración documentada.
- [ ] Despliegue automático a staging al fusionar y a producción con aprobación.
- [ ] El costo mensual queda por debajo de $150.000 COP.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S11 | HU-01-03 | RNF-DIS-01, RNF-DIS-02, RNF-MAN-02, RNF-COS-01 |

#### HU-01-09 · Sistema de diseño VECI

> **Como** usuario de VECI, **quiero** una interfaz cercana, clara y fácil, **para** sentir a VECI como un vecino aliado y no como un software más.

**Criterios de aceptación**

- [x] Paleta, tipografía y componentes base en Flutter y en el panel web.
- [x] Botones grandes, alto contraste y textos legibles al sol.
- [x] Guía de tono con ejemplos de mensajes ("¡Listo, veci! Te quedan 12 almuerzos").

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S1 | HU-00-02 | RNF-USA-02 |

#### HU-01-10 · Estructura de arquitectura limpia

> **Como** desarrollador, **quiero** que backend, panel web y app móvil nazcan con la estructura de arquitectura limpia y reglas automáticas que la protejan, **para** que VECI escale sin acumular deuda técnica ni archivos llenos de responsabilidades.

**Criterios de aceptación**

- [x] Cada app tiene la estructura de carpetas de la sección 5.3 del documento de requerimientos: módulos por funcionalidad con capas dominio, aplicación, infraestructura y presentación.
- [x] Existe un módulo de ejemplo completo por app (por ejemplo, horarios de servicio) que sirve de plantilla.
- [x] CI falla si un archivo supera 300 líneas o una función 50 líneas.
- [x] CI falla si el dominio importa el framework, la base de datos o la red, o si un módulo importa archivos internos de otro.
- [x] El README explica las capas y dónde va cada tipo de archivo.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S1 | HU-01-01 | RNF-MAN-03, RNF-MAN-01 |

### EP-02 · Autenticación y roles

**Objetivo:** Que cada persona entre con su celular y PIN y solo vea y haga lo que su rol permite en cada comercio.

**Resultado esperado:** Los cuatro roles funcionan en app y panel, con bloqueo por intentos fallidos y restablecimiento de PIN.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 6 · **Puntos:** 24

#### HU-02-01 · Iniciar sesión con celular y PIN

> **Como** cliente, cajero o propietario, **quiero** entrar con mi número de celular y un PIN de 6 dígitos, **para** usar VECI sin recordar contraseñas ni depender de SMS.

**Criterios de aceptación**

- [x] Con celular y PIN correctos, entro y veo la pantalla de mi rol.
- [x] El PIN se guarda con hash (Argon2 o bcrypt), nunca en texto plano.
- [x] Tras 5 intentos fallidos, la cuenta se bloquea temporalmente (15 min) y se registra en auditoría.
- [x] La sesión usa token de acceso de 15 min y token de renovación.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S2 | HU-01-04 | RF-AUT-01, RNF-SEG-01, RNF-SEG-04 |

#### HU-02-02 · Ingreso al panel con correo y contraseña

> **Como** propietario o cajero, **quiero** entrar al panel web también con correo y contraseña, **para** usar el computador del negocio.

**Criterios de aceptación**

- [x] El panel acepta celular + PIN o correo + contraseña.
- [x] Aplican las mismas reglas de bloqueo y expiración.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S3 | HU-02-01 | RF-AUT-02 |

#### HU-02-03 · Roles y permisos por comercio

> **Como** propietario, **quiero** que cada persona tenga un rol en mi negocio (propietario, cajero, cliente), **para** que nadie haga lo que no le corresponde.

**Criterios de aceptación**

- [x] Existen los roles Administrador VECI, Propietario, Cajero y Cliente.
- [x] Cada endpoint verifica rol y comercio activo; sin permiso responde 403.
- [x] Una misma persona puede ser cliente en un comercio y cajero en otro, y elige el comercio activo.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S3 | HU-02-01 | RF-AUT-03, RF-AUT-04 |

#### HU-02-04 · Gestionar cajeros

> **Como** propietario, **quiero** invitar, suspender y retirar cajeros de mi negocio, **para** controlar quién registra ventas y consumos.

**Criterios de aceptación**

- [x] Invito a un cajero por su celular; al entrar define su PIN.
- [x] Un cajero suspendido o retirado no puede iniciar sesión en mi comercio.
- [x] El límite de cajeros del plan se respeta (ver HU-11-01).

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S3 | HU-02-03 | RF-AUT-05 |

#### HU-02-05 · Restablecer PIN

> **Como** cajero o cliente que olvidó su PIN, **quiero** que me lo restablezcan de forma segura, **para** volver a entrar sin perder mi información.

**Criterios de aceptación**

- [x] El propietario restablece el PIN de sus cajeros desde el panel.
- [x] Soporte VECI restablece el PIN de un cliente tras verificar su documento.
- [x] El usuario debe crear un PIN nuevo al entrar y la acción queda en auditoría.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S3 | HU-02-01 | RF-AUT-01 |

*Nota:* A futuro se reemplaza por OTP (HU-14-01).

#### HU-02-06 · Sesión persistente y cierre remoto

> **Como** propietario, **quiero** que el celular del negocio quede con la sesión del cajero abierta y poder cerrarla a distancia, **para** no perder tiempo en hora pico y proteger el negocio si se pierde el celular.

**Criterios de aceptación**

- [x] La sesión del cajero se mantiene en el dispositivo registrado.
- [x] Desde el panel cierro la sesión de un dispositivo; al conectarse, se cierra y avisa si hay eventos sin sincronizar.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debería | 3 | F2 | — | HU-02-04 | RF-AUT-06 |

### EP-03 · Comercios, sedes y horarios

**Objetivo:** Dar de alta un negocio con su tipo y sus horarios de servicio.

**Resultado esperado:** Un restaurante queda configurado en menos de 10 minutos.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 3 · **Puntos:** 13

#### HU-03-01 · Registrar un comercio

> **Como** administrador VECI o dueño, **quiero** registrar un negocio con nombre, NIT o cédula, tipo, logo y contacto, **para** empezar a usar VECI.

**Criterios de aceptación**

- [x] El tipo de negocio sale de un catálogo configurable (restaurante, cafetería, panadería, colegio, tienda).
- [x] Al crearlo se crean su sede principal, su plan de Prueba y la membresía del propietario.

*Nota:* Desde ADR-0019 el dueño no crea el negocio solo: lo solicita desde Ajustes de la app o desde el panel, y Administración VECI lo aprueba o lo rechaza con un motivo. Solo se reciben negocios en municipios atendidos (hoy Mocoa).

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S3 | HU-01-04 | RF-COM-01, RF-COM-04 |

#### HU-03-02 · Horarios de servicio

> **Como** propietario, **quiero** definir mis horarios de servicio (desayuno, almuerzo, cena) por día, **para** que el control antifraude sepa cuándo atiendo.

**Criterios de aceptación**

- [x] Creo, edito y desactivo horarios con hora de inicio y fin por día de la semana.
- [x] Los horarios no pueden solaparse dentro de un mismo día.
- [x] Los cambios llegan a la app del cajero en la siguiente sincronización.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S4 | HU-03-01 | RF-COM-02 |

#### HU-03-03 · Varias sedes

> **Como** propietario con más de un local, **quiero** manejar varias sedes con sus cajeros y consumos, **para** ver cada local por separado y en conjunto.

**Criterios de aceptación**

- [x] Creo sedes y asigno cajeros a una o varias.
- [ ] Consumos y reportes se filtran por sede.
- [x] Solo disponible en el plan Pro.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debería | 5 | F2 | — | HU-03-01, HU-11-01 | RF-COM-03 |

*Nota:* El filtro por sede queda listo en los datos (los consumos y horarios llevan `branch_id`); la pantalla se hace con los consumos (EP-06) y los reportes (EP-10).

### EP-04 · Clientes y afiliación por QR

**Objetivo:** Que el cliente se registre solo, tenga su QR personal y quede afiliado a un negocio con un escaneo.

**Resultado esperado:** Un cliente nuevo queda afiliado y con QR del comercio en menos de 1 minuto, con o sin app.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 5 · **Puntos:** 21

#### HU-04-01 · Auto-registro del cliente

> **Como** cliente, **quiero** registrarme en la app con mi nombre, celular, número de documento y un PIN, **para** tener mi cuenta VECI sin depender del negocio.

**Criterios de aceptación**

- [x] Valido mi celular (10 dígitos) y documento; no se permiten duplicados.
- [x] Antes de crear la cuenta acepto la política de datos y queda la fecha y versión.
- [x] Al terminar veo un mensaje de bienvenida en el tono VECI.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S4 | HU-02-01, HU-12-01 | RF-CLI-01, RF-CLI-05 |

#### HU-04-02 · QR personal

> **Como** cliente, **quiero** tener un QR personal en mi app, **para** mostrarlo en cualquier negocio para afiliarme rápido.

**Criterios de aceptación**

- [x] El QR se genera al registrarme y contiene solo un token firmado, sin datos personales.
- [x] Se ve sin internet.
- [x] Puedo regenerarlo si lo perdí; el anterior queda revocado.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S4 | HU-04-01 | RF-CLI-02, RF-APC-02, RNF-SEG-03 |

#### HU-04-03 · Afiliar un cliente escaneando su QR

> **Como** cajero, **quiero** escanear el QR personal del cliente y afiliarlo a mi negocio, **para** registrarlo en segundos sin teclear sus datos.

**Criterios de aceptación**

- [x] Al escanear veo nombre y documento enmascarado (ej. ****5678) y confirmo.
- [x] Se crea la afiliación y el QR único del cliente en mi comercio, distinto del de otros comercios.
- [x] Si ya estaba afiliado, la app lo indica y abre su ficha.
- [x] El cliente ve el nuevo comercio en su app.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S4 | HU-04-02, HU-02-03 | RF-CLI-02, RF-CLI-03, RF-CLI-06 |

#### HU-04-04 · Registro asistido sin app

> **Como** cajero, **quiero** registrar a un cliente que no tiene la app con nombre, celular y documento, **para** que también pueda usar su tiquetera.

**Criterios de aceptación**

- [x] El registro toma menos de 30 segundos.
- [x] Si el celular o el documento ya existen en VECI, se vincula esa persona sin duplicarla.
- [x] El cajero confirma que el cliente aceptó la política de datos y queda registrado.
- [x] El cliente puede activar después su app con su celular y PIN.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S5 | HU-04-01 | RF-CLI-04, RF-CLI-05, RF-CLI-06 |

#### HU-04-05 · Buscar clientes

> **Como** cajero o propietario, **quiero** buscar un cliente por nombre, celular, documento o QR, **para** encontrarlo rápido en hora pico.

**Criterios de aceptación**

- [x] Los resultados aparecen mientras escribo (desde 3 caracteres).
- [x] La búsqueda funciona sin internet sobre la copia local.
- [x] Solo veo clientes de mi comercio.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S6 | HU-04-03 | RF-CLI-07 |

*Nota:* Implementada en EP-04 (ADR-0017). Afiliar y registrar en la caja necesitan señal; la afiliación sin internet (en cola) llega con el outbox de EP-07.

### EP-05 · Tiqueteras y ventas

**Objetivo:** Configurar los tipos de tiquetera y venderlas registrando el medio de pago.

**Resultado esperado:** El cajero vende una tiquetera en menos de 30 segundos, con o sin internet.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 5 · **Puntos:** 17

#### HU-05-01 · Tipos de tiquetera

> **Como** propietario, **quiero** crear tipos de tiquetera con nombre, unidades, precio y vigencia, **para** vender los paquetes que ofrezco.

**Criterios de aceptación**

- [x] Cada tipo tiene nombre, cantidad de unidades, unidad (almuerzo), precio en COP y vigencia en días.
- [x] Puedo desactivar un tipo sin afectar las tiqueteras ya vendidas.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S5 | HU-03-01 | RF-TIQ-01 |

#### HU-05-02 · Vender una tiquetera

> **Como** cajero, **quiero** vender una tiquetera a un cliente registrando cómo pagó, **para** que su saldo quede cargado de inmediato.

**Criterios de aceptación**

- [x] Elijo el cliente (escaneo o búsqueda), el tipo y el medio de pago: efectivo o transferencia (Nequi, Daviplata o Bancolombia).
- [x] Para transferencias puedo anotar una referencia opcional.
- [x] Se crea un movimiento de compra ligado al QR del cliente en mi comercio.
- [x] Funciona sin internet y se sincroniza después.
- [x] El cliente ve el nuevo saldo en su app.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S5 | HU-05-01, HU-04-03 | RF-TIQ-02, RF-TIQ-03, RF-OFF-01 |

*Nota:* Implementada en EP-05 (ADR-0018). La caja vende sin señal con el catálogo guardado y una cola propia en el celular que se envía sola; la reemplaza el outbox general de EP-07. El cliente se elige escaneando su QR o con la búsqueda de la caja; los dos abren su ficha con el botón "Vender tiquetera".

#### HU-05-03 · Varias tiqueteras activas

> **Como** cliente, **quiero** tener más de una tiquetera activa en un comercio, **para** renovar antes de que se acabe la anterior.

**Criterios de aceptación**

- [x] El consumo descuenta primero la tiquetera que vence antes.
- [x] El saldo mostrado es la suma de las tiqueteras vigentes.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S5 | HU-05-02 | RF-TIQ-04 |

*Nota:* EP-05 suma el saldo de las vigentes y ordena la pila por vencimiento (la primera es la que se gasta primero). El descuento FIFO lo hace el consumo de EP-06.

#### HU-05-04 · Vencimiento automático

> **Como** propietario, **quiero** que las tiqueteras vencidas se marquen solas, **para** no servir comidas de paquetes vencidos y saber cuántas unidades vencieron.

**Criterios de aceptación**

- [x] Un proceso diario marca como vencidas las tiqueteras cuya vigencia terminó.
- [x] El historial se conserva y las unidades vencidas aparecen en reportes.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S9 | HU-05-02 | RF-TIQ-05 |

*Nota:* Corre al arrancar la API y cada hora, por negocio y con RLS; la tiquetera vence a la medianoche del negocio después de su último día. Las unidades vencidas quedan en el libro (`EXPIRATION`) para los reportes de EP-10.

#### HU-05-05 · Anular venta o ajustar saldo

> **Como** propietario, **quiero** anular una venta o ajustar un saldo con un motivo, **para** corregir errores sin borrar la historia.

**Criterios de aceptación**

- [x] Solo el propietario puede hacerlo y el motivo es obligatorio.
- [x] Se crea un movimiento de ajuste o anulación; nada se borra.
- [x] Queda en la auditoría con usuario, fecha y hora.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S10 | HU-05-02, HU-12-03 | RF-TIQ-06, RNF-SEG-05 |

### EP-06 · Consumos y escaneo QR

**Objetivo:** Registrar cada consumo en segundos, de forma trazable y con control antifraude.

**Resultado esperado:** Escanear y descontar toma 3 segundos o menos en un Android de gama baja, sin consumos duplicados.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 7 · **Puntos:** 25

#### HU-06-01 · Escanear y descontar

> **Como** cajero, **quiero** escanear el QR del cliente y descontar su consumo, **para** atender rápido y sin cuaderno.

**Criterios de aceptación**

- [ ] Desde abrir la cámara hasta ver el saldo pasan 3 segundos o menos en un Android de 2 GB.
- [ ] Por defecto se descuenta 1 unidad; puedo indicar otra cantidad.
- [ ] La pantalla confirma nombre, unidades descontadas y saldo restante, con sonido y vibración.
- [ ] El consumo guarda fecha, hora, sede, cajero, dispositivo, unidades y saldo resultante y no se puede editar.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 8 | F1 | S6 | HU-06-02, HU-05-03 | RF-CON-01, RF-CON-02, RNF-REN-01 |

#### HU-06-02 · Validar el QR del comercio

> **Como** propietario, **quiero** que solo se acepten QR válidos de mi negocio, **para** evitar fraudes con QR copiados o alterados.

**Criterios de aceptación**

- [ ] El QR lleva un token firmado (cliente + comercio + versión).
- [ ] La app verifica la firma sin internet con la clave pública del comercio.
- [ ] Un QR manipulado, de otro comercio o revocado se rechaza con un mensaje claro.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S5 | HU-04-03 | RF-CON-04, RNF-SEG-03 |

#### HU-06-03 · Un consumo por horario de servicio

> **Como** propietario, **quiero** que un cliente no consuma dos veces en el mismo horario sin autorización, **para** evitar abusos y errores.

**Criterios de aceptación**

- [ ] Un segundo consumo en el mismo horario se bloquea con aviso.
- [ ] El cajero puede autorizarlo escribiendo un motivo, que queda registrado.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S6 | HU-03-02, HU-06-01 | RF-CON-03 |

#### HU-06-04 · Sin saldo o vencida

> **Como** cajero, **quiero** saber al instante si el cliente no tiene saldo o su tiquetera venció, **para** ofrecerle renovar en ese momento.

**Criterios de aceptación**

- [ ] La app muestra el motivo y un botón para vender una nueva tiquetera.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 2 | F1 | S6 | HU-05-02 | RF-CON-05 |

#### HU-06-05 · Consumo sin celular del cliente

> **Como** cajero, **quiero** registrar el consumo buscando al cliente por nombre o documento, **para** atenderlo aunque no traiga el celular.

**Criterios de aceptación**

- [ ] Busco al cliente y registro el consumo con las mismas reglas que el escaneo.
- [ ] El consumo queda marcado como manual en el historial.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 2 | F1 | S6 | HU-04-05, HU-06-01 | RF-CON-06 |

#### HU-06-06 · Reversar un consumo

> **Como** cajero o propietario, **quiero** reversar un consumo registrado por error, **para** dejar el saldo correcto sin borrar nada.

**Criterios de aceptación**

- [ ] El cajero puede reversar sus consumos de los últimos 10 minutos; después, solo el propietario.
- [ ] El reverso es un movimiento nuevo con motivo y queda en auditoría.
- [ ] El cliente recibe la notificación del reverso.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S6 | HU-06-01 | RF-CON-02 |

#### HU-06-07 · Revocar el QR de un comercio

> **Como** propietario, **quiero** revocar y regenerar el QR de un cliente en mi negocio, **para** bloquear un QR perdido o compartido.

**Criterios de aceptación**

- [ ] El QR anterior queda rechazado en la próxima sincronización de cada dispositivo.
- [ ] El cliente ve el QR nuevo en su app.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 2 | F1 | S10 | HU-06-02 | RNF-SEG-03 |

### EP-07 · Modo sin conexión y sincronización

**Objetivo:** Que la caja nunca se detenga por falta de internet y que todo cuadre al volver la señal.

**Resultado esperado:** 7 días sin internet y 1.000 eventos se sincronizan sin pérdidas ni duplicados; el cliente entiende las notificaciones tardías.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 7 · **Puntos:** 36

#### HU-07-01 · Copia local del comercio

> **Como** cajero, **quiero** que la app tenga en el celular los clientes, tiqueteras y saldos de mi negocio, **para** seguir atendiendo sin internet.

**Criterios de aceptación**

- [ ] Base local en Drift (SQLite) con clientes afiliados, tiqueteras, saldos, horarios y claves de verificación.
- [ ] Se actualiza por cambios incrementales desde la última sincronización.
- [ ] Los datos locales se cifran y se borran al cerrar la sesión.
- [ ] La sincronización solo baja cambios, para gastar menos de 20 MB de datos al mes por cajero.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 8 | F1 | S7 | HU-01-04, HU-00-04 | RF-OFF-03, RNF-CON-02 |

#### HU-07-02 · Bandeja de salida offline

> **Como** cajero, **quiero** que ventas y consumos se guarden en el celular cuando no hay internet, **para** no perder ningún registro.

**Criterios de aceptación**

- [ ] Cada evento lleva un ID único generado en el dispositivo (UUID v7) y la hora real en que ocurrió.
- [ ] Los eventos se guardan en una bandeja de salida y se envían en orden al volver la conexión.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S7 | HU-07-01 | RF-OFF-01, RF-OFF-02 |

#### HU-07-03 · Sincronización idempotente

> **Como** propietario, **quiero** que al sincronizar nada se pierda ni se duplique, **para** que los saldos siempre cuadren.

**Criterios de aceptación**

- [ ] El endpoint recibe lotes de eventos y responde el estado de cada uno.
- [ ] Reenviar el mismo evento no lo duplica.
- [ ] Los eventos se aplican según su hora real de ocurrencia.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 8 | F1 | S7 | HU-07-02 | RF-OFF-02, RNF-CON-01 |

#### HU-07-04 · Resolver conflictos

> **Como** propietario, **quiero** ver y resolver los conflictos que aparezcan al sincronizar, **para** decidir yo qué pasó, por ejemplo con un doble consumo en dos sedes.

**Criterios de aceptación**

- [ ] Se detectan dobles consumos en el mismo horario y saldos negativos.
- [ ] El panel lista los conflictos con sus detalles.
- [ ] El propietario acepta o reversa; la decisión queda en auditoría.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S8 | HU-07-03 | RF-OFF-04 |

#### HU-07-05 · Indicador de pendientes

> **Como** cajero, **quiero** ver cuántos registros faltan por sincronizar y desde cuándo, **para** saber si debo buscar señal.

**Criterios de aceptación**

- [ ] La app muestra los pendientes y la hora de la última sincronización.
- [ ] Si hay pendientes de más de 24 horas, aparece un aviso visible.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 2 | F1 | S8 | HU-07-02 | RF-OFF-05 |

#### HU-07-06 · Notificación tardía explicada

> **Como** cliente, **quiero** que si un consumo me llega tarde la notificación diga por qué, **para** no sentir que me cobraron algo extraño.

**Criterios de aceptación**

- [ ] Si el evento se sincroniza más de 5 minutos después del consumo, el texto incluye la hora real y el motivo.
- [ ] Ejemplo: "[Negocio] registró tu consumo de 1 almuerzo a las 12:40. Te llega ahora porque en ese momento no había internet."
- [ ] Si el consumo se sincroniza de inmediato, se usa la notificación normal (HU-09-02).

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S8 | HU-07-03, HU-09-02 | RF-OFF-06, RF-NOT-01 |

#### HU-07-07 · Pruebas de resiliencia offline

> **Como** desarrollador, **quiero** pruebas automáticas de días sin internet, muchos eventos y cortes a mitad de la sincronización, **para** asegurar que la función más crítica no falle en el piloto.

**Criterios de aceptación**

- [ ] Se simulan 7 días offline con 1.000 eventos y se sincronizan sin pérdidas ni duplicados.
- [ ] Un corte en mitad de un lote se recupera al reintentar.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S8 | HU-07-03 | RNF-CON-01, RNF-MAN-01 |

### EP-08 · App del cliente

**Objetivo:** Que el cliente vea sus comercios, su QR y su saldo en todo momento.

**Resultado esperado:** El cliente consulta su saldo y su QR aunque no tenga datos móviles.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 3 · **Puntos:** 16

#### HU-08-01 · Mis comercios

> **Como** cliente, **quiero** ver mis comercios con su saldo, vencimiento, QR e historial, **para** saber cuánto me queda en cada uno.

**Criterios de aceptación**

- [ ] Lista de comercios con saldo y fecha de vencimiento.
- [ ] El detalle muestra el QR de ese comercio y el historial de compras y consumos.
- [ ] Funciona sin internet con el último dato guardado y la hora de actualización.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S9 | HU-04-03, HU-05-02 | RF-APC-01, RF-APC-02 |

#### HU-08-02 · Saldo por enlace web

> **Como** cliente sin la app, **quiero** consultar mi saldo desde un enlace, **para** saber cuánto me queda sin instalar nada.

**Criterios de aceptación**

- [ ] El enlace tiene un token no adivinable y muestra solo comercio, saldo y vencimiento.
- [ ] El cliente o el cajero pueden compartirlo y regenerarlo.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S9 | HU-05-02 | RF-APC-03 |

#### HU-08-03 · Comprar o renovar desde la app

> **Como** cliente, **quiero** comprar o renovar mi tiquetera desde la app pagando en línea, **para** no tener que hacerlo en caja.

**Criterios de aceptación**

- [ ] Elijo el tipo de tiquetera y pago con la pasarela.
- [ ] Cuando el pago se confirma, el saldo se carga solo.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Podría | 8 | F3 | — | HU-14-03 | RF-APC-04 |

### EP-09 · Notificaciones

**Objetivo:** Avisar al cliente de cada consumo y de cuándo renovar.

**Resultado esperado:** Cada consumo con internet genera una notificación en menos de 10 segundos.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 4 · **Puntos:** 11

#### HU-09-01 · Notificaciones push

> **Como** desarrollador, **quiero** integrar Firebase Cloud Messaging en Android e iOS, **para** enviar avisos gratis a los clientes.

**Criterios de aceptación**

- [ ] La app registra y renueva el token del dispositivo.
- [ ] El backend envía notificaciones con reintentos y registra fallos.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S8 | HU-01-01 | RF-NOT-01 |

#### HU-09-02 · Aviso inmediato de consumo

> **Como** cliente, **quiero** recibir de inmediato una notificación con el negocio, lo descontado y mi saldo, **para** estar tranquilo de que me cobraron bien.

**Criterios de aceptación**

- [ ] Llega en menos de 10 segundos si hay internet.
- [ ] También se notifica cuando se compra una tiquetera o se reversa un consumo.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S8 | HU-09-01, HU-06-01 | RF-NOT-01 |

#### HU-09-03 · Aviso de renovación

> **Como** cliente, **quiero** que me avisen cuando me queden pocas unidades, **para** renovar a tiempo.

**Criterios de aceptación**

- [ ] El aviso llega al quedar 2 unidades (el propietario puede cambiar el número).
- [ ] Se envía una sola vez por tiquetera.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 2 | F1 | S9 | HU-09-02 | RF-NOT-02 |

#### HU-09-04 · Resumen diario al propietario

> **Como** propietario, **quiero** recibir un resumen diario de ventas y consumos, **para** saber cómo fue el día sin abrir el panel.

**Criterios de aceptación**

- [ ] Llega a una hora configurable con ventas, consumos y renovaciones del día.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Podría | 3 | F2 | — | HU-10-03 | RF-NOT-04 |

### EP-10 · Panel del propietario y reportes

**Objetivo:** Darle al dueño la información que hoy no tiene: lo que debe en comidas, lo que vende y quién deja de venir.

**Resultado esperado:** El dueño conoce su dinero comprometido y sus renovaciones sin abrir el cuaderno.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 6 · **Puntos:** 24

#### HU-10-01 · Dinero comprometido

> **Como** propietario, **quiero** ver cuántas comidas debo y cuánto dinero representan, **para** conocer mi pasivo real.

**Criterios de aceptación**

- [ ] El tablero muestra unidades pendientes por servir y su valor en COP a la fecha.
- [ ] Se puede ver por tipo de tiquetera.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S9 | HU-05-02 | RF-REP-01 |

#### HU-10-02 · Renovaciones e inactivos

> **Como** propietario, **quiero** ver clientes próximos a terminar, vencidos e inactivos, **para** llamarlos o ofrecerles renovar.

**Criterios de aceptación**

- [ ] Tres listas: próximos a terminar (N unidades o menos), vencidos e inactivos (sin consumo en N días).
- [ ] N es configurable.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S9 | HU-05-04 | RF-REP-02 |

#### HU-10-03 · Ventas e ingresos

> **Como** propietario, **quiero** ver ventas e ingresos por día, semana y mes y por medio de pago, **para** entender mi negocio.

**Criterios de aceptación**

- [ ] Gráficos y totales por periodo y medio de pago (efectivo y transferencias).
- [ ] Los totales cuadran con los movimientos.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | S10 | HU-05-02 | RF-REP-03 |

#### HU-10-04 · Historial auditable por cliente

> **Como** propietario, **quiero** ver cada compra, consumo y ajuste de un cliente con quién lo hizo, **para** resolver un reclamo en segundos.

**Criterios de aceptación**

- [ ] El historial muestra fecha, hora, tipo, unidades, cajero, sede y saldo resultante.
- [ ] Los consumos registrados offline indican su hora real y la de sincronización.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S10 | HU-06-01 | RF-REP-04 |

#### HU-10-05 · Exportar reportes

> **Como** propietario, **quiero** exportar los reportes a Excel o PDF, **para** compartirlos con mi contador.

**Criterios de aceptación**

- [ ] Cada reporte tiene botón de exportar con el filtro aplicado.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debería | 3 | F2 | — | HU-10-03 | RF-REP-05 |

#### HU-10-06 · Cierre de caja

> **Como** propietario o cajero, **quiero** hacer el cierre de caja diario por cajero, **para** cuadrar el efectivo y las transferencias del día.

**Criterios de aceptación**

- [ ] Muestra ventas por medio de pago y consumos del cajero en el día.
- [ ] El cajero registra el efectivo contado y queda la diferencia.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debería | 5 | F2 | — | HU-10-03 | RF-REP-06 |

### EP-11 · Suscripciones y administración VECI

**Objetivo:** Cobrar la suscripción y operar VECI como negocio.

**Resultado esperado:** Los planes limitan lo que corresponde y un comercio vencido pasa a solo lectura sin perder datos.

**Fase principal:** Fase 2 · Lanzamiento comercial · **Historias:** 5 · **Puntos:** 24

#### HU-11-01 · Planes y límites

> **Como** administrador VECI, **quiero** que cada comercio tenga un plan con sus límites, **para** cobrar según el valor que recibe.

**Criterios de aceptación**

- [ ] Planes: Prueba (30 días, 30 clientes), Básico (1 sede, 100 clientes activos, 2 cajeros) y Pro (ilimitado, varias sedes).
- [ ] Al llegar a un límite, la app lo explica y sugiere cambiar de plan.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F2 | — | HU-03-01 | RF-SUS-01 |

*Nota:* El piloto es gratuito, por eso se hace en la Fase 2.

#### HU-11-02 · Registrar pagos de suscripción

> **Como** administrador VECI, **quiero** registrar a mano los pagos de suscripción y su vigencia, **para** llevar el control de cobros.

**Criterios de aceptación**

- [ ] Registro fecha, valor, medio (Nequi, transferencia, efectivo) y periodo pagado.
- [ ] Se calcula la próxima fecha de pago y el estado del comercio.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F2 | — | HU-11-01 | RF-SUS-02 |

#### HU-11-03 · Gracia y solo lectura

> **Como** propietario, **quiero** tener unos días de gracia si me atraso, sin perder mis datos, **para** no quedar bloqueado de un momento a otro.

**Criterios de aceptación**

- [ ] Al vencer hay 7 días de gracia con aviso diario.
- [ ] Después el comercio queda en solo lectura: no vende ni registra consumos, pero ve todo.
- [ ] Nunca se borran datos por falta de pago.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F2 | — | HU-11-02 | RF-SUS-03 |

#### HU-11-04 · Consola de administración VECI

> **Como** administrador VECI, **quiero** una consola con todos los comercios, su plan, estado y uso, **para** dar soporte y vender.

**Criterios de aceptación**

- [ ] Lista con filtros por estado y plan.
- [ ] Desde aquí se hacen los restablecimientos de PIN de clientes (HU-02-05).

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F2 | — | HU-11-01 | RF-AUT-03 |

*Nota:* Durante el piloto estas tareas se hacen a mano. La lista de negocios con su estado y su ficha llegan antes con EP-16 (HU-16-04); esta historia suma el plan y el uso cuando exista EP-11.

#### HU-11-05 · Cobro automático

> **Como** administrador VECI, **quiero** cobrar la suscripción de forma recurrente con pasarela, **para** no depender de pagos manuales.

**Criterios de aceptación**

- [ ] El cobro mensual o anual se hace por la pasarela y actualiza la vigencia.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Podría | 8 | F3 | — | HU-14-03 | RF-SUS-04 |

### EP-12 · Protección de datos y auditoría

**Objetivo:** Cumplir la Ley 1581 de 2012 y dejar rastro de toda acción sensible.

**Resultado esperado:** Toda autorización y toda acción sobre saldos queda registrada y es consultable.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 4 · **Puntos:** 13

#### HU-12-01 · Política de datos y autorización

> **Como** cliente, **quiero** leer y aceptar la política de tratamiento de datos, **para** saber qué hace VECI con mi información.

**Criterios de aceptación**

- [x] La política está publicada y versionada.
- [x] Se guarda quién aceptó, qué versión y cuándo.
- [ ] Si la versión cambia, se pide aceptar de nuevo.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S4 | HU-01-04 | RF-CLI-05, RNF-LEG-01 |

*Nota:* EP-04 publica la versión 1.0 (`GET /politica-de-datos`, página `/politica-de-datos` del panel) y guarda el consentimiento al registrarse; un registro con una versión vieja se rechaza. Pedir aceptar de nuevo a quien ya tiene cuenta queda pendiente para cuando se publique la 1.1. El texto lo debe revisar un abogado antes del piloto.

#### HU-12-02 · Derechos de habeas data

> **Como** cliente, **quiero** pedir ver, corregir o eliminar mis datos, **para** ejercer mis derechos.

**Criterios de aceptación**

- [ ] La solicitud queda registrada con fecha y plazo legal (10 días hábiles consultas, 15 reclamos).
- [ ] Al eliminar, los datos personales se anonimizan pero los movimientos contables se conservan.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F2 | — | HU-12-01 | RF-CLI-08, RNF-LEG-01 |

*Nota:* En el piloto se atiende por un procedimiento manual documentado.

#### HU-12-03 · Bitácora de auditoría

> **Como** propietario, **quiero** que toda venta, consumo, ajuste y cambio de permisos quede registrado, **para** saber siempre quién hizo qué.

**Criterios de aceptación**

- [ ] Los registros de auditoría no se pueden editar ni borrar desde la aplicación.
- [ ] El propietario consulta la bitácora de su comercio con filtros.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S10 | HU-01-04 | RNF-SEG-05 |

#### HU-12-04 · Datos mínimos y enmascarados

> **Como** cliente, **quiero** que el cajero vea solo lo necesario de mí, **para** proteger mi información.

**Criterios de aceptación**

- [ ] El cajero ve nombre y documento enmascarado; el propietario ve el dato completo.
- [ ] Solo se piden nombre, celular y documento.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 2 | F1 | S10 | HU-04-03 | RNF-LEG-02 |

### EP-13 · Piloto y lanzamiento

**Objetivo:** Llevar VECI a los 5 restaurantes piloto, medir y publicar.

**Resultado esperado:** Piloto de 2 meses con satisfacción de 4/5 o más y cero errores de saldo.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 5 · **Puntos:** 17

#### HU-13-01 · Publicar en Google Play

> **Como** fundador de VECI, **quiero** publicar la app Android en prueba cerrada, **para** instalarla en los restaurantes piloto.

**Criterios de aceptación**

- [ ] La app está en la pista de prueba cerrada con ficha y política de privacidad.
- [ ] El instalable pesa menos de 25 MB y funciona en Android 8 o superior.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S11 | HU-01-08 | RNF-COM-01, RNF-COM-02 |

#### HU-13-02 · Capacitación y bienvenida

> **Como** cajero nuevo, **quiero** aprender a afiliar, vender y escanear en 10 minutos, **para** usar VECI desde el primer día.

**Criterios de aceptación**

- [ ] Guía de una página y video corto.
- [ ] Recorrido de bienvenida en la app la primera vez.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S11 | HU-06-01 | RNF-USA-01 |

#### HU-13-03 · Métricas del piloto

> **Como** fundador de VECI, **quiero** medir tiempos, errores de saldo y satisfacción, **para** decidir si se pasa a la Fase 2.

**Criterios de aceptación**

- [ ] Se mide el tiempo de registro de consumo y los errores de saldo reportados.
- [ ] Encuesta de satisfacción a dueños y cajeros (meta 4/5 o más).

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S11 | HU-13-01 | RNF-USA-03, RNF-REN-01 |

#### HU-13-04 · Pruebas de rendimiento

> **Como** desarrollador, **quiero** probar rendimiento en un celular de gama baja y en la API, **para** cumplir las metas antes del piloto.

**Criterios de aceptación**

- [ ] El escaneo cumple 3 segundos o menos en un Android de 2 GB.
- [ ] La API responde el 95 % en menos de 500 ms con carga de 50 comercios.
- [ ] El panel carga en menos de 3 segundos en 3G.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | S11 | HU-01-08 | RNF-REN-01, RNF-REN-02, RNF-REN-03, RNF-ESC-01 |

#### HU-13-05 · Publicar en App Store

> **Como** fundador de VECI, **quiero** publicar la app en iOS, **para** atender clientes con iPhone.

**Criterios de aceptación**

- [ ] La app pasa la revisión de Apple y funciona en iOS 14 o superior.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debería | 5 | F2 | — | HU-13-01 | RNF-COM-01 |

### EP-14 · Integraciones futuras

**Objetivo:** Sumar WhatsApp, OTP y pagos en línea cuando el negocio lo justifique.

**Resultado esperado:** Las integraciones se activan por plan sin cambiar el flujo base.

**Fase principal:** Fase 3 · Expansión · **Historias:** 3 · **Puntos:** 18

#### HU-14-01 · Código de verificación por WhatsApp o SMS

> **Como** cliente, **quiero** recibir un código para registrarme o recuperar mi PIN, **para** no depender de soporte.

**Criterios de aceptación**

- [ ] El código expira en 5 minutos y tiene límite de intentos.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Podría | 5 | F3 | — | HU-02-05 | RF-AUT-01 (a futuro) |

#### HU-14-02 · Avisos por WhatsApp

> **Como** cliente del plan Pro, **quiero** recibir mi QR y avisos de saldo bajo por WhatsApp, **para** no depender de la app.

**Criterios de aceptación**

- [ ] Se usan plantillas aprobadas de WhatsApp Cloud API.
- [ ] Solo se envían si el comercio tiene plan Pro y el cliente lo autorizó.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Podría | 5 | F3 | — | HU-11-01 | RF-NOT-03 |

#### HU-14-03 · Pagos en línea con Wompi

> **Como** cliente o propietario, **quiero** pagar en línea con Nequi, PSE o tarjeta, **para** comprar tiqueteras y suscripciones sin efectivo.

**Criterios de aceptación**

- [ ] Integración con Wompi con confirmación por webhook firmado.
- [ ] Los pagos fallidos no cargan saldo.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Podría | 8 | F3 | — | — | RF-APC-04, RF-SUS-04 |

### EP-15 · Expansión a otros sectores

**Objetivo:** Llevar el mismo núcleo a cafeterías, panaderías, colegios y tiendas.

**Resultado esperado:** Un nuevo tipo de negocio se habilita por configuración, sin cambiar el modelo central.

**Fase principal:** Fase 3 · Expansión · **Historias:** 4 · **Puntos:** 34

#### HU-15-01 · Paquetes de otros productos

> **Como** dueño de cafetería o panadería, **quiero** vender paquetes de cafés, panes u otros productos, **para** usar VECI en mi negocio.

**Criterios de aceptación**

- [ ] La unidad y el nombre del paquete son configurables por tipo de negocio, sin cambiar el modelo.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Podría | 5 | F3 | — | HU-05-01 | RF-EXP-01, RNF-ESC-02 |

#### HU-15-02 · Catálogo e inventario básico

> **Como** dueño de tienda o panadería, **quiero** registrar productos sueltos con su inventario, **para** vender y controlar existencias.

**Criterios de aceptación**

- [ ] Catálogo con precio y existencias; cada venta descuenta inventario.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Podría | 13 | F3 | — | HU-15-01 | RF-EXP-02 |

*Nota:* Se recomienda dividirla al planearla.

#### HU-15-03 · Colegios y acudientes

> **Como** acudiente, **quiero** recargar y consultar los consumos de mis hijos, **para** controlar su alimentación en el colegio.

**Criterios de aceptación**

- [ ] Un acudiente puede tener varios estudiantes y ver sus consumos.
- [ ] Aplican reglas de protección de datos de menores.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Podría | 8 | F3 | — | HU-15-01 | RF-EXP-03 |

#### HU-15-04 · Fiado con límite

> **Como** dueño de tienda de barrio, **quiero** dar crédito a mis clientes con un límite, **para** controlar lo que me deben.

**Criterios de aceptación**

- [ ] Cada cliente tiene un cupo; no se puede pasar sin autorización del dueño.
- [ ] El cliente ve su deuda en la app.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Podría | 8 | F3 | — | HU-04-03 | RF-EXP-04 |

### EP-16 · Consola VECI: control, seguridad y trazabilidad

**Objetivo:** Darle al dueño de VECI una consola propia y segura para ver y controlar toda la plataforma: negocios, personas, sesiones y movimientos, detectar fraudes y ataques a tiempo y dejar rastro verificable de cada acción, incluida la suya.

**Resultado esperado:** Desde `/plataforma`, con segundo factor, el dueño de VECI responde en minutos quién hizo qué, cuándo, desde dónde y en qué negocio; recibe una alerta cuando algo se sale de lo normal; puede cortar el acceso de una cuenta, un dispositivo o un negocio sin borrar datos; y cada vista de datos personales queda registrada.

**Fase principal:** Fase 1 · MVP y piloto · **Historias:** 16 · **Puntos:** 76 · **Prioridad de la épica:** alta, se construye antes de EP-06 (ver sección 4).

**Punto de partida (lo que ya existe y no se repite):**

- La consola VECI en `/plataforma` solo muestra las solicitudes de negocio y se abre a quien tiene `platform.manage_tenants` (ADR-0019, PR #114). Esta épica la convierte en la consola completa.
- Los guardas `@RequierePlataforma`, la función `identity.current_user_has_platform_permission(...)` y la RLS sin `BYPASSRLS` ya son el camino para leer entre negocios; se reutilizan.
- `audit.audit_log` es inmutable y `identity.login_attempts` guarda cada intento con su IP. Son la base de la trazabilidad y de la detección.

**Huecos que encontró el análisis (en `develop`, 9 de octubre de 2026):**

- El ingreso al panel de un rol interno no pide segundo factor: una contraseña robada abre la consola.
- La bitácora tiene columnas de IP e id de petición, pero `anotarEnBitacora` no las llena; tampoco hay id de petición en el API.
- Las sesiones (`identity.sessions`) no guardan IP ni navegador, así que no se puede saber desde dónde entró alguien.
- El API no limita peticiones ni pone cabeceras de seguridad: nada frena un ataque de fuerza bruta repartido entre muchas cuentas o un registro masivo.
- La bitácora y los intentos de ingreso solo tienen la partición `DEFAULT`; falta el proceso mensual que pide ADR-0010.
- No existe la suspensión de un negocio o de una cuenta desde la consola, aunque los estados `SUSPENDED` ya están en los catálogos.
- Las acciones de plataforma (ver datos personales, suspender, cerrar sesiones ajenas) no tienen código en `audit.actions`.

Las decisiones de diseño están en [ADR-0020](arquitectura/adr/0020-consola-veci-seguridad-y-trazabilidad.md).

#### HU-16-01 · Acceso reforzado a la consola

> **Como** dueño de VECI, **quiero** que entrar a la consola exija un segundo factor y que las acciones delicadas me lo vuelvan a pedir, **para** que una contraseña robada no le dé a nadie el control de la plataforma.

**Criterios de aceptación**

- [ ] Todo usuario con un rol interno (Administración o Soporte VECI) activa un segundo factor TOTP (app autenticadora) con códigos de recuperación de un solo uso; sin él, el API no le reconoce ningún permiso de plataforma.
- [ ] La sesión de consola vence a los 15 minutos sin uso y a las 8 horas en total; volver exige contraseña y código.
- [ ] Suspender, revelar un dato completo, cerrar sesiones ajenas, cambiar roles internos y aprobar solicitudes piden el código otra vez si pasaron más de 5 minutos desde el último (re-autenticación).
- [ ] Cinco códigos fallidos bloquean el segundo factor 15 minutos y generan una alerta (HU-16-12).
- [ ] Entrar desde un dispositivo nuevo avisa al dueño de VECI por correo.
- [ ] Activar, usar, fallar y restablecer el segundo factor queda en la bitácora.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 8 | F1 | C1 | HU-02-02 | RF-PLA-01, RNF-SEG-08 |

*Nota:* Las llaves de acceso (passkeys) se pueden sumar después como segundo factor alterno; el TOTP no depende de SMS ni de un proveedor pago.

#### HU-16-02 · Bitácora completa y a prueba de manipulación

> **Como** dueño de VECI, **quiero** que cada entrada de la bitácora diga desde qué IP, navegador y petición se hizo, y que una alteración se note, **para** poder demostrar lo que pasó.

**Criterios de aceptación**

- [ ] Cada petición al API lleva un id (`X-Request-Id`, se genera si no llega) que viaja a los registros de error y a la bitácora.
- [ ] `audit.audit_log` guarda IP, id de petición y agente de usuario en todas las entradas, sin cambiar a los que ya la usan.
- [ ] Cada entrada guarda el hash de la anterior y el suyo (cadena por mes); una verificación diaria recalcula la cadena y alerta si se rompió.
- [ ] Se agregan los códigos de acción de plataforma: ingreso a la consola, segundo factor, dato personal revelado, sesión ajena cerrada, negocio y cuenta suspendidos o reactivados, rol interno cambiado, IP bloqueada, incidente cambiado, evidencia exportada.
- [ ] Ninguna lectura de la consola sobre datos personales se hace sin dejar entrada.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | C1 | HU-01-04 | RNF-SEG-05, RNF-SEG-06 |

#### HU-16-03 · Protección del API contra abusos

> **Como** dueño de VECI, **quiero** que el API frene los intentos masivos y que pueda bloquear una IP desde la consola, **para** defender la plataforma de ataques automatizados.

**Criterios de aceptación**

- [ ] Límite de peticiones por IP y por identificador en ingreso, renovación de sesión, registro de clientes, solicitudes de negocio y restablecimiento de PIN; al pasarlo responde 429 con el tiempo de espera.
- [ ] Los límites viven en datos y se cambian sin desplegar; los contadores funcionan aunque el API corra en más de una instancia.
- [ ] Cabeceras de seguridad en el API y el panel (HSTS, `nosniff`, política de contenido, marcos prohibidos) y CORS solo con los orígenes configurados.
- [ ] Lista de IP bloqueadas con motivo y vencimiento, que se edita desde la consola y queda en la bitácora.
- [ ] Cada bloqueo por límite queda como evento de seguridad para la detección (HU-16-09).

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | C1 | HU-02-01 | RNF-SEG-07 |

#### HU-16-04 · Directorio y ficha de cada negocio

> **Como** dueño de VECI, **quiero** ver todos los negocios registrados y abrir la ficha de cada uno, **para** saber quién opera, con quién y qué está pasando.

**Criterios de aceptación**

- [ ] Lista de negocios con estado, tipo, municipio, dueño, cantidad de cajeros y de clientes afiliados, fecha de alta y última actividad, con búsqueda y filtros.
- [ ] La ficha muestra datos del negocio, sedes, horarios, equipo con su rol y estado, clientes afiliados (enmascarados) y cifras de ventas y consumos.
- [ ] La ficha tiene una línea de tiempo con su bitácora: solicitud, aprobación, cambios de equipo, ajustes, anulaciones, suspensiones e incidentes.
- [ ] Se llega a la ficha desde la solicitud aprobada y desde un incidente.
- [ ] La lectura usa RLS con permiso de plataforma, sin `BYPASSRLS`.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | C2 | HU-16-02 | RF-PLA-02, RF-AUT-03 |

#### HU-16-05 · Buscar personas y ver sus vínculos

> **Como** dueño de VECI, **quiero** buscar a cualquier persona y ver en qué negocios es dueña, cajera o cliente, **para** atender un reclamo o seguir un caso sin pedirle datos a cada negocio.

**Criterios de aceptación**

- [ ] Busco por celular, documento o nombre; el celular y el documento se comparan por su huella, no en claro.
- [ ] La ficha muestra membresías, afiliaciones, solicitudes de negocio, sesiones, dispositivos, intentos de ingreso recientes y su historia en la bitácora.
- [ ] Celular y documento se ven enmascarados; ver el dato completo pide un motivo (mínimo 10 letras), re-autenticación y queda como `PERSONAL_DATA_REVEALED`.
- [ ] Una persona anonimizada sale como anonimizada y no se puede revelar.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | C2 | HU-16-01, HU-16-02 | RF-PLA-03, RNF-LEG-02, RNF-SEG-08 |

#### HU-16-06 · Sesiones y dispositivos de toda la plataforma

> **Como** dueño de VECI, **quiero** ver las sesiones abiertas y cerrar las que no deben estar, **para** cortar un acceso robado de inmediato.

**Criterios de aceptación**

- [ ] Cada sesión guarda la IP y el navegador o modelo con que se abrió y la última IP con que se renovó.
- [ ] Veo las sesiones activas filtradas por persona, negocio, rol, dispositivo o IP, con su inicio y su último uso.
- [ ] Cierro una sesión, todas las de una persona o todas las de un dispositivo, con motivo; el token deja de servir en la siguiente petición.
- [ ] Bloqueo un dispositivo para que no pueda volver a abrir sesión hasta que lo desbloquee.
- [ ] La persona afectada ve en su lista de dispositivos que VECI cerró la sesión.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | C2 | HU-02-06, HU-16-02 | RF-PLA-04, RF-AUT-06 |

#### HU-16-07 · Suspender y reactivar negocios y cuentas

> **Como** dueño de VECI, **quiero** suspender un negocio o una cuenta con un motivo y reactivarlos después, **para** frenar un fraude sin perder información.

**Criterios de aceptación**

- [ ] Suspender un negocio lo pasa a `SUSPENDED`: no vende ni registra consumos, cierra las sesiones de su equipo y su dueño ve el motivo al entrar.
- [ ] Suspender una cuenta la pasa a `SUSPENDED` en todos los negocios y cierra sus sesiones.
- [ ] Lo que la caja haya guardado sin señal antes de la suspensión se recibe y queda marcado para revisión, nunca se pierde.
- [ ] Reactivar exige motivo; suspender y reactivar piden re-autenticación y quedan en la bitácora y en la línea de tiempo de la ficha.
- [ ] Nunca se borran datos.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | C2 | HU-16-04, HU-16-06 | RF-PLA-05 |

#### HU-16-08 · Revisión de solicitudes con señales de riesgo

> **Como** dueño de VECI, **quiero** que cada solicitud de negocio me muestre lo que debo revisar y me deje pedir más información, **para** no aprobar negocios falsos que afilien clientes reales.

**Criterios de aceptación**

- [ ] Cada solicitud muestra señales: documento o NIT ya usado, celular o dispositivo con solicitudes rechazadas, cuenta recién creada, varias solicitudes desde la misma IP, incidentes de la persona.
- [ ] Hay una lista de verificación (documento revisado, llamada hecha, local visitado) que se guarda con la decisión.
- [ ] Nuevo estado "Falta información" con un mensaje que la persona lee y responde en Ajustes; vuelve a revisión al responder.
- [ ] La solicitud tiene línea de tiempo con cada cambio, quién lo hizo y cuándo.
- [ ] Aprobar pide re-autenticación.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | C3 | HU-16-01, HU-16-02 | RF-PLA-06, RF-COM-01 |

*Nota:* Amplía lo que entregó ADR-0019; el alta, la cobertura y la RLS de las solicitudes no cambian.

#### HU-16-09 · Señales de riesgo en accesos y registros

> **Como** dueño de VECI, **quiero** que el sistema detecte solo los patrones de ataque más comunes, **para** enterarme antes de que causen daño.

**Criterios de aceptación**

- [ ] Las reglas viven en datos con umbral, ventana de tiempo, severidad y si están activas; se cambian sin desplegar.
- [ ] Reglas iniciales: fuerza bruta sobre una cuenta, muchos identificadores desde una IP (relleno de credenciales), muchos registros o solicitudes desde un dispositivo o IP, ingreso a la consola desde IP o dispositivo nuevo, ráfaga de restablecimientos de PIN, bloqueo por límite repetido.
- [ ] Cada regla que salta crea un evento de seguridad y, si la severidad lo pide, abre o suma a un incidente (HU-16-11).
- [ ] Un mismo patrón no abre incidentes repetidos: se agrupa por cuenta, IP o negocio.
- [ ] La evaluación corre cada 5 minutos y nunca frena el ingreso ni la caja.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 8 | F1 | C3 | HU-16-02, HU-16-03 | RF-PLA-07 |

#### HU-16-10 · Señales de fraude en la operación

> **Como** dueño de VECI, **quiero** detectar operaciones raras dentro de un negocio, **para** proteger el saldo de los clientes y la confianza en VECI.

**Criterios de aceptación**

- [ ] Reglas sobre el libro y la bitácora: anulaciones o ajustes muy por encima de lo normal del negocio, consumos del mismo cliente en dos negocios en minutos, consumos fuera de horario autorizados en cantidad, ventas grandes seguidas de anulación, afiliaciones masivas en poco tiempo.
- [ ] Usan el mismo motor de HU-16-09 y abren incidentes ligados al negocio y a las personas.
- [ ] El dueño del negocio no ve estas reglas ni sus resultados.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debería | 5 | F1 | — | HU-16-09, HU-06-01 | RF-PLA-07 |

*Nota:* Se planifica junto con EP-06, porque necesita los consumos.

#### HU-16-11 · Incidentes con seguimiento

> **Como** dueño de VECI, **quiero** una bandeja de incidentes donde anotar, decidir y cerrar cada caso, **para** que cada sospecha tenga un responsable y un final.

**Criterios de aceptación**

- [ ] Un incidente tiene severidad, estado (abierto, en investigación, resuelto, falso positivo), responsable, negocios y personas ligados y sus eventos de seguridad.
- [ ] Puedo abrir uno a mano desde una ficha de negocio o de persona.
- [ ] Notas y cambios de estado son solo inserción: forman la línea de tiempo del caso y no se editan.
- [ ] Las acciones tomadas desde el incidente (cerrar sesiones, suspender, bloquear IP) quedan ligadas a él.
- [ ] Cerrar un incidente exige una conclusión.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 5 | F1 | C4 | HU-16-09 | RF-PLA-08 |

#### HU-16-12 · Alertas al dueño de VECI

> **Como** dueño de VECI, **quiero** recibir una alerta cuando pase algo grave, **para** actuar aunque no esté mirando la consola.

**Criterios de aceptación**

- [ ] Los incidentes de severidad alta y crítica llegan por correo en menos de 5 minutos, con enlace a la consola y sin datos personales en el texto.
- [ ] Un resumen diario de seguridad (intentos fallidos, bloqueos, incidentes abiertos, solicitudes pendientes) llega a la hora configurada.
- [ ] Una alerta que no se pudo enviar se reintenta y queda registrada.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debe | 3 | F1 | C3 | HU-16-09 | RF-PLA-07, RNF-SEG-09 |

*Nota:* El proveedor de correo se elige con la guía SSoT; la notificación push al celular del dueño llega con EP-09.

#### HU-16-13 · Tablero de la consola

> **Como** dueño de VECI, **quiero** que la consola abra con un resumen de la plataforma, **para** ver de un vistazo si todo está en orden.

**Criterios de aceptación**

- [ ] Negocios por estado, solicitudes pendientes, sesiones activas, intentos fallidos y bloqueos de las últimas 24 horas, incidentes abiertos por severidad.
- [ ] Cada cifra lleva a la lista filtrada que la explica.
- [ ] El menú de la consola muestra solo lo que permiten los permisos de quien entra (Soporte ve menos que Administración).

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debería | 3 | F1 | C4 | HU-16-04, HU-16-11 | RF-PLA-02, RF-PLA-07 |

#### HU-16-14 · Equipo VECI con mínimo privilegio

> **Como** dueño de VECI, **quiero** dar y quitar roles internos con permisos acotados y tener una cuenta de emergencia, **para** sumar personas de soporte sin entregar todo el control.

**Criterios de aceptación**

- [ ] Doy y retiro Soporte o Administración VECI con vigencia; la persona debe activar segundo factor antes de usarlo.
- [ ] Los permisos de plataforma se separan: ver negocios, ver personas, revelar datos, suspender, gestionar seguridad, gestionar el equipo.
- [ ] Nadie se quita su propio rol de Administración si es el último que queda.
- [ ] Una cuenta de emergencia sellada (credencial guardada fuera de línea) solo se usa si se pierde el acceso y su uso alerta de inmediato.
- [ ] Cada 90 días la consola pide revisar quién tiene roles internos.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debería | 3 | F1 | C4 | HU-16-01 | RNF-SEG-08, RF-AUT-03 |

#### HU-16-15 · Exportar evidencia

> **Como** dueño de VECI, **quiero** exportar la historia de un incidente, un negocio o una persona en un archivo verificable, **para** entregarla a un abogado, a la Superintendencia o a la Fiscalía.

**Criterios de aceptación**

- [ ] Exporta CSV y PDF con la línea de tiempo, la bitácora relacionada y la huella (hash) del archivo.
- [ ] La exportación pide motivo y re-autenticación y queda en la bitácora.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Podría | 3 | F2 | — | HU-16-11 | RF-PLA-09 |

#### HU-16-16 · Retención y archivo de las bitácoras

> **Como** dueño de VECI, **quiero** que las bitácoras se conserven el tiempo debido sin hacer lenta la base, **para** cumplir y seguir pudiendo investigar.

**Criterios de aceptación**

- [ ] Un proceso crea por adelantado las particiones mensuales de `audit.audit_log`, `identity.login_attempts` y los eventos de seguridad, y alerta si falla.
- [ ] Las particiones de más de 24 meses se separan y se archivan cifradas, con su hash de cadena, antes de quitarlas de la base.
- [ ] Hay un procedimiento probado para consultar un archivo viejo.

| Prioridad | Puntos | Fase | Sprint | Depende de | Requerimientos |
| --- | --- | --- | --- | --- | --- |
| Debería | 3 | F1 | C4 | HU-16-02 | RNF-SEG-10 |

*Nota:* El plazo de 24 meses en línea es una propuesta; el plazo final lo valida el abogado junto con la política de datos.

## 6. Matriz de trazabilidad

Cada requerimiento del documento y las historias que lo cumplen. Un requerimiento sin historia sería un hueco del backlog; hoy no hay ninguno.

| Requerimiento | Historias |
| --- | --- |
| RF-AUT-01 | HU-02-01, HU-02-05, HU-14-01 |
| RF-AUT-02 | HU-02-02 |
| RF-AUT-03 | HU-02-03, HU-11-04, HU-16-04, HU-16-14 |
| RF-AUT-04 | HU-02-03 |
| RF-AUT-05 | HU-02-04 |
| RF-AUT-06 | HU-02-06, HU-16-06 |
| RF-COM-01 | HU-03-01, HU-16-08 |
| RF-COM-02 | HU-03-02 |
| RF-COM-03 | HU-03-03 |
| RF-COM-04 | HU-01-04, HU-03-01 |
| RF-CLI-01 | HU-04-01 |
| RF-CLI-02 | HU-04-02, HU-04-03 |
| RF-CLI-03 | HU-04-03 |
| RF-CLI-04 | HU-04-04 |
| RF-CLI-05 | HU-04-01, HU-04-04, HU-12-01 |
| RF-CLI-06 | HU-04-03, HU-04-04 |
| RF-CLI-07 | HU-04-05 |
| RF-CLI-08 | HU-12-02 |
| RF-TIQ-01 | HU-05-01 |
| RF-TIQ-02 | HU-05-02 |
| RF-TIQ-03 | HU-05-02 |
| RF-TIQ-04 | HU-05-03 |
| RF-TIQ-05 | HU-05-04 |
| RF-TIQ-06 | HU-05-05 |
| RF-CON-01 | HU-06-01 |
| RF-CON-02 | HU-06-01, HU-06-06 |
| RF-CON-03 | HU-06-03 |
| RF-CON-04 | HU-06-02 |
| RF-CON-05 | HU-06-04 |
| RF-CON-06 | HU-06-05 |
| RF-OFF-01 | HU-05-02, HU-07-02 |
| RF-OFF-02 | HU-07-02, HU-07-03 |
| RF-OFF-03 | HU-07-01 |
| RF-OFF-04 | HU-07-04 |
| RF-OFF-05 | HU-07-05 |
| RF-OFF-06 | HU-07-06 |
| RF-REP-01 | HU-10-01 |
| RF-REP-02 | HU-10-02 |
| RF-REP-03 | HU-10-03 |
| RF-REP-04 | HU-10-04 |
| RF-REP-05 | HU-10-05 |
| RF-REP-06 | HU-10-06 |
| RF-NOT-01 | HU-07-06, HU-09-01, HU-09-02 |
| RF-NOT-02 | HU-09-03 |
| RF-NOT-03 | HU-14-02 |
| RF-NOT-04 | HU-09-04 |
| RF-APC-01 | HU-08-01 |
| RF-APC-02 | HU-04-02, HU-08-01 |
| RF-APC-03 | HU-08-02 |
| RF-APC-04 | HU-08-03, HU-14-03 |
| RF-SUS-01 | HU-11-01 |
| RF-SUS-02 | HU-11-02 |
| RF-SUS-03 | HU-11-03 |
| RF-SUS-04 | HU-11-05, HU-14-03 |
| RF-EXP-01 | HU-15-01 |
| RF-EXP-02 | HU-15-02 |
| RF-EXP-03 | HU-15-03 |
| RF-EXP-04 | HU-15-04 |
| RF-PLA-01 | HU-16-01 |
| RF-PLA-02 | HU-16-04, HU-16-13 |
| RF-PLA-03 | HU-16-05 |
| RF-PLA-04 | HU-16-06 |
| RF-PLA-05 | HU-16-07 |
| RF-PLA-06 | HU-16-08 |
| RF-PLA-07 | HU-16-09, HU-16-10, HU-16-12, HU-16-13 |
| RF-PLA-08 | HU-16-11 |
| RF-PLA-09 | HU-16-15 |
| RNF-REN-01 | HU-00-04, HU-06-01, HU-13-03, HU-13-04 |
| RNF-REN-02 | HU-13-04 |
| RNF-REN-03 | HU-13-04 |
| RNF-DIS-01 | HU-01-08 |
| RNF-DIS-02 | HU-01-08 |
| RNF-CON-01 | HU-00-04, HU-07-03, HU-07-07 |
| RNF-CON-02 | HU-07-01 |
| RNF-SEG-01 | HU-02-01 |
| RNF-SEG-02 | HU-01-05 |
| RNF-SEG-03 | HU-04-02, HU-06-02, HU-06-07 |
| RNF-SEG-04 | HU-02-01 |
| RNF-SEG-05 | HU-05-05, HU-12-03, HU-16-02 |
| RNF-SEG-06 | HU-16-02 |
| RNF-SEG-07 | HU-16-03 |
| RNF-SEG-08 | HU-16-01, HU-16-05, HU-16-14 |
| RNF-SEG-09 | HU-16-12 |
| RNF-SEG-10 | HU-16-16 |
| RNF-LEG-01 | HU-12-01, HU-12-02 |
| RNF-LEG-02 | HU-12-04, HU-16-05 |
| RNF-USA-01 | HU-00-02, HU-13-02 |
| RNF-USA-02 | HU-00-02, HU-01-09 |
| RNF-USA-03 | HU-13-03 |
| RNF-COM-01 | HU-13-01, HU-13-05 |
| RNF-COM-02 | HU-13-01 |
| RNF-ESC-01 | HU-13-04 |
| RNF-ESC-02 | HU-01-04, HU-15-01 |
| RNF-MAN-01 | HU-01-01, HU-01-02, HU-01-06, HU-01-10, HU-07-07 |
| RNF-MAN-02 | HU-01-03, HU-01-08 |
| RNF-MAN-03 | HU-01-10 |
| RNF-OBS-01 | HU-01-07 |
| RNF-COS-01 | HU-01-08 |

## 7. Cómo mantener este backlog

- Este archivo es la fuente versionada del backlog; cada cambio se hace por PR para que quede la historia en Git.
- Si cambia un requerimiento, se actualiza primero el documento de requerimientos y luego las historias que lo trazan.
- Cada épica y cada historia ya es un [issue de GitHub](https://github.com/Yadirtf/VECI/issues) con su ID en el título; las épicas son los issues #3 a #18 y las historias son sub-issues de su épica (#19 a #99). EP-16 y sus historias se cargan como issues al fusionar este cambio, con etiquetas `EP-xx`, `fase-N`, `prioridad: …` y `sprint: Sx`.
- Si cambia una historia en este archivo, se actualiza también su issue. Al terminarla se marcan sus criterios y se cierra el issue (o se cierra con `Closes #NN` en el PR).
- Las historias nuevas toman el siguiente número libre de su épica; los IDs no se reutilizan.

## 8. Historial de versiones

| Versión | Fecha | Cambios |
| --- | --- | --- |
| 1.0 | 2026-10-04 | Backlog inicial: 16 épicas, 80 historias, plan de sprints de la Fase 1 y trazabilidad. |
| 1.1 | 2026-10-04 | Se agrega HU-01-10 (estructura de arquitectura limpia) y el criterio de arquitectura limpia en la definición de terminado. |
| 1.2 | 2026-10-04 | Se amplía la Fase 1 a los meses 3 a 9 (11 sprints de construcción más 2 meses de piloto); las fases 2 y 3 se corren 3 meses. El backlog queda cargado en GitHub Issues. |
| 1.3 | 2026-10-04 | HU-00-03 terminada: modelo de datos y ADR en docs/arquitectura. |
| 1.4 | 2026-10-04 | HU-00-04: prueba de concepto de escaneo offline en poc/escaneo-offline, resultados en docs/arquitectura/poc y ADR-0011. Falta la medición en el Android de 2 GB. |
| 1.5 | 2026-10-04 | EP-01 implementada (PR #102). El repositorio se reorganiza en tres proyectos independientes, backend/, web/ y mobile/, más docs/ (ADR-0014); la prueba de concepto pasa a docs/arquitectura/poc/escaneo-offline. |
| 1.6 | 2026-10-04 | Guía de mejor solución (SSoT) en la definición de listo. EP-02 implementada (PR #106): ingreso con PIN y correo, bloqueo, tokens con renovación, roles y permisos por comercio, equipo, PIN temporal, dispositivos y cierre remoto en API, panel y app (ADR-0015). HU-02-06 se adelanta de la Fase 2. |
| 1.7 | 2026-10-05 | EP-03 implementada: alta de negocios por el dueño (conversación) y por Administración VECI (PIN temporal del propietario), horarios editables con historia, pausa y ETag para la caja, y sedes del plan Pro con cajeros por sede (ADR-0016). HU-03-03 se adelanta de la Fase 2; su filtro por sede en consumos y reportes queda para EP-06 y EP-10. |
| 1.8 | 2026-10-05 | EP-04 implementada: registro propio del cliente con política de datos versionada (HU-12-01 en parte), QR personal firmado que se ve sin internet y se regenera, afiliación con un escaneo y QR propio por negocio, registro asistido con PIN de bienvenida de 7 días y búsqueda en la caja sobre una copia local enmascarada (ADR-0017). |
| 1.9 | 2026-10-08 | EP-05 implementada: pizarra de tipos de tiquetera, venta idempotente con medio de pago en línea y sin señal (cola en el celular), saldo por unidad con la pila por vencimiento en la caja, el panel y la app del cliente (con copia sin internet), vencimiento automático por negocio y anulación y ajuste con motivo y auditoría (ADR-0018). |
| 1.10 | 2026-10-08 | Revisión de roles y seguridad antes de EP-06: el registro de negocio pasa a ser una solicitud que aprueba Administración VECI (Ajustes en la app, consola VECI en el panel), cobertura por municipio en datos (hoy Mocoa) y PIN temporal que no toca cuentas de otros negocios ni del equipo VECI (ADR-0019). |
| 1.11 | 2026-10-09 | Nueva épica EP-16, Consola VECI: control, seguridad y trazabilidad (16 historias, 76 puntos), de prioridad alta y antes de EP-06: segundo factor y re-autenticación, bitácora completa y encadenada, límite de peticiones, fichas de negocios y personas, sesiones, suspensiones, señales de riesgo, incidentes y alertas (ADR-0020). Requerimientos RF-PLA-01 a 09 y RNF-SEG-06 a 10. |
