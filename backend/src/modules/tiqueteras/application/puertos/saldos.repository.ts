import { Movimiento } from '../../domain/entities/movimiento';
import { Tiquetera } from '../../domain/entities/tiquetera';
import { MotivoRevisado } from '../../domain/rules/correccion.rule';

/** Ajuste: evento ADJUSTMENT con su asiento de ± unidades en una tiquetera (RF-TIQ-06). */
export interface Ajuste {
  readonly ajusteId: string;
  readonly tiqueteraId: string;
  readonly unidades: number;
  readonly motivo: MotivoRevisado;
  readonly actorUsuarioId: string;
  readonly dispositivoId: string | null;
}

/** Tiqueteras de la persona en uno de sus negocios, vistas desde su app. */
export interface TiqueterasEnComercio {
  readonly comercioId: string;
  readonly comercio: string;
  readonly zonaHoraria: string;
  readonly tiqueteras: Tiquetera[];
}

/** Saldos y su historia (HU-05-03, HU-05-05). El comercio activo o la persona fijan RLS. */
export interface SaldosRepository {
  zonaHoraria(): Promise<string>;
  /** Tiqueteras del cliente en el comercio activo; null si no es su cliente. */
  delCliente(clienteId: string): Promise<Tiquetera[] | null>;
  /** Lo último que pasó con el saldo del cliente, del más reciente al más antiguo. */
  movimientos(clienteId: string, limite: number): Promise<Movimiento[]>;
  tiquetera(tiqueteraId: string): Promise<Tiquetera | null>;
  /**
   * Bloquea la tiquetera, vuelve a revisar el ajuste con [revisar] sobre el saldo de ese
   * momento y escribe el ajuste con su auditoría en una transacción.
   */
  ajustar(ajuste: Ajuste, revisar: (actual: Tiquetera) => void): Promise<void>;
  /** Tiqueteras de la persona de la sesión en todos sus negocios (customer_self). */
  deLaPersona(usuarioId: string): Promise<TiqueterasEnComercio[]>;
}

export const SALDOS_REPOSITORY = Symbol('SaldosRepository');
