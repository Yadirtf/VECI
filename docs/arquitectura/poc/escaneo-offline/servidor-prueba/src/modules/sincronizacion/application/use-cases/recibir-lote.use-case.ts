import { Inject, Injectable } from '@nestjs/common';
import { EventResult, IncomingEvent, InboundEvent } from '../../domain/inbound-event';
import { INBOUND_EVENT_REPOSITORY, InboundEventRepository } from '../../domain/inbound-event.repository';
import { PAYLOAD_HASHER, PayloadHasher } from '../../domain/payload-hasher';
import { validarEvento } from '../../domain/rules/validar-evento.rule';
import { SYNC_METRICS, SyncMetrics } from '../../domain/sync-metrics';

export interface RecibirLoteInput {
  batchId: string;
  deviceId: string;
  tenantId: string;
  events: IncomingEvent[];
}

export interface RecibirLoteOutput {
  batchId: string;
  results: EventResult[];
}

/**
 * Recibe un lote de la bandeja de salida (sección 5 del modelo de datos, pasos 1 a 3).
 * Cada evento se registra una sola vez por su id; un reenvío devuelve el resultado guardado.
 */
@Injectable()
export class RecibirLoteUseCase {
  constructor(
    @Inject(INBOUND_EVENT_REPOSITORY) private readonly events: InboundEventRepository,
    @Inject(PAYLOAD_HASHER) private readonly hasher: PayloadHasher,
    @Inject(SYNC_METRICS) private readonly metrics: SyncMetrics,
  ) {}

  execute(input: RecibirLoteInput): RecibirLoteOutput {
    this.metrics.batchReceived();
    const results = input.events.map((event) => this.receive(event, input));
    return { batchId: input.batchId, results };
  }

  private receive(event: IncomingEvent, input: RecibirLoteInput): EventResult {
    this.metrics.eventDelivered();
    const hash = this.hasher.hash(event.payload);
    const existing = this.events.findById(event.id);
    if (existing) return this.replay(existing, hash);
    const now = new Date();
    const reason = validarEvento(event, { tenantId: input.tenantId, now });
    const occurredAt = new Date(event.occurredAt);
    this.trackOrder(input.deviceId, occurredAt, reason === null);
    this.events.insert({
      id: event.id,
      tenantId: input.tenantId,
      batchId: input.batchId,
      deviceId: input.deviceId,
      kind: event.kind,
      occurredAt,
      receivedAt: now,
      payloadSha256: hash,
      status: reason === null ? 'APPLIED' : 'REJECTED',
      rejectionReason: reason,
    });
    return { id: event.id, status: reason === null ? 'APPLIED' : 'REJECTED', rejectionReason: reason, replayed: false };
  }

  /** Mismo id: si el contenido es igual es un reintento; si cambió, se rechaza sin tocar lo guardado. */
  private replay(existing: InboundEvent, hash: string): EventResult {
    if (existing.payloadSha256 !== hash) {
      return { id: existing.id, status: 'REJECTED', rejectionReason: 'VALIDATION_ERROR', replayed: true };
    }
    this.metrics.replayDetected();
    return { id: existing.id, status: existing.status, rejectionReason: existing.rejectionReason, replayed: true };
  }

  private trackOrder(deviceId: string, occurredAt: Date, applied: boolean): void {
    if (!applied) return;
    const last = this.events.lastOccurredAt(deviceId);
    if (last && occurredAt < last) this.metrics.outOfOrderDetected();
  }
}
