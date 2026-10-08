import { Reloj } from '../../../../shared/application/puertos/reloj.port';
import { ClienteNoEncontrado } from '../../domain/errors/errores-tiqueteras';
import { EstadoDeCuenta, MisTiqueterasOutput } from '../dto/tiqueteras.dto';
import { SaldosRepository } from '../puertos/saldos.repository';
import { estadoDeSaldo } from '../servicios/estado-de-saldo';

/** Renglones de historia que se muestran en la ficha; los reportes traen el resto. */
const MOVIMIENTOS_EN_FICHA = 30;

/**
 * Saldo de un cliente en el negocio (HU-05-03): la suma de sus tiqueteras vigentes,
 * cuál se gasta primero y lo último que le pasó a su saldo (HU-05-05: nada se borra).
 */
export class ConsultarSaldoDelCliente {
  constructor(
    private readonly saldos: SaldosRepository,
    private readonly reloj: Reloj,
  ) {}

  async ejecutar(clienteId: string): Promise<EstadoDeCuenta> {
    const [tiqueteras, zona, movimientos] = await Promise.all([
      this.saldos.delCliente(clienteId),
      this.saldos.zonaHoraria(),
      this.saldos.movimientos(clienteId, MOVIMIENTOS_EN_FICHA),
    ]);
    if (!tiqueteras) throw new ClienteNoEncontrado();
    return { clienteId, ...estadoDeSaldo(tiqueteras, zona, this.reloj.ahora()), movimientos };
  }
}

/** El cliente ve en su app el saldo que tiene en cada negocio (HU-05-02, RF-APC-01). */
export class ConsultarMisTiqueteras {
  constructor(
    private readonly saldos: SaldosRepository,
    private readonly reloj: Reloj,
  ) {}

  async ejecutar(usuarioId: string): Promise<MisTiqueterasOutput[]> {
    const ahora = this.reloj.ahora();
    return (await this.saldos.deLaPersona(usuarioId)).map((c) => ({
      comercioId: c.comercioId,
      comercio: c.comercio,
      ...estadoDeSaldo(c.tiqueteras, c.zonaHoraria, ahora),
    }));
  }
}
