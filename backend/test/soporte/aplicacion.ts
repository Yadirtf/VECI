import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { AppModule } from '../../src/app.module';
import { configurarAplicacion } from '../../src/app.setup';
import { urlApp } from './base-de-datos';

/** Levanta la API completa contra la base de pruebas, conectada como veci_api (RLS). */
export async function levantarApi(): Promise<INestApplication> {
  process.env.DATABASE_APP_URL = urlApp();
  // Las pruebas vencen tiqueteras a mano, cuando el escenario lo pide.
  process.env.VECI_VENCIMIENTO_AUTOMATICO = 'false';
  const modulo = await Test.createTestingModule({ imports: [AppModule] }).compile();
  const app = modulo.createNestApplication({ logger: false });
  configurarAplicacion(app);
  await app.init();
  return app;
}
