import { INestApplication, ValidationPipe } from '@nestjs/common';
import { SentryGlobalFilter } from '@sentry/nestjs/setup';
import { HttpAdapterHost } from '@nestjs/core';
import { CONFIGURACION, Configuracion } from './shared/infrastructure/config/configuracion';
import { ErroresDeDominioFilter } from './shared/presentation/http/filtros/errores-de-dominio.filter';
import { publicarDocumentacion } from './shared/presentation/http/openapi/documentacion';

/** Configuración común a main.ts, las pruebas e2e y la exportación de OpenAPI. */
export function configurarAplicacion(app: INestApplication): Configuracion {
  const config = app.get<Configuracion>(CONFIGURACION);
  app.enableCors({ origin: [...config.origenesPermitidos] });
  app.useGlobalPipes(
    new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
  );
  app.useGlobalFilters(
    new SentryGlobalFilter(app.get(HttpAdapterHost).httpAdapter),
    new ErroresDeDominioFilter(),
  );
  app.enableShutdownHooks();
  if (config.documentacionActiva) publicarDocumentacion(app);
  return config;
}
