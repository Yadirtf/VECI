import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { UuidV7Generator } from '../src/shared/infrastructure/uuid-v7.generator';

const TENANT = '01920000-0000-7000-8000-000000000001';
const ids = new UuidV7Generator();

function mil(): object[] {
  const start = Date.now() - 7 * 24 * 3600 * 1000;
  return Array.from({ length: 1000 }, (_, i) => ({
    id: ids.next(),
    kind: 'CONSUMPTION',
    occurred_at: new Date(start + i * 60_000).toISOString(),
    payload: { tenant_id: TENANT, affiliation_qr_code_id: ids.next(), units_requested: 1 },
  }));
}

describe('POST /poc/sync/batches (e2e)', () => {
  let app: INestApplication;
  const device = ids.next();

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    configureApp(app);
    await app.init();
  });

  afterAll(() => app.close());

  const send = (batchId: string, events: object[]) =>
    request(app.getHttpServer())
      .post('/poc/sync/batches')
      .send({ batch_id: batchId, device_id: device, tenant_id: TENANT, events })
      .expect(200);

  it('1.000 eventos con cada lote reenviado dos veces quedan 1.000, sin duplicados', async () => {
    const events = mil();
    for (let i = 0; i < events.length; i += 100) {
      const batchId = ids.next();
      const slice = events.slice(i, i + 100);
      const first = await send(batchId, slice);
      const again = await send(batchId, slice);
      expect(first.body.results.every((r: { replayed: boolean }) => !r.replayed)).toBe(true);
      expect(again.body.results.every((r: { replayed: boolean }) => r.replayed)).toBe(true);
    }
    const stats = await request(app.getHttpServer()).get('/poc/sync/stats').expect(200);
    expect(stats.body).toMatchObject({
      eventosUnicos: 1000,
      eventosAplicados: 1000,
      entregasRecibidas: 2000,
      reenviosDetectados: 1000,
      eventosFueraDeOrden: 0,
    });
  });

  it('rechaza un lote mal formado con 400', async () => {
    await request(app.getHttpServer())
      .post('/poc/sync/batches')
      .send({ batch_id: 'x', device_id: device, tenant_id: TENANT, events: [] })
      .expect(400);
  });
});
