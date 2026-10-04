import { Module } from '@nestjs/common';
import { GENERADOR_IDS, GeneradorIds } from '../../shared/application/puertos/generador-ids.port';
import { CrearHorario } from './application/use-cases/crear-horario.use-case';
import { ListarHorarios } from './application/use-cases/listar-horarios.use-case';
import {
  HORARIO_SERVICIO_REPOSITORY,
  HorarioServicioRepository,
} from './domain/repositories/horario-servicio.repository';
import { PrismaHorarioServicioRepository } from './infrastructure/persistence/prisma-horario-servicio.repository';
import { HorariosController } from './presentation/http/horarios.controller';

/**
 * Módulo de ejemplo de la arquitectura limpia (HU-01-10): copie esta estructura
 * para crear un módulo nuevo. Este archivo solo conecta las piezas.
 */
@Module({
  controllers: [HorariosController],
  providers: [
    { provide: HORARIO_SERVICIO_REPOSITORY, useClass: PrismaHorarioServicioRepository },
    {
      provide: ListarHorarios,
      useFactory: (repositorio: HorarioServicioRepository) => new ListarHorarios(repositorio),
      inject: [HORARIO_SERVICIO_REPOSITORY],
    },
    {
      provide: CrearHorario,
      useFactory: (repositorio: HorarioServicioRepository, ids: GeneradorIds) =>
        new CrearHorario(repositorio, ids),
      inject: [HORARIO_SERVICIO_REPOSITORY, GENERADOR_IDS],
    },
  ],
})
export class HorariosModule {}
