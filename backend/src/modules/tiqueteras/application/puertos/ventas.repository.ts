import { Motivo } from '../../domain/entities/movimiento';
import { TipoDeTiquetera } from '../../domain/entities/tipo-de-tiquetera';
import {
  EstadoVenta,
  MedioDePago,
  OrigenVenta,
  Pago,
  VentaRegistrada,
} from '../../domain/entities/venta';
import { MotivoRevisado } from '../../domain/rules/correccion.rule';

/** Lo que la venta necesita saber del comercio: su zona horaria y los medios de pago. */
export interface ContextoDeVenta {
  readonly zonaHoraria: string;
  readonly medios: MedioDePago[];
}

/** Una venta lista para el libro: evento, línea, pago, tiquetera y su asiento (+N). */
export interface NuevaVenta {
  readonly ventaId: string;
  readonly tiqueteraId: string;
  readonly clienteId: string;
  readonly tipo: TipoDeTiquetera;
  readonly precio: number;
  readonly pago: Pago;
  readonly ocurridaEn: Date;
  readonly venceEn: Date;
  readonly origen: OrigenVenta;
  readonly actorUsuarioId: string;
  readonly dispositivoId: string | null;
}

/** Una venta para la lista del propietario (anular). */
export interface VentaResumen {
  readonly ventaId: string;
  readonly clienteId: string;
  readonly cliente: string;
  readonly tiquetera: string;
  readonly precio: number;
  readonly pago: Pago;
  readonly ocurridaEn: Date;
  readonly origen: OrigenVenta;
  readonly estado: EstadoVenta;
  readonly cajero: string | null;
  /** Unidades que le quedan a la tiquetera de esa venta. */
  readonly saldo: number;
}

/** Anular: evento SALE_VOID que reversa la venta y quita lo que quedaba (RF-TIQ-06). */
export interface Anulacion {
  readonly anulacionId: string;
  readonly ventaId: string;
  readonly motivo: MotivoRevisado;
  readonly actorUsuarioId: string;
  readonly dispositivoId: string | null;
}

export type ResultadoRegistro = 'REGISTRADA' | 'YA_EXISTIA';

/** Ventas del comercio activo (HU-05-02, HU-05-05). Todo corre con RLS. */
export interface VentasRepository {
  contexto(): Promise<ContextoDeVenta>;
  /** Estado de la afiliación del cliente; null si no es de este comercio. */
  estadoDelCliente(clienteId: string): Promise<'ACTIVE' | 'BLOCKED' | 'ENDED' | null>;
  buscar(ventaId: string): Promise<VentaRegistrada | null>;
  /**
   * Escribe la venta y su rastro de auditoría en una transacción. Si el id ya existe
   * (otro envío de la misma venta ganó la carrera) no escribe nada y lo dice.
   */
  registrar(venta: NuevaVenta): Promise<ResultadoRegistro>;
  recientes(limite: number): Promise<VentaResumen[]>;
  /** Motivos que sirven para anular o ajustar (ledger.event_reasons). */
  motivos(): Promise<Motivo[]>;
  /** Bloquea la venta, revisa que siga completada y la anula con su auditoría. */
  anular(anulacion: Anulacion): Promise<void>;
}

export const VENTAS_REPOSITORY = Symbol('VentasRepository');
