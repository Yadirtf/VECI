import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { Reloj } from '../../../../shared/application/puertos/reloj.port';
import { Motivo } from '../../domain/entities/movimiento';
import {
  TiqueteraNoEncontrada,
  VentaNoEncontrada,
  VentaYaAnulada,
} from '../../domain/errors/errores-tiqueteras';
import { validarAjuste, validarMotivo } from '../../domain/rules/correccion.rule';
import { Actor, EstadoDeCuenta } from '../dto/tiqueteras.dto';
import { SaldosRepository } from '../puertos/saldos.repository';
import { VentaResumen, VentasRepository } from '../puertos/ventas.repository';
import { ConsultarSaldoDelCliente } from './consultar-saldos.use-case';

export interface DependenciasCorregir {
  ventas: VentasRepository;
  saldos: SaldosRepository;
  ids: GeneradorIds;
  reloj: Reloj;
}

export interface Correccion {
  readonly motivo: string;
  readonly nota: string | null;
}

/** Ventas que el propietario ve para revisar y anular. */
const VENTAS_RECIENTES = 50;

/**
 * Anular una venta o ajustar un saldo (HU-05-05). Solo el propietario (permiso del
 * rol), siempre con motivo, sin borrar nada: cada corrección es un evento nuevo del
 * libro y queda en la bitácora con usuario, fecha y hora (RNF-SEG-05).
 */
export class CorregirSaldos {
  private readonly consultar: ConsultarSaldoDelCliente;

  constructor(private readonly d: DependenciasCorregir) {
    this.consultar = new ConsultarSaldoDelCliente(d.saldos, d.reloj);
  }

  motivos(): Promise<Motivo[]> {
    return this.d.ventas.motivos();
  }

  ventasRecientes(): Promise<VentaResumen[]> {
    return this.d.ventas.recientes(VENTAS_RECIENTES);
  }

  async anular(actor: Actor, ventaId: string, correccion: Correccion): Promise<EstadoDeCuenta> {
    const venta = await this.d.ventas.buscar(ventaId);
    if (!venta) throw new VentaNoEncontrada();
    if (venta.estado === 'VOIDED') throw new VentaYaAnulada();
    const motivo = validarMotivo(correccion.motivo, correccion.nota, await this.d.ventas.motivos());
    await this.d.ventas.anular({
      anulacionId: this.d.ids.siguiente(),
      ventaId,
      motivo,
      actorUsuarioId: actor.usuarioId,
      dispositivoId: actor.dispositivoId,
    });
    return this.consultar.ejecutar(venta.clienteId);
  }

  async ajustar(
    actor: Actor,
    tiqueteraId: string,
    unidades: number,
    correccion: Correccion,
  ): Promise<EstadoDeCuenta> {
    const tiquetera = await this.d.saldos.tiquetera(tiqueteraId);
    if (!tiquetera) throw new TiqueteraNoEncontrada();
    validarAjuste(tiquetera, unidades, this.d.reloj.ahora());
    const motivo = validarMotivo(correccion.motivo, correccion.nota, await this.d.ventas.motivos());
    const ajuste = {
      ajusteId: this.d.ids.siguiente(),
      tiqueteraId,
      unidades,
      motivo,
      actorUsuarioId: actor.usuarioId,
      dispositivoId: actor.dispositivoId,
    };
    // Con la tiquetera bloqueada se revisa otra vez: un consumo pudo llegar entre tanto.
    await this.d.saldos.ajustar(ajuste, (actual) =>
      validarAjuste(actual, unidades, this.d.reloj.ahora()),
    );
    return this.consultar.ejecutar(tiquetera.clienteId);
  }
}
