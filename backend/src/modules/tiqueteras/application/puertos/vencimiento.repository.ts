/** Proceso automático de vencimiento (HU-05-04). Cada comercio se vence con su contexto. */
export interface VencimientoRepository {
  /** Ids de los comercios con tiqueteras activas cuyo vencimiento ya pasó. */
  comerciosConVencidas(ahora: Date): Promise<string[]>;
  /**
   * Marca vencidas esas tiqueteras del comercio: evento EXPIRATION (origen SYSTEM_JOB)
   * que quita las unidades que quedaban. Devuelve cuántas venció.
   */
  vencer(comercioId: string, ahora: Date): Promise<number>;
}

export const VENCIMIENTO_REPOSITORY = Symbol('VencimientoRepository');
