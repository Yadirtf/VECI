import { Global, MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ALMACEN_CONTEXTO } from './application/contexto/almacen-contexto.port';
import { RESOLVEDOR_IDENTIDAD } from './application/contexto/resolvedor-identidad.port';
import { VERIFICADOR_MEMBRESIA } from './application/contexto/verificador-membresia.port';
import { VERIFICADOR_PLATAFORMA } from './application/contexto/verificador-plataforma.port';
import {
  VERIFICADOR_SESION,
  VerificadorSesion,
} from './application/contexto/verificador-sesion.port';
import { AUDITORIA } from './application/puertos/auditoria.port';
import { CIFRADOR_SECRETOS } from './application/puertos/cifrador-secretos.port';
import { FIRMADOR_QR } from './application/puertos/firmador-qr.port';
import { FIRMADOR_TOKENS, FirmadorTokens } from './application/puertos/firmador-tokens.port';
import { GENERADOR_IDS } from './application/puertos/generador-ids.port';
import { GENERADOR_SECRETOS } from './application/puertos/generador-secretos.port';
import { OBSERVABILIDAD } from './application/puertos/observabilidad.port';
import { Reloj, RELOJ } from './application/puertos/reloj.port';
import { PrismaAuditoria } from './infrastructure/auditoria/prisma-auditoria';
import {
  CONFIGURACION,
  Configuracion,
  leerConfiguracion,
} from './infrastructure/config/configuracion';
import { AlmacenContextoAsincrono } from './infrastructure/contexto/almacen-contexto-asincrono';
import { PrismaVerificadorMembresia } from './infrastructure/contexto/prisma-verificador-membresia';
import { PrismaVerificadorPlataforma } from './infrastructure/contexto/prisma-verificador-plataforma';
import { PrismaVerificadorSesion } from './infrastructure/contexto/prisma-verificador-sesion';
import { IdentidadDesarrolloResolvedor } from './infrastructure/identidad/identidad-desarrollo.resolvedor';
import { IdentidadTokenResolvedor } from './infrastructure/identidad/identidad-token.resolvedor';
import { GeneradorUuidV7 } from './infrastructure/ids/uuid-v7.generador';
import { SentryObservabilidad } from './infrastructure/observabilidad/sentry-observabilidad';
import { PrismaService } from './infrastructure/prisma/prisma.service';
import { FirmadorQrEd25519 } from './infrastructure/qr/firmador-qr-ed25519';
import { TransaccionComercio } from './infrastructure/prisma/transaccion-comercio';
import { TransaccionUsuario } from './infrastructure/prisma/transaccion-usuario';
import { Argon2Cifrador } from './infrastructure/secretos/argon2-cifrador';
import { GeneradorSecretosCrypto } from './infrastructure/secretos/generador-secretos-crypto';
import { RelojSistema } from './infrastructure/tiempo/reloj-sistema';
import { FirmadorHs256 } from './infrastructure/tokens/firmador-hs256';
import { ComercioActivoGuard } from './presentation/http/guards/comercio-activo.guard';
import { PlataformaGuard } from './presentation/http/guards/plataforma.guard';
import { SesionGuard } from './presentation/http/guards/sesion.guard';
import { ContextoPeticionMiddleware } from './presentation/http/middleware/contexto-peticion.middleware';

const PUERTOS = [
  CONFIGURACION,
  ALMACEN_CONTEXTO,
  VERIFICADOR_MEMBRESIA,
  VERIFICADOR_PLATAFORMA,
  VERIFICADOR_SESION,
  RESOLVEDOR_IDENTIDAD,
  OBSERVABILIDAD,
  GENERADOR_IDS,
  GENERADOR_SECRETOS,
  CIFRADOR_SECRETOS,
  FIRMADOR_TOKENS,
  FIRMADOR_QR,
  RELOJ,
  AUDITORIA,
];

/** Piezas transversales: configuración, base de datos, contexto, identidad, auditoría e ids. */
@Global()
@Module({
  providers: [
    { provide: CONFIGURACION, useFactory: () => leerConfiguracion() },
    { provide: ALMACEN_CONTEXTO, useClass: AlmacenContextoAsincrono },
    { provide: VERIFICADOR_MEMBRESIA, useClass: PrismaVerificadorMembresia },
    { provide: VERIFICADOR_PLATAFORMA, useClass: PrismaVerificadorPlataforma },
    { provide: VERIFICADOR_SESION, useClass: PrismaVerificadorSesion },
    { provide: RELOJ, useClass: RelojSistema },
    {
      provide: FIRMADOR_TOKENS,
      useFactory: (config: Configuracion, reloj: Reloj) =>
        new FirmadorHs256(config.secretoTokens, reloj),
      inject: [CONFIGURACION, RELOJ],
    },
    {
      provide: FIRMADOR_QR,
      useFactory: (config: Configuracion) => new FirmadorQrEd25519(config.secretoQr),
      inject: [CONFIGURACION],
    },
    {
      provide: RESOLVEDOR_IDENTIDAD,
      useFactory: (config: Configuracion, firmador: FirmadorTokens, sesiones: VerificadorSesion) =>
        new IdentidadTokenResolvedor(
          firmador,
          sesiones,
          config.identidadDesarrollo ? new IdentidadDesarrolloResolvedor(true) : null,
        ),
      inject: [CONFIGURACION, FIRMADOR_TOKENS, VERIFICADOR_SESION],
    },
    { provide: OBSERVABILIDAD, useClass: SentryObservabilidad },
    { provide: GENERADOR_IDS, useClass: GeneradorUuidV7 },
    { provide: GENERADOR_SECRETOS, useClass: GeneradorSecretosCrypto },
    { provide: CIFRADOR_SECRETOS, useClass: Argon2Cifrador },
    { provide: AUDITORIA, useClass: PrismaAuditoria },
    PrismaService,
    TransaccionComercio,
    TransaccionUsuario,
    ComercioActivoGuard,
    SesionGuard,
    PlataformaGuard,
  ],
  exports: [
    ...PUERTOS,
    PrismaService,
    TransaccionComercio,
    TransaccionUsuario,
    ComercioActivoGuard,
    SesionGuard,
    PlataformaGuard,
  ],
})
export class SharedModule implements NestModule {
  configure(consumidor: MiddlewareConsumer): void {
    consumidor.apply(ContextoPeticionMiddleware).forRoutes('*');
  }
}
