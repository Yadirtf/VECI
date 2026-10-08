import { Module } from '@nestjs/common';
import { GENERADOR_IDS, GeneradorIds } from '../../shared/application/puertos/generador-ids.port';
import { CambiarHorario } from './application/use-cases/cambiar-horario.use-case';
import { CrearHorario } from './application/use-cases/crear-horario.use-case';
import { ProgramarServicio } from './application/use-cases/programar-servicio.use-case';
import { ListarHorarios } from './application/use-cases/listar-horarios.use-case';
import { GestionarServicios } from './application/use-cases/servicios.use-case';
import {
  HORARIO_SERVICIO_REPOSITORY,
  HorarioServicioRepository,
} from './domain/repositories/horario-servicio.repository';
import { PrismaHorarioServicioRepository } from './infrastructure/persistence/prisma-horario-servicio.repository';
import { HorariosController } from './presentation/http/horarios.controller';
import { ServiciosController } from './presentation/http/servicios.controller';

/**
 * Horarios de servicio (HU-03-02). Es también el módulo de ejemplo de la
 * arquitectura limpia (HU-01-10): copie esta estructura para crear uno nuevo.
 * Este archivo solo conecta las piezas.
 */
@Module({
  controllers: [HorariosController, ServiciosController],
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
    {
      provide: CambiarHorario,
      useFactory: (repositorio: HorarioServicioRepository, ids: GeneradorIds) =>
        new CambiarHorario(repositorio, ids),
      inject: [HORARIO_SERVICIO_REPOSITORY, GENERADOR_IDS],
    },
    {
      provide: ProgramarServicio,
      useFactory: (repositorio: HorarioServicioRepository, ids: GeneradorIds) =>
        new ProgramarServicio(repositorio, ids),
      inject: [HORARIO_SERVICIO_REPOSITORY, GENERADOR_IDS],
    },
    {
      provide: GestionarServicios,
      useFactory: (repositorio: HorarioServicioRepository, ids: GeneradorIds) =>
        new GestionarServicios(repositorio, ids),
      inject: [HORARIO_SERVICIO_REPOSITORY, GENERADOR_IDS],
    },
  ],
})
export class HorariosModule {}
