import { hash, verify } from '@node-rs/argon2';
import { CifradorSecretos } from '../../application/puertos/cifrador-secretos.port';

/**
 * Argon2id con los parámetros mínimos que recomienda OWASP (19 MiB, 2 pasadas),
 * que caben en el plan gratuito de Render. El hash incluye sal y parámetros.
 */
export class Argon2Cifrador implements CifradorSecretos {
  cifrar(secreto: string): Promise<string> {
    return hash(secreto, { memoryCost: 19456, timeCost: 2, parallelism: 1 });
  }

  async coincide(hashGuardado: string, secreto: string): Promise<boolean> {
    try {
      return await verify(hashGuardado, secreto);
    } catch {
      return false;
    }
  }
}
