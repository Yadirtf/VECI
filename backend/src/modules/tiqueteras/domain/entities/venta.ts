/** Medio de pago del catálogo core.payment_methods con sus canales (Nequi, Daviplata...). */
export interface MedioDePago {
  readonly codigo: string;
  readonly nombre: string;
  readonly necesitaCanal: boolean;
  readonly canales: readonly { readonly codigo: string; readonly nombre: string }[];
}

/** Cómo pagó el cliente (HU-05-02). La referencia de la transferencia es opcional. */
export interface Pago {
  readonly medio: string;
  readonly canal: string | null;
  readonly referencia: string | null;
}

/** En línea, o hecha sin señal en el celular y enviada después (ADR-0004). */
export type OrigenVenta = 'ONLINE' | 'OFFLINE_SYNC';

export type EstadoVenta = 'COMPLETED' | 'VOIDED';

/** Una venta registrada en el libro: evento SALE con su línea, su pago y su tiquetera. */
export interface VentaRegistrada {
  readonly ventaId: string;
  readonly clienteId: string;
  readonly tipoId: string;
  readonly tiqueteraId: string;
  readonly precio: number;
  readonly pago: Pago;
  readonly ocurridaEn: Date;
  readonly origen: OrigenVenta;
  readonly estado: EstadoVenta;
}
