/**
 * Contenido firmado del QR del cliente en un comercio
 * (customers.affiliation_qr_codes, ADR-0005). No lleva saldo ni datos personales.
 */
export interface QrPayload {
  /** Clave del comercio que firmó (tenancy.tenant_signing_keys.key_id). */
  keyId: string;
  tenantId: string;
  affiliationId: string;
  /** Id de la fila de affiliation_qr_codes: identifica la versión escaneada. */
  qrCodeId: string;
  version: number;
}
