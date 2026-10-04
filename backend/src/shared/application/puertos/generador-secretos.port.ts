/** Valores aleatorios criptográficos y huellas para guardar tokens sin el secreto. */
export interface GeneradorSecretos {
  /** Texto aleatorio de 256 bits, seguro para URL. */
  token(): string;
  /** Seis dígitos aleatorios. */
  digitos(): string;
  /** SHA-256 del valor, en hexadecimal. */
  huella(valor: string): string;
}

export const GENERADOR_SECRETOS = Symbol('GeneradorSecretos');
