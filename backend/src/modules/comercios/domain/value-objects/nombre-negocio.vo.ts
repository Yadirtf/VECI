import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';

/** Nombre con que la gente conoce el negocio: "Restaurante La Vecina". */
export class NombreNegocio {
  private constructor(readonly valor: string) {}

  static de(texto: string): NombreNegocio {
    const limpio = texto.trim().replace(/\s+/g, ' ');
    if (limpio.length < 3 || limpio.length > 120) {
      throw new DatoInvalido('El nombre del negocio va de 3 a 120 letras, veci.');
    }
    return new NombreNegocio(limpio);
  }

  /** Enlace público: "restaurante-la-vecina". */
  get slug(): string {
    const base = this.valor
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '')
      .slice(0, 50)
      .replace(/-+$/, '');
    return base || 'negocio';
  }
}
