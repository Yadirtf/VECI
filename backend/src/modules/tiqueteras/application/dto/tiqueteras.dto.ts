import { Movimiento } from '../../domain/entities/movimiento';
import { TipoDeTiquetera, UnidadDeConsumo } from '../../domain/entities/tipo-de-tiquetera';
import { Tiquetera } from '../../domain/entities/tiquetera';
import { MedioDePago, OrigenVenta, Pago } from '../../domain/entities/venta';

/** Quién actúa, en qué comercio y desde qué dispositivo. */
export interface Actor {
  readonly usuarioId: string;
  readonly comercioId: string;
  readonly dispositivoId: string | null;
}

export interface TipoOutput extends TipoDeTiquetera {
  readonly precioPorUnidad: number;
}

/** Lo que la caja guarda para vender sin internet: tipos activos y medios de pago. */
export interface CatalogoDeVenta {
  readonly version: string;
  readonly tipos: TipoOutput[];
  readonly medios: MedioDePago[];
}

export interface TiqueteraOutput extends Tiquetera {
  /** Último día en que sirve, en la fecha del negocio (AAAA-MM-DD). */
  readonly ultimoDia: string;
  readonly vigente: boolean;
  /** 1 = la que se gasta primero; null si ya no sirve. */
  readonly turno: number | null;
}

export interface SaldoOutput {
  readonly unidad: UnidadDeConsumo;
  readonly disponibles: number;
  readonly proximoVencimiento: Date;
  readonly ultimoDia: string;
  readonly tiqueteras: number;
}

/** El saldo del cliente en un negocio: por unidad y tiquetera por tiquetera. */
export interface EstadoDeSaldo {
  readonly saldos: SaldoOutput[];
  readonly tiqueteras: TiqueteraOutput[];
}

export interface EstadoDeCuenta extends EstadoDeSaldo {
  readonly clienteId: string;
  readonly movimientos: Movimiento[];
}

export interface VentaInput {
  /** UUID v7 que genera la caja: la misma venta enviada dos veces no se duplica. */
  readonly ventaId: string;
  readonly clienteId: string;
  readonly tipoId: string;
  /** Lo que la caja le cobró al cliente. */
  readonly precio: number;
  readonly pago: Pago;
  /** Hora real de la venta; solo cuenta si se hizo sin conexión. */
  readonly ocurridaEn: Date | null;
  readonly sinConexion: boolean;
}

export interface VentaOutput extends EstadoDeSaldo {
  readonly ventaId: string;
  readonly clienteId: string;
  /** La misma venta ya había llegado: no se registró otra vez. */
  readonly repetida: boolean;
  readonly origen: OrigenVenta;
  readonly tiquetera: TiqueteraOutput;
}

export interface MisTiqueterasOutput extends EstadoDeSaldo {
  readonly comercioId: string;
  readonly comercio: string;
}
