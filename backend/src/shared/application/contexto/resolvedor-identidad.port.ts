/** Cabeceras de la petición, ya en minúsculas. */
export type Cabeceras = Readonly<Record<string, string | string[] | undefined>>;

/**
 * Obtiene el usuario autenticado de una petición, o null si no hay sesión.
 * EP-02 (celular y PIN) lo implementa con tokens; hoy existe una versión de desarrollo.
 */
export interface ResolvedorIdentidad {
  resolver(cabeceras: Cabeceras): Promise<string | null>;
}

export const RESOLVEDOR_IDENTIDAD = Symbol('ResolvedorIdentidad');
