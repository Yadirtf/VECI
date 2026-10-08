import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../generated/prisma/client';
import {
  ClienteTransaccion,
  TransaccionComercio,
} from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { HorarioServicio } from '../../domain/entities/horario-servicio.entity';
import {
  HorarioNoEncontrado,
  ServicioRepetido,
} from '../../domain/errors/horario-no-encontrado.error';
import { HorarioSeCruza } from '../../domain/errors/horario-se-cruza.error';
import {
  HorarioConServicio,
  HorarioServicioRepository,
  Servicio,
} from '../../domain/repositories/horario-servicio.repository';
import { codigoPostgres, VIOLACION_EXCLUSION } from './es-error-postgres';
import { aHorarioServicio, FilaHorario } from './horario-servicio.mapper';

const VIOLACION_UNICA = '23505';

/**
 * Horarios en tenancy.service_schedules. Las horas son un rango propio de
 * PostgreSQL (core.time_range) que Prisma no modela, por eso se usa SQL tipado.
 * Todas las consultas corren con el comercio activo fijado: RLS filtra el resto.
 * "Hoy" es la fecha local del negocio (tenancy.current_local_date); un horario que
 * empieza mañana por la fecha UTC del servidor también cuenta (tenancy.still_valid).
 */
@Injectable()
export class PrismaHorarioServicioRepository implements HorarioServicioRepository {
  constructor(private readonly transaccion: TransaccionComercio) {}

  listarVigentes(): Promise<HorarioConServicio[]> {
    return this.transaccion.ejecutar(async (tx) => {
      const filas = await this.consultar(tx, Prisma.sql`TRUE`);
      return filas.map((fila) => ({
        horario: aHorarioServicio(fila),
        servicioNombre: fila.servicio,
      }));
    });
  }

  version(): Promise<string> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<{ version: string }[]>`
        SELECT greatest((SELECT max(sync_version) FROM tenancy.service_schedules),
                        (SELECT max(sync_version) FROM tenancy.services), 0)::text AS version`;
      return fila.version;
    });
  }

  buscar(id: string): Promise<HorarioServicio | null> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await this.consultar(tx, Prisma.sql`ss.id = ${id}::uuid`);
      return fila ? aHorarioServicio(fila) : null;
    });
  }

  listarDeSedeYDia(sedeId: string, dia: CodigoCatalogo): Promise<HorarioServicio[]> {
    return this.transaccion.ejecutar(async (tx) => {
      const filtro = Prisma.sql`ss.is_active AND ss.branch_id = ${sedeId}::uuid AND w.code = ${dia.valor}`;
      const filas = await this.consultar(tx, filtro);
      return filas.map(aHorarioServicio);
    });
  }

  existeServicio(servicioId: string): Promise<boolean> {
    return this.transaccion.ejecutar(
      async (tx) => (await tx.services.count({ where: { id: servicioId, is_active: true } })) > 0,
    );
  }

  existeSede(sedeId: string): Promise<boolean> {
    return this.transaccion.ejecutar(
      async (tx) => (await tx.branches.count({ where: { id: sedeId } })) > 0,
    );
  }

  guardar(...horarios: HorarioServicio[]): Promise<void> {
    return this.conCruces((tx) => this.insertarTodos(tx, horarios));
  }

  programar(cerrar: readonly string[], nuevos: readonly HorarioServicio[]): Promise<void> {
    return this.conCruces(async (tx) => {
      for (const anteriorId of cerrar) {
        const cerrados = await tx.$executeRaw`
          UPDATE tenancy.service_schedules
             SET valid_during = daterange(
                   LEAST(lower(valid_during), tenancy.current_local_date()),
                   tenancy.current_local_date(), '[)')
           WHERE id = ${anteriorId}::uuid AND tenancy.still_valid(valid_during)`;
        if (cerrados === 0) throw new HorarioNoEncontrado();
      }
      await this.insertarTodos(tx, nuevos);
    });
  }

  cambiarEstado(id: string, activo: boolean): Promise<void> {
    return this.conCruces(async (tx) => {
      const cambiados = await tx.$executeRaw`
        UPDATE tenancy.service_schedules SET is_active = ${activo}
         WHERE id = ${id}::uuid AND tenancy.still_valid(valid_during)`;
      if (cambiados === 0) throw new HorarioNoEncontrado();
    });
  }

  servicios(): Promise<Servicio[]> {
    return this.transaccion.ejecutar(
      (tx) =>
        tx.$queryRaw<Servicio[]>`
        SELECT id::text, name AS nombre FROM tenancy.services
         WHERE is_active ORDER BY sort_order, name`,
    );
  }

  async crearServicio(servicio: Servicio): Promise<void> {
    try {
      await this.transaccion.ejecutar(
        (tx) => tx.$executeRaw`
        INSERT INTO tenancy.services (id, tenant_id, name, sort_order)
        SELECT ${servicio.id}::uuid, core.current_tenant_id(), ${servicio.nombre},
               coalesce(max(sort_order), 0) + 1
          FROM tenancy.services`,
      );
    } catch (error) {
      if (codigoPostgres(error) === VIOLACION_UNICA) throw new ServicioRepetido();
      throw error;
    }
  }

  private async conCruces(trabajo: (tx: ClienteTransaccion) => Promise<unknown>): Promise<void> {
    try {
      await this.transaccion.ejecutar(trabajo);
    } catch (error) {
      if (codigoPostgres(error) === VIOLACION_EXCLUSION) throw new HorarioSeCruza();
      throw error;
    }
  }

  private async insertarTodos(
    tx: ClienteTransaccion,
    horarios: readonly HorarioServicio[],
  ): Promise<void> {
    for (const horario of horarios) {
      const insertados = await tx.$executeRaw`
        INSERT INTO tenancy.service_schedules
               (id, tenant_id, service_id, branch_id, weekday_id, hours, valid_during, is_active)
        SELECT ${horario.id}::uuid, core.current_tenant_id(), ${horario.servicioId}::uuid,
               ${horario.sedeId}::uuid, w.id,
               core.time_range(${horario.horas.inicio}::time, ${horario.horas.fin}::time, '[)'),
               daterange(tenancy.current_local_date(), NULL, '[)'), ${horario.activo}
          FROM core.weekdays w
         WHERE w.code = ${horario.dia.valor}`;
      if (insertados === 0) {
        throw new DatoInvalido(`"${horario.dia.valor}" no es un día de la semana`);
      }
    }
  }

  private consultar(tx: ClienteTransaccion, filtro: Prisma.Sql): Promise<FilaHorario[]> {
    return tx.$queryRaw<FilaHorario[]>`
      SELECT ss.id::text, ss.service_id::text, ss.branch_id::text, w.code AS dia,
             to_char(lower(ss.hours), 'HH24:MI') AS inicio,
             to_char(upper(ss.hours), 'HH24:MI') AS fin, s.name AS servicio,
             ss.is_active AS activo
        FROM tenancy.service_schedules ss
        JOIN tenancy.services s ON s.id = ss.service_id
        JOIN core.weekdays w ON w.id = ss.weekday_id
       WHERE tenancy.still_valid(ss.valid_during) AND ${filtro}
       ORDER BY ss.branch_id, w.id, lower(ss.hours)`;
  }
}
