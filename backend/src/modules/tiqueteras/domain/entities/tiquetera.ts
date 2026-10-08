import { UnidadDeConsumo } from './tipo-de-tiquetera';

/** Estado de una tiquetera vendida (prepaid.package_statuses). */
export type EstadoTiquetera = 'ACTIVE' | 'DEPLETED' | 'EXPIRED' | 'VOIDED';

/**
 * Tiquetera vendida a un cliente en este negocio. Su saldo es la suma del libro
 * (ADR-0003); aquí llega la caché que mantiene la base en la misma transacción.
 */
export interface Tiquetera {
  readonly tiqueteraId: string;
  readonly clienteId: string;
  readonly ventaId: string;
  readonly tipoId: string;
  readonly nombre: string;
  readonly unidad: UnidadDeConsumo;
  readonly compradas: number;
  readonly saldo: number;
  readonly estado: EstadoTiquetera;
  readonly compradaEn: Date;
  /** Primer instante en que ya no sirve: medianoche del negocio después del último día. */
  readonly venceEn: Date;
  /** Precio que se cobró por ella; null en la app del cliente, que no ve la venta. */
  readonly precio: number | null;
}
