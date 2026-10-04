import { Module } from '@nestjs/common';
import { ObtenerEstadisticasUseCase } from './application/use-cases/obtener-estadisticas.use-case';
import { RecibirLoteUseCase } from './application/use-cases/recibir-lote.use-case';
import { ReiniciarPruebaUseCase } from './application/use-cases/reiniciar-prueba.use-case';
import { INBOUND_EVENT_REPOSITORY } from './domain/inbound-event.repository';
import { PAYLOAD_HASHER } from './domain/payload-hasher';
import { SYNC_METRICS } from './domain/sync-metrics';
import { InMemorySyncMetrics } from './infrastructure/in-memory-sync-metrics';
import { InMemoryInboundEventRepository } from './infrastructure/persistence/in-memory-inbound-event.repository';
import { Sha256PayloadHasher } from './infrastructure/sha256-payload.hasher';
import { SimuladorDeCortes } from './presentation/http/simulador-de-cortes';
import { SincronizacionController } from './presentation/http/sincronizacion.controller';

@Module({
  controllers: [SincronizacionController],
  providers: [
    RecibirLoteUseCase,
    ObtenerEstadisticasUseCase,
    ReiniciarPruebaUseCase,
    { provide: SimuladorDeCortes, useValue: new SimuladorDeCortes() },
    { provide: INBOUND_EVENT_REPOSITORY, useClass: InMemoryInboundEventRepository },
    { provide: PAYLOAD_HASHER, useClass: Sha256PayloadHasher },
    { provide: SYNC_METRICS, useClass: InMemorySyncMetrics },
  ],
})
export class SincronizacionModule {}
