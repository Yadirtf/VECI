/**
 * Quién firma un QR (ADR-0005, ADR-0017): VECI firma el QR personal y cada comercio
 * firma los QR de sus clientes con su propia clave Ed25519 (comercioId null = VECI).
 */
export interface FirmanteQr {
  readonly comercioId: string | null;
  readonly keyId: string;
}

/** Firma Ed25519 de los QR. La clave privada nunca sale de la API. */
export interface FirmadorQr {
  /** Firma los bytes ASCII del mensaje. Devuelve la firma en base64url. */
  firmar(firmante: FirmanteQr, mensaje: string): string;
  verificar(firmante: FirmanteQr, mensaje: string, firma: string): boolean;
  /** Clave pública cruda (32 bytes) que baja al celular del cajero. */
  clavePublica(firmante: FirmanteQr): Uint8Array;
  /** Cómo se obtiene la privada; va en tenancy.tenant_signing_keys.private_key_ref. */
  readonly referenciaPrivada: string;
}

export const FIRMADOR_QR = Symbol('FirmadorQr');
