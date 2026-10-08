/** Marca los errores de la petición con datos que no son personales (HU-01-07). */
export interface Observabilidad {
  etiquetarComercio(comercioId: string): void;
  /** Reporta un error de un proceso sin petición (por ejemplo, el vencimiento automático). */
  capturarError(error: unknown): void;
}

export const OBSERVABILIDAD = Symbol('Observabilidad');
