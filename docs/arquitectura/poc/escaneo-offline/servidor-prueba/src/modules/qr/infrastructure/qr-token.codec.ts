import { QrPayload } from '../domain/qr-payload';

/**
 * Formato del token impreso en el QR (versión 1):
 *
 *   V1.<base64url(JSON)>.<base64url(firma Ed25519)>
 *
 * La firma cubre los bytes ASCII de "V1.<base64url(JSON)>". El JSON usa llaves
 * cortas para que el QR sea pequeño y se lea rápido con cámaras de gama baja.
 * La app móvil implementa el mismo formato en qr_token_codec.dart.
 */
export const QR_TOKEN_PREFIX = 'V1';

interface WirePayload {
  k: string;
  t: string;
  a: string;
  q: string;
  v: number;
}

export function encodeSignedPart(payload: QrPayload): string {
  const wire: WirePayload = {
    k: payload.keyId,
    t: payload.tenantId,
    a: payload.affiliationId,
    q: payload.qrCodeId,
    v: payload.version,
  };
  const body = Buffer.from(JSON.stringify(wire), 'utf8').toString('base64url');
  return `${QR_TOKEN_PREFIX}.${body}`;
}

export function joinToken(signedPart: string, signature: Buffer): string {
  return `${signedPart}.${signature.toString('base64url')}`;
}
