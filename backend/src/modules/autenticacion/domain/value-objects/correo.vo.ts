import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';

const FORMATO = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

/** Correo para entrar al panel (HU-02-02). Se guarda en minúsculas. */
export class Correo {
  private constructor(readonly valor: string) {}

  static de(texto: string): Correo {
    const limpio = texto.trim().toLowerCase();
    if (!FORMATO.test(limpio) || limpio.length > 120) {
      throw new DatoInvalido('Ese correo no parece válido. Revísalo, veci.');
    }
    return new Correo(limpio);
  }
}
