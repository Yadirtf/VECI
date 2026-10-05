import { createPrivateKey, createPublicKey, hkdfSync, KeyObject, sign, verify } from 'node:crypto';
import { FirmadorQr, FirmanteQr } from '../../application/puertos/firmador-qr.port';

/** Prefijo DER (PKCS#8) de una clave privada Ed25519; le siguen los 32 bytes de la semilla. */
const PKCS8_ED25519 = Buffer.from('302e020100300506032b657004220420', 'hex');

/**
 * Ed25519 con claves derivadas (HKDF-SHA256) de un secreto maestro (VECI_QR_SECRETO).
 * Cada comercio tiene su clave propia: quien saque la de un comercio no firma QR de
 * otro, y rotar es subir el keyId. Con un gestor de secretos, solo cambia esta clase.
 */
export class FirmadorQrEd25519 implements FirmadorQr {
  readonly referenciaPrivada = 'hkdf-sha256:v1';
  private readonly claves = new Map<string, KeyObject>();

  constructor(private readonly secretoMaestro: string) {
    if (secretoMaestro.length < 32)
      throw new Error('VECI_QR_SECRETO necesita 32 caracteres o más.');
  }

  firmar(firmante: FirmanteQr, mensaje: string): string {
    return sign(null, Buffer.from(mensaje, 'ascii'), this.privada(firmante)).toString('base64url');
  }

  verificar(firmante: FirmanteQr, mensaje: string, firma: string): boolean {
    const bytes = Buffer.from(firma, 'base64url');
    if (bytes.length !== 64) return false;
    const publica = createPublicKey(this.privada(firmante));
    return verify(null, Buffer.from(mensaje, 'ascii'), publica, bytes);
  }

  clavePublica(firmante: FirmanteQr): Uint8Array {
    const der = createPublicKey(this.privada(firmante)).export({ format: 'der', type: 'spki' });
    return new Uint8Array(der.subarray(der.length - 32));
  }

  private privada(firmante: FirmanteQr): KeyObject {
    const info = `${firmante.comercioId ? `tenant:${firmante.comercioId}` : 'veci'}:${firmante.keyId}`;
    const guardada = this.claves.get(info);
    if (guardada) return guardada;
    const semilla = Buffer.from(hkdfSync('sha256', this.secretoMaestro, 'veci-qr', info, 32));
    const clave = createPrivateKey({
      key: Buffer.concat([PKCS8_ED25519, semilla]),
      format: 'der',
      type: 'pkcs8',
    });
    this.claves.set(info, clave);
    return clave;
  }
}
