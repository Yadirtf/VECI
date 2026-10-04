import { SyncMetrics } from '../domain/sync-metrics';

export class InMemorySyncMetrics implements SyncMetrics {
  private counters = InMemorySyncMetrics.zero();

  batchReceived(): void {
    this.counters.lotesRecibidos++;
  }

  eventDelivered(): void {
    this.counters.entregasRecibidas++;
  }

  replayDetected(): void {
    this.counters.reenviosDetectados++;
  }

  outOfOrderDetected(): void {
    this.counters.eventosFueraDeOrden++;
  }

  cutSimulated(): void {
    this.counters.cortesSimulados++;
  }

  snapshot() {
    return { ...this.counters };
  }

  reset(): void {
    this.counters = InMemorySyncMetrics.zero();
  }

  private static zero() {
    return { lotesRecibidos: 0, entregasRecibidas: 0, reenviosDetectados: 0, eventosFueraDeOrden: 0, cortesSimulados: 0 };
  }
}
