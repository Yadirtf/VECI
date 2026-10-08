/** Tipo de evento del libro (ledger.event_types). */
export type TipoDeEvento =
  'SALE' | 'CONSUMPTION' | 'CONSUMPTION_REVERSAL' | 'SALE_VOID' | 'ADJUSTMENT' | 'EXPIRATION';

/** Motivo de un ajuste o una anulación (ledger.event_reasons). */
export interface Motivo {
  readonly codigo: string;
  readonly nombre: string;
}

/**
 * Un renglón de la historia del cliente: cada hecho con quién, cuándo y cuántas
 * unidades movió. Nada se borra; una corrección es un renglón nuevo (RF-TIQ-06).
 */
export interface Movimiento {
  readonly eventoId: string;
  readonly tipo: TipoDeEvento;
  readonly ocurridoEn: Date;
  readonly unidades: number;
  readonly tiquetera: string | null;
  readonly motivo: string | null;
  readonly nota: string | null;
  readonly quien: string | null;
  /** Evento que este corrige (anulación o reverso). */
  readonly corrigeA: string | null;
}
