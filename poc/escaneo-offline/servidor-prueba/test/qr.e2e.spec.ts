import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { createPublicKey, verify } from 'node:crypto';
import request from 'supertest';
import { AppModule } from '../src/app.module';

/** Verifica el token igual que lo hará el celular: solo con la clave pública. */
function verifies(token: string, publicKeyBase64: string): boolean {
  const cut = token.lastIndexOf('.');
  const key = createPublicKey({
    key: { kty: 'OKP', crv: 'Ed25519', x: Buffer.from(publicKeyBase64, 'base64').toString('base64url') },
    format: 'jwk',
  });
  return verify(null, Buffer.from(token.slice(0, cut), 'ascii'), key, Buffer.from(token.slice(cut + 1), 'base64url'));
}

describe('QR de prueba (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    await app.init();
  });

  afterAll(() => app.close());

  it('la hoja y los datos offline permiten validar cada QR como se espera', async () => {
    const sheet = (await request(app.getHttpServer()).get('/poc/qr-de-prueba.json').expect(200)).body;
    const offline = (await request(app.getHttpServer()).get('/poc/datos-offline').expect(200)).body;
    const key = offline.signingKeys[0].publicKeyBase64;
    const byExpected = (e: string) => sheet.filter((q: { expected: string }) => q.expected === e);

    expect(byExpected('VALIDO')).toHaveLength(5);
    for (const qr of byExpected('VALIDO')) expect(verifies(qr.token, key)).toBe(true);
    expect(verifies(byExpected('FIRMA_INVALIDA')[0].token, key)).toBe(false);
    expect(verifies(byExpected('OTRO_COMERCIO')[0].token, key)).toBe(false);
    expect(offline.revokedQrCodeIds).toHaveLength(1);
  });

  it('la hoja HTML se sirve con imágenes de QR', async () => {
    const page = await request(app.getHttpServer()).get('/poc/qr-de-prueba').expect(200);
    expect(page.text).toContain('data:image/png;base64');
  });
});
