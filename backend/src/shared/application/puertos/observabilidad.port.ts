/** Marca los errores de la petición con datos que no son personales (HU-01-07). */
export interface Observabilidad {
  etiquetarComercio(comercioId: string): void;
}

export const OBSERVABILIDAD = Symbol('Observabilidad');
