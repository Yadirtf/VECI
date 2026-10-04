import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';

const E164 = /^\+[1-9]\d{7,14}$/;
const MOVIL_COLOMBIA = /^3\d{9}$/;

/**
 * Celular en formato E.164 (+573001234567), como se guarda en la base.
 * Acepta como lo escribe la gente: "300 123 4567", "57 300...", "+57-300...".
 */
export class Celular {
  private constructor(readonly valor: string) {}

  static de(texto: string): Celular {
    const limpio = texto.replace(/[\s\-().]/g, '');
    if (MOVIL_COLOMBIA.test(limpio)) return new Celular(`+57${limpio}`);
    if (/^57\d{10}$/.test(limpio)) return new Celular(`+${limpio}`);
    if (E164.test(limpio)) return new Celular(limpio);
    throw new DatoInvalido('Revisa el celular, veci: son 10 números y empieza por 3.');
  }

  /** Últimos 4 dígitos, para mostrar sin exponer el número completo. */
  get enmascarado(): string {
    return `••• ${this.valor.slice(-4)}`;
  }
}
