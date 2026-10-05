import type { AlmacenBorrador } from '../application/use-alta';
import type { BorradorAlta } from '../domain/alta';

const CLAVE = 'veci.alta.borrador';

/**
 * Lo escrito en el alta se guarda en este navegador (no en el servidor): si se va la
 * señal o se cierra la pestaña, la conversación sigue donde iba. Nunca guarda PIN.
 */
export const borradorNavegador: AlmacenBorrador = {
  leer() {
    try {
      const texto = window.localStorage.getItem(CLAVE);
      return texto ? (JSON.parse(texto) as BorradorAlta) : null;
    } catch {
      return null;
    }
  },
  guardar(borrador) {
    try {
      if (borrador) window.localStorage.setItem(CLAVE, JSON.stringify(borrador));
      else window.localStorage.removeItem(CLAVE);
    } catch {
      // Sin almacenamiento (modo privado): la conversación sigue, solo no se recuerda.
    }
  },
};
