import { generateKeyPairSync, KeyObject, sign } from 'node:crypto';
import { QrPayload } from '../domain/qr-payload';
import { PublicSigningKey, SigningKeyring } from '../domain/signing-keyring';
import { encodeSignedPart, joinToken } from './qr-token.codec';

interface KeyPair {
  keyId: string;
  publicKey: KeyObject;
  privateKey: KeyObject;
}

/**
 * Claves Ed25519 en memoria, una por comercio, creadas al arrancar.
 * En el MVP la privada vive en el gestor de secretos (ADR-0005).
 */
export class Ed25519Keyring implements SigningKeyring {
  private readonly keys = new Map<string, KeyPair>();

  activeKeyId(tenantId: string): string {
    return this.pairFor(tenantId).keyId;
  }

  publicKeys(tenantId: string): PublicSigningKey[] {
    const pair = this.pairFor(tenantId);
    const jwk = pair.publicKey.export({ format: 'jwk' });
    const raw = Buffer.from(jwk.x as string, 'base64url');
    return [
      { keyId: pair.keyId, algorithm: 'Ed25519', publicKeyBase64: raw.toString('base64'), retiredAt: null },
    ];
  }

  signToken(payload: QrPayload): string {
    const pair = this.pairFor(payload.tenantId);
    const signedPart = encodeSignedPart(payload);
    const signature = sign(null, Buffer.from(signedPart, 'ascii'), pair.privateKey);
    return joinToken(signedPart, signature);
  }

  private pairFor(tenantId: string): KeyPair {
    const existing = this.keys.get(tenantId);
    if (existing) return existing;
    const { publicKey, privateKey } = generateKeyPairSync('ed25519');
    const pair = { keyId: `k-${tenantId.slice(-4)}-1`, publicKey, privateKey };
    this.keys.set(tenantId, pair);
    return pair;
  }
}
