import { InboundEvent } from './inbound-event';

export interface InboundEventRepository {
  findById(id: string): InboundEvent | undefined;
  /** Falla si el id ya existe: la PK es la garantía de idempotencia. */
  insert(event: InboundEvent): void;
  count(): number;
  countByStatus(status: InboundEvent['status']): number;
  /** Hora real del último evento aplicado de ese celular, para medir el orden. */
  lastOccurredAt(deviceId: string): Date | undefined;
  clear(): void;
}

export const INBOUND_EVENT_REPOSITORY = Symbol('InboundEventRepository');
