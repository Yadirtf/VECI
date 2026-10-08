# 0016 · Alta de comercios, horarios con historia y ETag, sedes por plan y diseño propio

- **Estado:** Propuesta (la decisión 1 la reemplaza [ADR-0019](0019-roles-solicitudes-de-negocio-y-cobertura.md))
- **Fecha:** 2026-10-05
- **Requerimientos:** RF-COM-01 a RF-COM-04, RNF-USA-02, RNF-ESC-02

## Contexto

EP-03 pide registrar un negocio (nombre, NIT o cédula, tipo de un catálogo, logo y contacto) con su sede principal, su plan de Prueba y la membresía del propietario; definir horarios de servicio por día sin solapes que lleguen a la caja en la siguiente sincronización; y, en el plan Pro, varias sedes con cajeros asignados. El dueño del producto pidió además que el panel y la app dejen de verse genéricos: VECI es un aliado cercano, no "una aplicación tecnológica más".

Siguiendo la [guía de mejor solución](../../guias/ssot-mejor-solucion-no-generica.md), tres agentes exploraron el diseño con semillas distintas (la cajera en hora pico, el contexto del Putumayo y "el error imposible"); el resto de decisiones se compararon con al menos tres alternativas.

## Decisión

1. **Dos puertas, un mismo alta.** El dueño se registra solo (`POST /comercios`, con sesión) y Administración VECI registra por él (`POST /plataforma/comercios`, permiso `platform.manage_tenants`). El alta corre con el comercio nuevo fijado como contexto de RLS: crea comercio (estado inicial), contactos, sede principal, servicios de la plantilla y la suscripción de Prueba. Cuando registra Administración VECI, el propietario se invita con el mismo PIN temporal de EP-02 ([ADR-0015](0015-sesion-pin-temporal-y-acceso-propio.md)) y rol `OWNER`.
2. **La prueba la abre el propio comercio, nada más.** Una política estrecha (`tenant_starts_trial`) deja a `veci_app` insertar su suscripción solo a un plan con `trial_days` y en el estado inicial; los cambios de plan siguen siendo de la plataforma.
3. **Plantilla de servicios en datos.** `tenancy.business_type_services` dice con qué servicios nace cada tipo (restaurante: desayuno, almuerzo, cena; colegio: refrigerio, almuerzo) y su horario sugerido. Un sector nuevo es una fila ([ADR-0006](0006-estados-y-tipos-como-catalogos.md)). Las horas no se crean solas: el dueño las confirma.
4. **Camino de apertura.** El negocio queda en su estado inicial hasta que el dueño lo abre; abrir exige solo lo obligatorio (horarios). Datos, equipo y tiqueteras se muestran como paradas del camino.
5. **Editar un horario no borra la historia.** Se cierra la vigencia (`valid_during`) del horario anterior en la fecha local del negocio (`tenancy.current_local_date`) y se crea uno nuevo desde hoy; pausar cambia `is_active`. La restricción de exclusión de la base sigue impidiendo solapes. Un horario cuya fecha UTC empieza mañana cuenta como vigente (`tenancy.still_valid`), porque en la noche de Colombia el servidor ya va un día adelante.
6. **La caja sincroniza con ETag.** `GET /horarios` responde con `ETag` (la mayor `sync_version` de horarios y servicios) y 304 si nada cambió. La app guarda la ETag en Drift junto con la copia local, así que una caja sin cambios no baja nada y una sin señal sigue con lo guardado.
7. **Sedes por plan, en datos.** Varias sedes exige la función `MULTI_BRANCH` y respeta el límite `BRANCHES` del plan vigente. La sede principal no se cierra. Un cajero sin filas en `membership_branches` trabaja en todas; si al asignarlo queda en todas las activas, se guarda vacío para que cubra también las sedes nuevas.
8. **Diseño propio, sin cambiar el sistema de diseño.** Se usan los tokens y componentes existentes, con formas propias por pantalla:
   - Registrar el negocio es una **conversación**: una pregunta por pantalla, el avance como piedras para cruzar la quebrada, el dígito de verificación del NIT puesto por VECI y, al final, el **letrero** que cuelga en la puerta con el sello del negocio (su inicial mientras no hay logo).
   - Los horarios son el **camino del sol**: un arco de 5 a. m. a 10 p. m. donde cada servicio es un tramo grueso que se estira con el dedo (de 15 en 15 minutos) y se detiene solo contra su vecino; siete soles en fila ondulada muestran la semana (luna = se descansa). Hay botones de más y menos para quien no arrastra.
   - En la caja, **"¿Ya es hora?"** responde en grande con lo guardado en el celular.
   - Las sedes son un **caserío** alrededor del patio; el lote vacío invita a Pro sin estorbar.

## Alternativas consideradas

- **Solo Administración VECI registra negocios:** más control, pero frena el crecimiento y no cumple "configurado en menos de 10 minutos".
- **Función `SECURITY DEFINER` para el alta:** evitaría la política de la suscripción, pero en Neon el dueño de la función y `FORCE RLS` la vuelven frágil (mismo motivo que en ADR-0015).
- **Editar el horario en su lugar:** más simple, pero borra con qué horario se validó un consumo pasado (antifraude, EP-06).
- **Borrar un horario en vez de pausarlo:** se pierde y hay que volver a crearlo cada temporada.
- **Bajar siempre la lista completa / avisar por push:** la lista completa gasta datos en cada apertura; el push depende de Firebase y de señal. La ETag cuesta un encabezado y el push puede sumarse luego.
- **Crear los horarios sugeridos al registrar:** abriría el negocio sin que el dueño mire sus horas; se prefiere sugerir y confirmar.
- **Formulario largo de alta / asistente con barra de progreso:** lo típico; la conversación se contesta entre pedido y pedido y se guarda en el navegador si se va la señal.
- **Reloj circular de 24 horas para horarios:** muy bonito, pero en un celular de gama baja los tramos cortos quedan imposibles de tocar.
- **Tabla de días por horas o tarjetas apiladas:** claras pero genéricas; no muestran de un vistazo que el día "se acaba" ni los huecos libres.

## Consecuencias

- El logo es un enlace `https` hasta que exista almacenamiento de archivos; el sello con la inicial cubre mientras tanto.
- El filtro por sede de consumos y reportes queda para EP-06 y EP-10; los datos ya llevan `branch_id`.
- La base local de la app pasa a la versión 2 (columna `activo` y tabla de marcas de sincronización) con migración automática.
- Cualquier consulta nueva de horarios vigentes debe usar `tenancy.still_valid(valid_during)`, no `@> current_date`.
