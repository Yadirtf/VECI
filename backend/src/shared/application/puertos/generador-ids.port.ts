/** Genera ids únicos ordenados por tiempo (UUID v7, ADR-0004). */
export interface GeneradorIds {
  siguiente(): string;
}

export const GENERADOR_IDS = Symbol('GeneradorIds');
