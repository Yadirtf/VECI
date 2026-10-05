# 0017 · Clientes: QR firmados con claves derivadas, datos enmascarados y copia local en la caja

- **Estado:** Propuesta
- **Fecha:** 2026-10-05
- **Requerimientos:** RF-CLI-01 a RF-CLI-07, RF-APC-02, RNF-SEG-03, RNF-LEG-01

## Contexto

EP-04 pide que el cliente se registre solo con su política de datos aceptada, tenga un QR personal que se vea sin internet y pueda regenerar, quede afiliado a un negocio con un escaneo (con un QR distinto en cada negocio), que el cajero registre a quien no tiene app y que la búsqueda en la caja funcione sin señal y solo sobre los clientes del negocio. [ADR-0005](0005-qr-firmado-por-comercio.md) ya fijó los dos QR firmados con Ed25519; faltaba decidir de dónde salen las claves, qué lleva el token, qué ve cada quien y cómo baja la copia a la caja.

Siguiendo la [guía de mejor solución](../../guias/ssot-mejor-solucion-no-generica.md), tres agentes propusieron el diseño desde semillas distintas (la cajera en hora pico, la persona mayor sin app y "confiar sin mostrar de más"). Las decisiones se tomaron en este orden: correcto y seguro, sirve sin internet y en gama baja, cercano y fácil, simple de mantener, barato.

## Decisión

1. **Claves derivadas, no guardadas.** Cada clave privada Ed25519 se deriva con HKDF-SHA256 de un único secreto del servidor, `VECI_QR_SECRETO` (sal `veci-qr`, información `veci:<keyId>` para VECI y `tenant:<comercioId>:<keyId>` para cada negocio). La base guarda solo la pública en `tenancy.tenant_signing_keys`, con la referencia `hkdf-sha256:v1`. La clave del negocio (`k1`) se crea la primera vez que afilia a alguien. Rotar es pasar a `k2`.
2. **Tokens sin datos personales.** QR personal: `VP1.<datos>.<firma>`; QR en el negocio: `V1.<datos>.<firma>`. Los datos son JSON en base64url con la clave usada, el id de la fila del QR y su versión (y, en el del negocio, comercio y afiliación). Nunca nombre, documento ni saldo. La firma cubre `prefijo.datos`.
3. **Leer un QR responde una de cinco cosas**, con el mensaje listo para la caja: `PERSONA_POR_AFILIAR` (nombre corto y documento `****5678`), `CLIENTE`, `QR_CAMBIADO` (versión revocada, sin decir de quién era), `OTRO_NEGOCIO` y `NO_ES_DE_VECI` (firma o formato inválidos). Afiliar es idempotente: un segundo escaneo responde `yaEstaba` y abre la ficha.
4. **Lo que ve cada quien.** El cajero ve el nombre corto y el documento y el celular tapados (`****5678`, `••• 8888`); solo el permiso `customers.view_full_document` (propietario) ve los datos completos. La vista previa de un QR personal pasa por la función `customers.preview_personal_qr`, que devuelve solo lo enmascarado, porque la persona aún no es visible para el negocio por RLS.
5. **Copia local enmascarada con ETag.** `GET /clientes/copia-local` baja a la caja nombre, nombre para buscar (sin tildes), documento y celular tapados, sus últimos 4 y el estado de la cuenta, más las claves públicas del negocio. Responde 304 con `If-None-Match` cuando nada cambió. La caja busca sobre esa copia en Drift mientras se escribe.
6. **Registro asistido sin duplicar personas.** Primero se revisa el documento: si la persona existe se vincula; si no, se crea con su usuario pendiente y un **PIN de bienvenida** que sirve 7 días (`credential_types.temporary_valid_hours`). Al entrar con él, el flujo de [ADR-0015](0015-sesion-pin-temporal-y-acceso-propio.md) pide crear el PIN propio. Si el celular ya es de otra cuenta, el cajero puede marcarlo como celular compartido de la familia: queda como contacto y la persona sin cuenta propia.
7. **Política de datos versionada.** `compliance.policy_versions` guarda versión, fecha y huella SHA-256 del texto, que vive en la API junto con su "en corto" y "en palabras de vecino". Registrarse (solo o asistido) exige la versión vigente y guarda el consentimiento con el canal. Una prueba compara la huella del texto con la de las migraciones.
8. **Diseño propio.** En la app, el registro es una conversación de una pregunta por pantalla y Mi QR es un carnet con sello de versión que regenera en línea, sin modal. En la caja, "la ranura de quien sigue": un solo campo que entiende nombre, celular o documento, junto al botón de escanear. En el panel, "Tus clientes" es una libreta con su ventanilla.

## Alternativas consideradas

- **Una clave privada por negocio en un gestor de secretos:** lo que pedía ADR-0005; obliga a crear y leer un secreto por negocio y otra dependencia de pago. Derivar da el mismo aislamiento (comprometer una clave no da las otras) con un solo secreto. Si se filtra `VECI_QR_SECRETO` hay que rotar todas, y por eso la referencia lleva versión.
- **Firmar con HMAC:** la caja tendría la clave para fabricar QR (mismo motivo que en ADR-0005).
- **QR personal con el documento o el celular:** más simple pero expone datos y se falsifica.
- **Hash del documento en la copia local para buscar por número completo:** un documento de 6 a 10 dígitos se adivina por fuerza bruta en segundos; se buscan los últimos 4.
- **Bajar la copia completa cada vez / avisar por push:** gasta datos o depende de Firebase; la ETag cuesta un encabezado.
- **Afiliación sin señal en cola:** necesita el outbox de EP-07; en EP-04 la caja lo dice con franqueza y pide reintentar con señal.
- **PIN de bienvenida sin vencimiento:** un PIN dictado en voz alta en un mostrador no debe servir para siempre.
- **"Léemelo" con voz y subir el brillo de la pantalla:** útiles para personas mayores, pero agregan dependencias nativas ([ADR-0011](0011-librerias-escaneo-offline.md)); se usan letra grande y alto contraste.

## Consecuencias

- `VECI_QR_SECRETO` es obligatorio en staging y producción; cambiarlo invalida todos los QR emitidos con esa referencia.
- La verificación de QR personales se hace en el servidor en EP-04; la caja ya baja las claves públicas del negocio para validar sin internet los QR de consumo en EP-06.
- Una afiliación que llega sin QR (semilla, importación o, en EP-07, la caja sin señal) recibe el suyo la primera vez que el cliente abre sus negocios o la caja la vuelve a afiliar.
- La lista de QR revocados por negocio llega con la sincronización incremental de EP-07.
- Pedir aceptar de nuevo la política a quien ya tiene cuenta queda pendiente para la versión 1.1.
