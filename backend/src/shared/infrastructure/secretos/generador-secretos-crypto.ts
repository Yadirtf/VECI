import { createHash, randomBytes, randomInt } from 'node:crypto';
import { GeneradorSecretos } from '../../application/puertos/generador-secretos.port';

export class GeneradorSecretosCrypto implements GeneradorSecretos {
  token(): string {
    return randomBytes(32).toString('base64url');
  }

  digitos(): string {
    return String(randomInt(0, 1_000_000)).padStart(6, '0');
  }

  huella(valor: string): string {
    return createHash('sha256').update(valor).digest('hex');
  }
}
