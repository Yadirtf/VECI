import './cargar-entorno';
import './instrument';
import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { configurarAplicacion } from './app.setup';

async function arrancar(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  const config = configurarAplicacion(app);
  await app.listen(config.puerto, '0.0.0.0');
}

void arrancar();
