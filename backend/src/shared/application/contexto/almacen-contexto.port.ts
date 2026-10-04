import { ContextoComercio } from './contexto-comercio';

/**
 * Guarda el contexto de la petición en curso. La presentación lo fija después de
 * validar la membresía y la persistencia lo lee para aplicar RLS en la base.
 */
export interface AlmacenContexto {
  ejecutar<T>(trabajo: () => T): T;
  fijarComercio(contexto: ContextoComercio): void;
  comercioActual(): ContextoComercio | null;
}

export const ALMACEN_CONTEXTO = Symbol('AlmacenContexto');
