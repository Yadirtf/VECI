import { InboundEvent } from '../../domain/inbound-event';
import { InboundEventRepository } from '../../domain/inbound-event.repository';

/**
 * Sustituto en memoria de sync.inbound_events. Reproduce la restricción de PK:
 * insertar un id repetido lanza error, igual que PostgreSQL.
 */
export class InMemoryInboundEventRepository implements InboundEventRepository {
  private readonly rows = new Map<string, InboundEvent>();
  private readonly lastByDevice = new Map<string, Date>();

  findById(id: string): InboundEvent | undefined {
    return this.rows.get(id);
  }

  insert(event: InboundEvent): void {
    if (this.rows.has(event.id)) {
      throw new Error(`duplicate key value violates unique constraint "inbound_events_pkey" (${event.id})`);
    }
    this.rows.set(event.id, event);
    if (event.status === 'APPLIED') this.trackLast(event);
  }

  count(): number {
    return this.rows.size;
  }

  countByStatus(status: InboundEvent['status']): number {
    let total = 0;
    for (const row of this.rows.values()) if (row.status === status) total++;
    return total;
  }

  lastOccurredAt(deviceId: string): Date | undefined {
    return this.lastByDevice.get(deviceId);
  }

  clear(): void {
    this.rows.clear();
    this.lastByDevice.clear();
  }

  private trackLast(event: InboundEvent): void {
    const last = this.lastByDevice.get(event.deviceId);
    if (!last || event.occurredAt > last) this.lastByDevice.set(event.deviceId, event.occurredAt);
  }
}
