import { Global, MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ALMACEN_CONTEXTO } from './application/contexto/almacen-contexto.port';
import { RESOLVEDOR_IDENTIDAD } from './application/contexto/resolvedor-identidad.port';
import { VERIFICADOR_MEMBRESIA } from './application/contexto/verificador-membresia.port';
import { GENERADOR_IDS } from './application/puertos/generador-ids.port';
import { OBSERVABILIDAD } from './application/puertos/observabilidad.port';
import {
  CONFIGURACION,
  Configuracion,
  leerConfiguracion,
} from './infrastructure/config/configuracion';
import { AlmacenContextoAsincrono } from './infrastructure/contexto/almacen-contexto-asincrono';
import { PrismaVerificadorMembresia } from './infrastructure/contexto/prisma-verificador-membresia';
import { IdentidadDesarrolloResolvedor } from './infrastructure/identidad/identidad-desarrollo.resolvedor';
import { GeneradorUuidV7 } from './infrastructure/ids/uuid-v7.generador';
import { SentryObservabilidad } from './infrastructure/observabilidad/sentry-observabilidad';
import { PrismaService } from './infrastructure/prisma/prisma.service';
import { TransaccionComercio } from './infrastructure/prisma/transaccion-comercio';
import { ComercioActivoGuard } from './presentation/http/guards/comercio-activo.guard';
import { ContextoPeticionMiddleware } from './presentation/http/middleware/contexto-peticion.middleware';

/** Piezas transversales: configuración, base de datos, contexto del comercio e ids. */
@Global()
@Module({
  providers: [
    { provide: CONFIGURACION, useFactory: () => leerConfiguracion() },
    { provide: ALMACEN_CONTEXTO, useClass: AlmacenContextoAsincrono },
    { provide: VERIFICADOR_MEMBRESIA, useClass: PrismaVerificadorMembresia },
    {
      provide: RESOLVEDOR_IDENTIDAD,
      useFactory: (config: Configuracion) =>
        new IdentidadDesarrolloResolvedor(config.identidadDesarrollo),
      inject: [CONFIGURACION],
    },
    { provide: OBSERVABILIDAD, useClass: SentryObservabilidad },
    { provide: GENERADOR_IDS, useClass: GeneradorUuidV7 },
    PrismaService,
    TransaccionComercio,
    ComercioActivoGuard,
  ],
  exports: [
    CONFIGURACION,
    ALMACEN_CONTEXTO,
    VERIFICADOR_MEMBRESIA,
    RESOLVEDOR_IDENTIDAD,
    OBSERVABILIDAD,
    GENERADOR_IDS,
    PrismaService,
    TransaccionComercio,
    ComercioActivoGuard,
  ],
})
export class SharedModule implements NestModule {
  configure(consumidor: MiddlewareConsumer): void {
    consumidor.apply(ContextoPeticionMiddleware).forRoutes('*');
  }
}
