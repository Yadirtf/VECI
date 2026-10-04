import { Body, Controller, Get, HttpCode, Inject, Post, Query, Res } from '@nestjs/common';
import { Response } from 'express';
import { ObtenerEstadisticasUseCase } from '../../application/use-cases/obtener-estadisticas.use-case';
import { RecibirLoteOutput, RecibirLoteUseCase } from '../../application/use-cases/recibir-lote.use-case';
import { ReiniciarPruebaUseCase } from '../../application/use-cases/reiniciar-prueba.use-case';
import { SYNC_METRICS, SyncMetrics } from '../../domain/sync-metrics';
import { RecibirLoteRequest } from './recibir-lote.request';
import { parseRate, SimuladorDeCortes } from './simulador-de-cortes';

@Controller('poc/sync')
export class SincronizacionController {
  constructor(
    private readonly recibirLote: RecibirLoteUseCase,
    private readonly estadisticas: ObtenerEstadisticasUseCase,
    private readonly reiniciar: ReiniciarPruebaUseCase,
    private readonly cortes: SimuladorDeCortes,
    @Inject(SYNC_METRICS) private readonly metrics: SyncMetrics,
  ) {}

  /** `?simular_corte=0.3` corta la respuesta del 30 % de los lotes después de guardarlos. */
  @Post('batches')
  @HttpCode(200)
  recibir(
    @Body() body: RecibirLoteRequest,
    @Query('simular_corte') simularCorte: string | undefined,
    @Res({ passthrough: true }) res: Response,
  ): RecibirLoteOutput | undefined {
    const output = this.recibirLote.execute({
      batchId: body.batch_id,
      deviceId: body.device_id,
      tenantId: body.tenant_id,
      events: body.events.map((e) => ({ id: e.id, kind: e.kind, occurredAt: e.occurred_at, payload: e.payload })),
    });
    if (this.cortes.maybeCut(parseRate(simularCorte), res)) {
      this.metrics.cutSimulated();
      return undefined;
    }
    return output;
  }

  @Get('stats')
  stats() {
    return this.estadisticas.execute();
  }

  @Post('reset')
  @HttpCode(204)
  reset(): void {
    this.reiniciar.execute();
  }
}
