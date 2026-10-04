export interface SyncStats {
  lotesRecibidos: number;
  entregasRecibidas: number;
  eventosUnicos: number;
  eventosAplicados: number;
  eventosRechazados: number;
  reenviosDetectados: number;
  eventosFueraDeOrden: number;
  cortesSimulados: number;
}

/** Contadores de la prueba: cuántas veces llegó algo y cuántas se repitió. */
export interface SyncMetrics {
  batchReceived(): void;
  eventDelivered(): void;
  replayDetected(): void;
  outOfOrderDetected(): void;
  cutSimulated(): void;
  snapshot(): Omit<SyncStats, 'eventosUnicos' | 'eventosAplicados' | 'eventosRechazados'>;
  reset(): void;
}

export const SYNC_METRICS = Symbol('SyncMetrics');
