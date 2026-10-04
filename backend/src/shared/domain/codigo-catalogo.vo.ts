import { DatoInvalido } from './errores/dato-invalido.error';

const FORMATO = /^[A-Z][A-Z0-9_]*$/;

/**
 * Código estable de un valor de catálogo (estado, día, tipo de negocio...).
 * El código vive en datos (ADR-0006): el dominio valida su forma, no la lista de valores.
 */
export class CodigoCatalogo {
  private constructor(readonly valor: string) {}

  static de(valor: string): CodigoCatalogo {
    if (!FORMATO.test(valor) || valor.length > 40) {
      throw new DatoInvalido(`"${valor}" no es un código de catálogo válido`);
    }
    return new CodigoCatalogo(valor);
  }

  igualA(otro: CodigoCatalogo): boolean {
    return this.valor === otro.valor;
  }
}
