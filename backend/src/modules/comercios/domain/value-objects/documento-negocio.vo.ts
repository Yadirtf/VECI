import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';

/** Pesos de la DIAN para el dígito de verificación, de derecha a izquierda. */
const PESOS = [3, 7, 13, 17, 19, 23, 29, 37, 41, 43, 47, 53, 59, 67, 71];

/** Dígito de verificación de un NIT (módulo 11 de la DIAN). */
export function digitoVerificacion(base: string): number {
  const suma = [...base]
    .reverse()
    .reduce((total, digito, i) => total + Number(digito) * PESOS[i], 0);
  const residuo = suma % 11;
  return residuo > 1 ? 11 - residuo : residuo;
}

export type TipoDocumentoNegocio = 'NIT' | 'CC';

/**
 * NIT o cédula del negocio (RF-COM-01). El NIT se guarda con su dígito de
 * verificación al final: si la persona escribe solo los 9 números, VECI lo calcula;
 * si lo escribe, se comprueba. Así un NIT mal copiado no entra.
 */
export class DocumentoNegocio {
  private constructor(
    readonly tipo: TipoDocumentoNegocio,
    readonly numero: string,
  ) {}

  static de(tipo: string, texto: string): DocumentoNegocio {
    const limpio = texto.replace(/[\s.]/g, '');
    if (tipo === 'NIT') return new DocumentoNegocio('NIT', DocumentoNegocio.nit(limpio));
    if (tipo === 'CC' && /^\d{6,10}$/.test(limpio)) return new DocumentoNegocio('CC', limpio);
    if (tipo === 'CC') throw new DatoInvalido('La cédula tiene de 6 a 10 números, veci.');
    throw new DatoInvalido('El negocio se registra con NIT o con cédula.');
  }

  private static nit(texto: string): string {
    const [base, dv] = texto.includes('-') ? texto.split('-') : DocumentoNegocio.partir(texto);
    if (!/^\d{8,9}$/.test(base) || (dv !== undefined && !/^\d$/.test(dv))) {
      throw new DatoInvalido('El NIT tiene 9 números y, si quieres, su dígito de verificación.');
    }
    const esperado = digitoVerificacion(base);
    if (dv !== undefined && Number(dv) !== esperado) {
      throw new DatoInvalido(`Revisa el NIT, veci: el dígito de verificación es ${esperado}.`);
    }
    return `${base}${esperado}`;
  }

  /** Sin guion: 9 números son la base; 10 números traen el dígito al final. */
  private static partir(texto: string): [string, string | undefined] {
    return texto.length === 10 ? [texto.slice(0, 9), texto.slice(9)] : [texto, undefined];
  }

  /** Como se muestra: 900.123.456-7 para el NIT. */
  get legible(): string {
    if (this.tipo === 'CC') return this.numero;
    const base = this.numero.slice(0, -1).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    return `${base}-${this.numero.slice(-1)}`;
  }
}
