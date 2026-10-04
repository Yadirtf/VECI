import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../generated/prisma/client';
import {
  ClienteTransaccion,
  TransaccionComercio,
} from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { HorarioServicio } from '../../domain/entities/horario-servicio.entity';
import { HorarioSeCruza } from '../../domain/errors/horario-se-cruza.error';
import {
  HorarioConServicio,
  HorarioServicioRepository,
} from '../../domain/repositories/horario-servicio.repository';
import { codigoPostgres, VIOLACION_EXCLUSION } from './es-error-postgres';
import { aHorarioServicio, FilaHorario } from './horario-servicio.mapper';

/**
 * Horarios en tenancy.service_schedules. Las horas son un rango propio de
 * PostgreSQL (core.time_range) que Prisma no modela, por eso se usa SQL tipado.
 * Todas las consultas corren con el comercio activo fijado: RLS filtra el resto.
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

  listarDeSedeYDia(sedeId: string, dia: CodigoCatalogo): Promise<HorarioServicio[]> {
    return this.transaccion.ejecutar(async (tx) => {
      const filtro = Prisma.sql`ss.branch_id = ${sedeId}::uuid AND w.code = ${dia.valor}`;
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

  async guardar(horario: HorarioServicio): Promise<void> {
    try {
      const insertados = await this.transaccion.ejecutar((tx) => this.insertar(tx, horario));
      if (insertados === 0)
        throw new DatoInvalido(`"${horario.dia.valor}" no es un día de la semana`);
    } catch (error) {
      if (codigoPostgres(error) === VIOLACION_EXCLUSION) throw new HorarioSeCruza();
      throw error;
    }
  }

  private insertar(tx: ClienteTransaccion, horario: HorarioServicio): Promise<number> {
    return tx.$executeRaw`
      INSERT INTO tenancy.service_schedules (id, tenant_id, service_id, branch_id, weekday_id, hours)
      SELECT ${horario.id}::uuid, core.current_tenant_id(), ${horario.servicioId}::uuid,
             ${horario.sedeId}::uuid, w.id,
             core.time_range(${horario.horas.inicio}::time, ${horario.horas.fin}::time, '[)')
        FROM core.weekdays w
       WHERE w.code = ${horario.dia.valor}`;
  }

  private consultar(tx: ClienteTransaccion, filtro: Prisma.Sql): Promise<FilaHorario[]> {
    return tx.$queryRaw<FilaHorario[]>`
      SELECT ss.id::text, ss.service_id::text, ss.branch_id::text, w.code AS dia,
             to_char(lower(ss.hours), 'HH24:MI') AS inicio,
             to_char(upper(ss.hours), 'HH24:MI') AS fin, s.name AS servicio
        FROM tenancy.service_schedules ss
        JOIN tenancy.services s ON s.id = ss.service_id
        JOIN core.weekdays w ON w.id = ss.weekday_id
       WHERE ss.is_active AND ss.valid_during @> current_date AND ${filtro}
       ORDER BY ss.branch_id, w.id, lower(ss.hours)`;
  }
}
