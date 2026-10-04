import { Identidad } from './identidad';

/** Cabeceras de la petición, ya en minúsculas. */
export type Cabeceras = Readonly<Record<string, string | string[] | undefined>>;

/**
 * Obtiene la identidad de una petición, o null si no trae credenciales.
 * Lanza SesionNoValida si las trae pero ya no sirven (token vencido o sesión cerrada).
 */
export interface ResolvedorIdentidad {
  resolver(cabeceras: Cabeceras): Promise<Identidad | null>;
}

export const RESOLVEDOR_IDENTIDAD = Symbol('ResolvedorIdentidad');
