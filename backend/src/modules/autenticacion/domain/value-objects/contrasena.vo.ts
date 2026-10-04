import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';

/** Contraseña del panel (HU-02-02): 8 a 64 caracteres, con letras y números. */
export class Contrasena {
  private constructor(readonly valor: string) {}

  static nueva(texto: string): Contrasena {
    const larga = texto.length >= 8 && texto.length <= 64;
    if (!larga || !/[A-Za-zÁÉÍÓÚÑáéíóúñ]/.test(texto) || !/\d/.test(texto)) {
      throw new DatoInvalido('La contraseña necesita al menos 8 caracteres, con letras y números.');
    }
    return new Contrasena(texto);
  }
}
