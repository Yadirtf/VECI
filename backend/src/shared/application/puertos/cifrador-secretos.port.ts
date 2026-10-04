/** Hash lento de PIN y contraseñas (Argon2id). Nunca se guarda el secreto (RNF-SEG-01). */
export interface CifradorSecretos {
  cifrar(secreto: string): Promise<string>;
  coincide(hash: string, secreto: string): Promise<boolean>;
}

export const CIFRADOR_SECRETOS = Symbol('CifradorSecretos');
