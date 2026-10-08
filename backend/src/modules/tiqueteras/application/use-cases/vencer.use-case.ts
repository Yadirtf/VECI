import { Observabilidad } from '../../../../shared/application/puertos/observabilidad.port';
import { Reloj } from '../../../../shared/application/puertos/reloj.port';
import { VencimientoRepository } from '../puertos/vencimiento.repository';

export interface ResultadoVencimiento {
  readonly comercios: number;
  readonly tiqueteras: number;
  /** Comercios en que falló; se reintentan en la siguiente vuelta. */
  readonly fallidos: number;
}

/**
 * Vencimiento automático (HU-05-04): marca vencidas las tiqueteras activas cuya
 * vigencia terminó y deja en el libro las unidades que se perdieron, para reportes.
 * Recorre los comercios uno por uno con su contexto; si uno falla sigue con el resto.
 * Es idempotente: correrlo dos veces no vence nada dos veces.
 */
export class VencerTiqueteras {
  constructor(
    private readonly repositorio: VencimientoRepository,
    private readonly reloj: Reloj,
    private readonly observabilidad: Observabilidad,
  ) {}

  async ejecutar(): Promise<ResultadoVencimiento> {
    const ahora = this.reloj.ahora();
    const comercios = await this.repositorio.comerciosConVencidas(ahora);
    let tiqueteras = 0;
    let fallidos = 0;
    for (const comercioId of comercios) {
      try {
        tiqueteras += await this.repositorio.vencer(comercioId, ahora);
      } catch (error) {
        fallidos += 1;
        this.observabilidad.capturarError(error);
      }
    }
    return { comercios: comercios.length, tiqueteras, fallidos };
  }
}
