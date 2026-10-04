import { UuidV7Generator } from '../../../../shared/infrastructure/uuid-v7.generator';
import { IncomingEvent } from '../../domain/inbound-event';
import { InMemorySyncMetrics } from '../../infrastructure/in-memory-sync-metrics';
import { InMemoryInboundEventRepository } from '../../infrastructure/persistence/in-memory-inbound-event.repository';
import { Sha256PayloadHasher } from '../../infrastructure/sha256-payload.hasher';
import { RecibirLoteUseCase } from './recibir-lote.use-case';

const TENANT = '01920000-0000-7000-8000-000000000001';
const ids = new UuidV7Generator();

function consumo(overrides: Partial<IncomingEvent> = {}): IncomingEvent {
  return {
    id: ids.next(),
    kind: 'CONSUMPTION',
    occurredAt: new Date().toISOString(),
    payload: { tenant_id: TENANT, affiliation_qr_code_id: ids.next(), units_requested: 1 },
    ...overrides,
  };
}

function setup() {
  const repo = new InMemoryInboundEventRepository();
  const metrics = new InMemorySyncMetrics();
  const useCase = new RecibirLoteUseCase(repo, new Sha256PayloadHasher(), metrics);
  const send = (events: IncomingEvent[]) =>
    useCase.execute({ batchId: ids.next(), deviceId: ids.next(), tenantId: TENANT, events });
  return { repo, metrics, send };
}

describe('RecibirLoteUseCase', () => {
  it('aplica un evento nuevo', () => {
    const { repo, send } = setup();
    const { results } = send([consumo()]);
    expect(results[0]).toMatchObject({ status: 'APPLIED', replayed: false });
    expect(repo.count()).toBe(1);
  });

  it('un reenvío devuelve el resultado guardado sin duplicar', () => {
    const { repo, metrics, send } = setup();
    const event = consumo();
    send([event]);
    const { results } = send([event]);
    expect(results[0]).toMatchObject({ status: 'APPLIED', replayed: true });
    expect(repo.count()).toBe(1);
    expect(metrics.snapshot().reenviosDetectados).toBe(1);
  });

  it('rechaza el mismo id con contenido distinto y conserva el original', () => {
    const { repo, send } = setup();
    const event = consumo();
    send([event]);
    const altered = { ...event, payload: { ...event.payload, units_requested: 9 } };
    const { results } = send([altered]);
    expect(results[0]).toMatchObject({ status: 'REJECTED', rejectionReason: 'VALIDATION_ERROR' });
    expect(repo.findById(event.id)?.status).toBe('APPLIED');
  });

  it('rechaza eventos de otro comercio', () => {
    const { send } = setup();
    const event = consumo({ payload: { tenant_id: 'otro', affiliation_qr_code_id: ids.next() } });
    expect(send([event]).results[0]).toMatchObject({ status: 'REJECTED', rejectionReason: 'QR_FROM_OTHER_TENANT' });
  });

  it('rechaza ids que no son UUID v7 y horas en el futuro', () => {
    const { send } = setup();
    const future = new Date(Date.now() + 60 * 60 * 1000).toISOString();
    const { results } = send([consumo({ id: crypto.randomUUID() }), consumo({ occurredAt: future })]);
    expect(results.map((r) => r.rejectionReason)).toEqual(['VALIDATION_ERROR', 'VALIDATION_ERROR']);
  });
});
