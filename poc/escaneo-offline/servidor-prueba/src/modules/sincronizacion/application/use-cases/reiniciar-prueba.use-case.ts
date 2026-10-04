import { Inject, Injectable } from '@nestjs/common';
import { INBOUND_EVENT_REPOSITORY, InboundEventRepository } from '../../domain/inbound-event.repository';
import { SYNC_METRICS, SyncMetrics } from '../../domain/sync-metrics';

/** Deja el servidor en cero para repetir la medición. Solo existe en la prueba de concepto. */
@Injectable()
export class ReiniciarPruebaUseCase {
  constructor(
    @Inject(INBOUND_EVENT_REPOSITORY) private readonly events: InboundEventRepository,
    @Inject(SYNC_METRICS) private readonly metrics: SyncMetrics,
  ) {}

  execute(): void {
    this.events.clear();
    this.metrics.reset();
  }
}
