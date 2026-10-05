import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';

/**
 * Dirección pública del logo (https). Es opcional: sin logo, la app y el panel
 * dibujan el sello del negocio con su inicial.
 */
export class Logo {
  private constructor(readonly url: string) {}

  static de(texto: string): Logo {
    const limpio = texto.trim();
    let url: URL;
    try {
      url = new URL(limpio);
    } catch {
      throw new DatoInvalido('Esa dirección del logo no abre, veci.');
    }
    if (url.protocol !== 'https:' || limpio.length > 500) {
      throw new DatoInvalido('El logo debe estar en una dirección https.');
    }
    return new Logo(limpio);
  }
}
