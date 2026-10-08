/** Unidad que se descuenta: almuerzo, desayuno, café… */
export interface Unidad {
  codigo: string;
  singular: string;
  plural: string;
}

export type EstadoTipo = 'ACTIVE' | 'INACTIVE' | 'ARCHIVED';

/** Un renglón de la pizarra: "20 almuerzos por $220.000, sirve 30 días". */
export interface TipoDeTiquetera {
  tipoId: string;
  nombre: string;
  unidad: Unidad;
  unidades: number;
  precio: number;
  precioPorUnidad: number;
  vigenciaDias: number;
  estado: EstadoTipo;
  vendidas: number;
  vigentes: number;
}

export interface DatosDeTipo {
  nombre: string;
  unidad: string;
  unidades: number;
  precio: number;
  vigenciaDias: number;
}

export type EstadoTiquetera = 'ACTIVE' | 'DEPLETED' | 'EXPIRED' | 'VOIDED';

export interface Tiquetera {
  tiqueteraId: string;
  ventaId: string;
  nombre: string;
  unidad: Unidad;
  compradas: number;
  saldo: number;
  estado: EstadoTiquetera;
  compradaEn: Date;
  /** Último día en que sirve, en la fecha del negocio (AAAA-MM-DD). */
  ultimoDia: string;
  vigente: boolean;
  /** 1 = la que se gasta primero. */
  turno: number | null;
  precio: number | null;
}

/** Saldo de una unidad: la suma de las tiqueteras vigentes. */
export interface SaldoPorUnidad {
  unidad: Unidad;
  disponibles: number;
  ultimoDia: string;
  tiqueteras: number;
}

export type TipoDeMovimiento =
  'SALE' | 'CONSUMPTION' | 'CONSUMPTION_REVERSAL' | 'SALE_VOID' | 'ADJUSTMENT' | 'EXPIRATION';

/** Un renglón de la historia: nada se borra, una corrección es un renglón nuevo. */
export interface Movimiento {
  eventoId: string;
  tipo: TipoDeMovimiento;
  ocurridoEn: Date;
  unidades: number;
  tiquetera: string | null;
  motivo: string | null;
  nota: string | null;
  quien: string | null;
}

export interface EstadoDeCuenta {
  clienteId: string;
  saldos: SaldoPorUnidad[];
  tiqueteras: Tiquetera[];
  movimientos: Movimiento[];
}

export interface Canal {
  codigo: string;
  nombre: string;
}

export interface MedioDePago {
  codigo: string;
  nombre: string;
  necesitaCanal: boolean;
  canales: Canal[];
}

export interface Pago {
  medio: string;
  canal: string | null;
  referencia: string | null;
}

export interface NuevaVenta {
  ventaId: string;
  clienteId: string;
  tipoId: string;
  precio: number;
  pago: Pago;
}

export interface VentaReciente {
  ventaId: string;
  clienteId: string;
  cliente: string;
  tiquetera: string;
  precio: number;
  pago: Pago;
  ocurridaEn: Date;
  sinConexion: boolean;
  anulada: boolean;
  cajero: string | null;
  saldo: number;
}

export interface Motivo {
  codigo: string;
  nombre: string;
}

export interface Correccion {
  motivo: string;
  nota: string | null;
}

/** Lo que la API dijo que salió mal; el código es para el programa, el mensaje para la pantalla. */
export class ProblemaTiqueteras extends Error {
  constructor(
    readonly codigo: string,
    mensaje: string,
  ) {
    super(mensaje);
    this.name = 'ProblemaTiqueteras';
  }
}

/** La pizarra del negocio activo. */
export interface RepositorioPizarra {
  tipos(): Promise<TipoDeTiquetera[]>;
  unidades(): Promise<Unidad[]>;
  crear(datos: DatosDeTipo): Promise<TipoDeTiquetera>;
  editar(tipoId: string, datos: DatosDeTipo): Promise<TipoDeTiquetera>;
  cambiarEstado(tipoId: string, activo: boolean): Promise<TipoDeTiquetera>;
}

/** Ventas, saldos y correcciones del negocio activo. */
export interface RepositorioCuentas {
  catalogo(): Promise<{ tipos: TipoDeTiquetera[]; medios: MedioDePago[] }>;
  cuenta(clienteId: string): Promise<EstadoDeCuenta>;
  vender(venta: NuevaVenta): Promise<EstadoDeCuenta>;
  ventas(): Promise<VentaReciente[]>;
  motivos(): Promise<Motivo[]>;
  anular(ventaId: string, correccion: Correccion): Promise<EstadoDeCuenta>;
  ajustar(tiqueteraId: string, unidades: number, correccion: Correccion): Promise<EstadoDeCuenta>;
}
