import { QrPayload } from './qr-payload';

export interface PublicSigningKey {
  keyId: string;
  algorithm: 'Ed25519';
  /** Clave pública cruda (32 bytes) en base64. */
  publicKeyBase64: string;
  retiredAt: string | null;
}

/** Claves de firma por comercio. La privada nunca sale de esta interfaz. */
export interface SigningKeyring {
  activeKeyId(tenantId: string): string;
  publicKeys(tenantId: string): PublicSigningKey[];
  /** Devuelve el token completo listo para imprimir en el QR. */
  signToken(payload: QrPayload): string;
}

export const SIGNING_KEYRING = Symbol('SigningKeyring');
