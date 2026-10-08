import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { Reloj } from '../../../../shared/application/puertos/reloj.port';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { TipoDeTiquetera } from '../../domain/entities/tipo-de-tiquetera';
import { VentaRegistrada } from '../../domain/entities/venta';
import {
  ClienteNoEncontrado,
  ClienteNoPuedeComprar,
  PrecioCambio,
  TipoNoEncontrado,
  TipoNoSeVende,
  VentaDistinta,
} from '../../domain/errors/errores-tiqueteras';
import { validarPago } from '../../domain/rules/pago.rule';
import { LIMITES_TIPO } from '../../domain/rules/reglas-tipo.rule';
import { calcularVencimiento } from '../../domain/rules/vigencia.rule';
import { Actor, VentaInput, VentaOutput } from '../dto/tiqueteras.dto';
import { SaldosRepository } from '../puertos/saldos.repository';
import { TiposRepository } from '../puertos/tipos.repository';
import { NuevaVenta, VentasRepository } from '../puertos/ventas.repository';
import { estadoDeSaldo } from '../servicios/estado-de-saldo';

export interface DependenciasVender {
  tipos: TiposRepository;
  ventas: VentasRepository;
  saldos: SaldosRepository;
  ids: GeneradorIds;
  reloj: Reloj;
}

/** Un celular puede quedarse días sin señal; más de un mes ya no es una venta pendiente. */
const DIAS_MAXIMOS_SIN_CONEXION = 30;
/** Relojes de celular algo adelantados. */
const MINUTOS_DE_TOLERANCIA = 5;
const MS_POR_MINUTO = 60_000;

export const pesos = (valor: number) => `$${valor.toLocaleString('es-CO')}`;

/** Un reintento trae los mismos datos; con otros datos es otra venta con el id repetido. */
function esLaMisma(registrada: VentaRegistrada, venta: VentaInput): boolean {
  return (
    registrada.clienteId === venta.clienteId &&
    registrada.tipoId === venta.tipoId &&
    registrada.precio === venta.precio &&
    registrada.pago.medio === venta.pago.medio &&
    registrada.pago.canal === (venta.pago.canal ?? null)
  );
}

/**
 * Vender una tiquetera (HU-05-02): el saldo del cliente queda cargado de inmediato con
 * un movimiento de compra en el libro. La caja genera el id, así que una venta hecha sin
 * señal y enviada varias veces queda una sola vez (ADR-0004). En línea manda la pizarra
 * (tipo activo y precio vigente); sin conexión la venta ya ocurrió y se guarda tal cual.
 */
export class VenderTiquetera {
  constructor(private readonly d: DependenciasVender) {}

  async ejecutar(actor: Actor, venta: VentaInput): Promise<VentaOutput> {
    const previa = await this.d.ventas.buscar(venta.ventaId);
    if (previa) return this.repetida(previa, venta);
    const nueva = await this.preparar(actor, venta);
    const resultado = await this.d.ventas.registrar(nueva);
    if (resultado === 'REGISTRADA') return this.respuesta(nueva, false);
    // Otro envío del mismo id ganó la carrera; si no se ve, el id es de otro negocio.
    const ganadora = await this.d.ventas.buscar(venta.ventaId);
    if (!ganadora) throw new VentaDistinta();
    return this.repetida(ganadora, venta);
  }

  private async repetida(previa: VentaRegistrada, venta: VentaInput): Promise<VentaOutput> {
    if (!esLaMisma(previa, venta)) throw new VentaDistinta();
    return this.respuesta(previa, true);
  }

  private async preparar(actor: Actor, venta: VentaInput): Promise<NuevaVenta> {
    const tipo = await this.d.tipos.buscar(venta.tipoId);
    if (!tipo) throw new TipoNoEncontrado();
    if (!venta.sinConexion) this.exigirPizarra(tipo, venta.precio);
    this.revisarPrecio(venta.precio);
    await this.revisarCliente(venta);
    const contexto = await this.d.ventas.contexto();
    const ocurridaEn = this.horaReal(venta);
    return {
      ventaId: venta.ventaId,
      tiqueteraId: this.d.ids.siguiente(),
      clienteId: venta.clienteId,
      tipo,
      precio: venta.precio,
      pago: validarPago(venta.pago, contexto.medios),
      ocurridaEn,
      venceEn: calcularVencimiento(ocurridaEn, tipo.vigenciaDias, contexto.zonaHoraria),
      origen: venta.sinConexion ? 'OFFLINE_SYNC' : 'ONLINE',
      actorUsuarioId: actor.usuarioId,
      dispositivoId: actor.dispositivoId,
    };
  }

  private exigirPizarra(tipo: TipoDeTiquetera, precio: number): void {
    if (tipo.estado !== 'ACTIVE') throw new TipoNoSeVende();
    if (tipo.precio !== precio) throw new PrecioCambio(pesos(tipo.precio));
  }

  private revisarPrecio(precio: number): void {
    const { min, max } = LIMITES_TIPO.precio;
    if (!Number.isInteger(precio) || precio < min || precio > max) {
      throw new DatoInvalido('El precio cobrado no es válido.');
    }
  }

  /** En línea solo se le vende a un cliente activo; sin conexión basta con que sea cliente. */
  private async revisarCliente(venta: VentaInput): Promise<void> {
    const estado = await this.d.ventas.estadoDelCliente(venta.clienteId);
    if (!estado) throw new ClienteNoEncontrado();
    if (estado !== 'ACTIVE' && !venta.sinConexion) throw new ClienteNoPuedeComprar();
  }

  private horaReal(venta: VentaInput): Date {
    const ahora = this.d.reloj.ahora();
    if (!venta.sinConexion || !venta.ocurridaEn) return ahora;
    const atraso = ahora.getTime() - venta.ocurridaEn.getTime();
    if (atraso < -MINUTOS_DE_TOLERANCIA * MS_POR_MINUTO) {
      throw new DatoInvalido('La hora de la venta está en el futuro: revisa la hora del celular.');
    }
    if (atraso > DIAS_MAXIMOS_SIN_CONEXION * 24 * 60 * MS_POR_MINUTO) {
      throw new DatoInvalido('Esa venta es de hace más de un mes. Regístrala de nuevo.');
    }
    return venta.ocurridaEn;
  }

  private async respuesta(
    venta: Pick<VentaRegistrada, 'ventaId' | 'clienteId' | 'tiqueteraId' | 'origen'>,
    repetida: boolean,
  ): Promise<VentaOutput> {
    const { ventaId, clienteId, tiqueteraId, origen } = venta;
    const [tiqueteras, zona] = await Promise.all([
      this.d.saldos.delCliente(clienteId),
      this.d.saldos.zonaHoraria(),
    ]);
    const estado = estadoDeSaldo(tiqueteras ?? [], zona, this.d.reloj.ahora());
    const tiquetera = estado.tiqueteras.find((t) => t.tiqueteraId === tiqueteraId);
    if (!tiquetera) throw new Error(`La tiquetera ${tiqueteraId} de la venta no aparece.`);
    return { ventaId, clienteId, repetida, origen, tiquetera, ...estado };
  }
}
