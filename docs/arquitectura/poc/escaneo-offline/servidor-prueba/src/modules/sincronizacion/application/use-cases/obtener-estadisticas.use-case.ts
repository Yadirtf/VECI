import { Inject, Injectable } from '@nestjs/common';
import { INBOUND_EVENT_REPOSITORY, InboundEventRepository } from '../../domain/inbound-event.repository';
import { SYNC_METRICS, SyncMetrics, SyncStats } from '../../domain/sync-metrics';

/** Resumen para comprobar "sin duplicados": únicos vs. entregas recibidas. */
@Injectable()
export class ObtenerEstadisticasUseCase {
  constructor(
    @Inject(INBOUND_EVENT_REPOSITORY) private readonly events: InboundEventRepository,
    @Inject(SYNC_METRICS) private readonly metrics: SyncMetrics,
  ) {}

  execute(): SyncStats {
    return {
      ...this.metrics.snapshot(),
      eventosUnicos: this.events.count(),
      eventosAplicados: this.events.countByStatus('APPLIED'),
      eventosRechazados: this.events.countByStatus('REJECTED'),
    };
  }
}
