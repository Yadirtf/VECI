/** Genera ids únicos ordenados por tiempo (UUID v7, ADR-0004). */
export interface IdGenerator {
  next(): string;
}

export const ID_GENERATOR = Symbol('IdGenerator');
