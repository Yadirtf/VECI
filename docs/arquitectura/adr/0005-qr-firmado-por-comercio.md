# 0005 · QR con token firmado por comercio, sin datos sensibles

- **Estado:** Aceptada
- **Fecha:** 2026-10-04
- **Requerimientos:** RF-CLI-02, RF-CLI-03, RF-CON-01, RF-CON-04, RNF-SEG-03, HU-06-02, HU-06-07

## Contexto

El QR es la llave del cliente en la caja. Debe validarse sin internet, no puede servir en otro comercio, no puede revelar datos personales ni saldo, y debe poder bloquearse si se pierde o se comparte.

## Decisión

1. **Dos QR distintos.**
   - *QR personal* (`customers.personal_qr_codes`): firmado por VECI con `person_id` y versión. Solo sirve para afiliarse a un comercio.
   - *QR del cliente en el comercio* (`customers.affiliation_qr_codes`): firmado con la clave del comercio, con `affiliation_id`, `tenant_id` y versión. Es el que se escanea para consumir. Un cliente en tres comercios tiene tres.
2. **Firma asimétrica (Ed25519) por comercio.** La clave pública está en `tenancy.tenant_signing_keys` y baja al celular del cajero, que verifica la firma sin internet. La privada vive en el gestor de secretos; la base guarda solo su referencia. Las claves se rotan: una activa a la vez, las retiradas siguen verificando los QR que firmaron hasta regenerarlos.
3. **Revocación por versión.** Regenerar o revocar un QR cierra la fila vigente (`revoked_at` + motivo) y crea la siguiente versión. La lista de revocados baja al celular en la sincronización incremental. Un QR revocado usado offline abre el conflicto `REVOKED_QR_USED`.
4. **El QR no guarda saldo ni datos personales.** El saldo vive en el servidor y en la copia local cifrada del celular.

## Alternativas consideradas

| Alternativa | Por qué no |
| --- | --- |
| QR con el número de documento | Expone datos personales y se falsifica con cualquier generador de QR. |
| Un solo QR por persona para todos los comercios | Un comercio podría usarlo en otro; revocar en uno afectaría a todos. |
| HMAC con clave compartida | El celular del cajero tendría la clave para *firmar*, no solo verificar: quien la extraiga fabrica QR válidos. |

## Consecuencias

- Validar un QR offline es una verificación criptográfica local, de milisegundos.
- El consumo guarda qué versión del QR se escaneó (`consumptions.affiliation_qr_code_id`), útil para investigar fraudes.
- Si un comercio pierde el control de su clave, se rota y se regeneran sus QR sin afectar a otros comercios.
