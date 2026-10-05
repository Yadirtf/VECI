import { Module } from '@nestjs/common';
import { GENERADOR_IDS, GeneradorIds } from '../../shared/application/puertos/generador-ids.port';
import { SEDES_REPOSITORY, SedesRepository } from './application/puertos/sedes.repository';
import { GestionarSedes } from './application/use-cases/sedes.use-case';
import { PrismaSedesRepository } from './infrastructure/persistence/prisma-sedes.repository';
import { SedesController } from './presentation/http/sedes.controller';

/** EP-03 · Varias sedes con sus cajeros (HU-03-03). */
@Module({
  controllers: [SedesController],
  providers: [
    { provide: SEDES_REPOSITORY, useClass: PrismaSedesRepository },
    {
      provide: GestionarSedes,
      useFactory: (sedes: SedesRepository, ids: GeneradorIds) => new GestionarSedes(sedes, ids),
      inject: [SEDES_REPOSITORY, GENERADOR_IDS],
    },
  ],
})
export class SedesModule {}
