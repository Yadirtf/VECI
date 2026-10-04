import type { PreferenciasSesion } from '../domain/sesion';

const CLAVE = 'veci.comercio';

/** Recuerda el negocio elegido en este navegador; si el almacenamiento falla, solo se olvida. */
export const preferenciasNavegador: PreferenciasSesion = {
  comercioGuardado() {
    try {
      return window.localStorage.getItem(CLAVE);
    } catch {
      return null;
    }
  },
  guardarComercio(comercioId) {
    try {
      if (comercioId) window.localStorage.setItem(CLAVE, comercioId);
      else window.localStorage.removeItem(CLAVE);
    } catch {
      // Navegador en modo privado o sin espacio: el panel vuelve a preguntar el negocio.
    }
  },
};
