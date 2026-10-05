import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../generated/prisma/client';
import { TransaccionComercio } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { CajeroEnSedes, CupoDeSedes, Sede } from '../../domain/entities/sede';
import { NombreDeSedeRepetido } from '../../domain/errors/errores-sedes';
import {
  CambiosSede,
  DatosSede,
  SedesRepository,
} from '../../application/puertos/sedes.repository';

interface FilaSede {
  id: string;
  nombre: string;
  principal: boolean;
  estado: string;
  activa: boolean;
  municipio_id: number | null;
  municipio: string | null;
  direccion: string | null;
}

/** SQLSTATE dentro de un error de Prisma con el adaptador pg. */
function codigoPostgres(error: unknown): string | undefined {
  const meta = (error as { meta?: { driverAdapterError?: { cause?: { originalCode?: unknown } } } })
    ?.meta;
  const codigo = meta?.driverAdapterError?.cause?.originalCode;
  return typeof codigo === 'string' ? codigo : undefined;
}

const aSede = (f: FilaSede): Sede => ({
  sedeId: f.id,
  nombre: f.nombre,
  principal: f.principal,
  estado: f.estado,
  activa: f.activa,
  municipioId: f.municipio_id,
  municipio: f.municipio,
  direccion: f.direccion,
});

/**
 * Sedes en tenancy.branches y asignaciones en tenancy.membership_branches. El cupo
 * sale del plan vigente: función MULTI_BRANCH y límite BRANCHES (ADR-0006).
 */
@Injectable()
export class PrismaSedesRepository implements SedesRepository {
  constructor(private readonly transaccion: TransaccionComercio) {}

  listar(): Promise<Sede[]> {
    return this.consultar(Prisma.sql`TRUE`);
  }

  async buscar(sedeId: string): Promise<Sede | null> {
    const [sede] = await this.consultar(Prisma.sql`b.id = ${sedeId}::uuid`);
    return sede ?? null;
  }

  cajeros(): Promise<CajeroEnSedes[]> {
    return this.transaccion.ejecutar(
      (tx) =>
        tx.$queryRaw<CajeroEnSedes[]>`
        SELECT m.id::text AS "membresiaId",
               p.given_names || coalesce(' ' || p.family_names, '') AS nombre,
               coalesce(array_agg(mb.branch_id::text ORDER BY mb.assigned_at)
                          FILTER (WHERE mb.id IS NOT NULL), '{}') AS "sedeIds"
          FROM tenancy.memberships m
          JOIN tenancy.membership_statuses ms ON ms.id = m.membership_status_id
                                             AND (ms.allows_login OR ms.is_initial)
          JOIN tenancy.membership_roles mr ON mr.membership_id = m.id AND mr.revoked_at IS NULL
          JOIN identity.roles r ON r.id = mr.role_id AND r.code = 'CASHIER'
          JOIN identity.users u ON u.id = m.user_id
          JOIN identity.people p ON p.id = u.person_id
          LEFT JOIN tenancy.membership_branches mb ON mb.membership_id = m.id AND mb.revoked_at IS NULL
         GROUP BY m.id, p.given_names, p.family_names
         ORDER BY nombre`,
    );
  }

  cupo(): Promise<CupoDeSedes> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<
        { ocupadas: number; limite: number | null; varias: boolean }[]
      >`
        SELECT (SELECT count(*)::int FROM tenancy.branches b
                  JOIN tenancy.branch_statuses bs ON bs.id = b.branch_status_id AND bs.allows_operations
               ) AS ocupadas,
               (SELECT pl.max_value FROM billing.plan_limits pl
                  JOIN billing.limit_types lt ON lt.id = pl.limit_type_id AND lt.code = 'BRANCHES'
                 WHERE pl.plan_id = s.plan_id) AS limite,
               EXISTS (SELECT 1 FROM billing.plan_features pf
                         JOIN billing.features f ON f.id = pf.feature_id AND f.code = 'MULTI_BRANCH'
                        WHERE pf.plan_id = s.plan_id) AS varias
          FROM (SELECT 1) AS uno
          LEFT JOIN billing.subscriptions s ON s.ended_at IS NULL`;
      return { ocupadas: fila.ocupadas, limite: fila.limite, variasSedes: fila.varias };
    });
  }

  async crear(sedeId: string, d: DatosSede): Promise<void> {
    await this.conNombreUnico(
      (tx) => tx.$executeRaw`
      INSERT INTO tenancy.branches (id, tenant_id, name, branch_status_id, municipality_id, address_line)
      SELECT ${sedeId}::uuid, core.current_tenant_id(), ${d.nombre}, bs.id,
             ${d.municipioId}::integer, ${d.direccion}
        FROM tenancy.branch_statuses bs WHERE bs.code = 'ACTIVE'`,
    );
  }

  async actualizar(sedeId: string, c: CambiosSede): Promise<void> {
    const estado = c.activa === undefined ? null : c.activa ? 'ACTIVE' : 'INACTIVE';
    await this.conNombreUnico(
      (tx) => tx.$executeRaw`
      UPDATE tenancy.branches
         SET name = coalesce(${c.nombre ?? null}, name),
             municipality_id = CASE WHEN ${c.municipioId !== undefined}
                                    THEN ${c.municipioId ?? null}::integer ELSE municipality_id END,
             address_line = CASE WHEN ${c.direccion !== undefined}
                                 THEN ${c.direccion ?? null} ELSE address_line END,
             branch_status_id = coalesce((SELECT id FROM tenancy.branch_statuses WHERE code = ${estado}),
                                         branch_status_id)
       WHERE id = ${sedeId}::uuid`,
    );
  }

  esCajero(membresiaId: string): Promise<boolean> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<{ es: boolean }[]>`
        SELECT EXISTS (SELECT 1 FROM tenancy.membership_roles mr
                         JOIN identity.roles r ON r.id = mr.role_id AND r.code = 'CASHIER'
                        WHERE mr.membership_id = ${membresiaId}::uuid AND mr.revoked_at IS NULL) AS es`;
      return fila.es;
    });
  }

  asignar(membresiaId: string, sedeIds: readonly string[], porUsuarioId: string): Promise<void> {
    const lista = sedeIds.length ? Prisma.join(sedeIds.map((id) => Prisma.sql`${id}::uuid`)) : null;
    const enLista = lista ? Prisma.sql`branch_id IN (${lista})` : Prisma.sql`FALSE`;
    return this.transaccion.ejecutar(async (tx) => {
      await tx.$executeRaw`
        UPDATE tenancy.membership_branches SET revoked_at = now()
         WHERE membership_id = ${membresiaId}::uuid AND revoked_at IS NULL AND NOT (${enLista})`;
      if (!lista) return;
      await tx.$executeRaw`
        INSERT INTO tenancy.membership_branches (tenant_id, membership_id, branch_id, assigned_by_user_id)
        SELECT core.current_tenant_id(), ${membresiaId}::uuid, b.id, ${porUsuarioId}::uuid
          FROM tenancy.branches b
         WHERE b.id IN (${lista})
           AND NOT EXISTS (SELECT 1 FROM tenancy.membership_branches mb
                            WHERE mb.membership_id = ${membresiaId}::uuid AND mb.branch_id = b.id
                              AND mb.revoked_at IS NULL)`;
    });
  }

  private async conNombreUnico(
    trabajo: Parameters<TransaccionComercio['ejecutar']>[0],
  ): Promise<void> {
    try {
      await this.transaccion.ejecutar(trabajo);
    } catch (error) {
      if (codigoPostgres(error) === '23505') throw new NombreDeSedeRepetido();
      throw error;
    }
  }

  private consultar(filtro: Prisma.Sql): Promise<Sede[]> {
    return this.transaccion.ejecutar(async (tx) => {
      const filas = await tx.$queryRaw<FilaSede[]>`
        SELECT b.id::text, b.name AS nombre, b.is_main AS principal, bs.code AS estado,
               bs.allows_operations AS activa, b.municipality_id AS municipio_id,
               mu.name AS municipio, b.address_line AS direccion
          FROM tenancy.branches b
          JOIN tenancy.branch_statuses bs ON bs.id = b.branch_status_id
          LEFT JOIN core.municipalities mu ON mu.id = b.municipality_id
         WHERE ${filtro}
         ORDER BY b.is_main DESC, b.created_at`;
      return filas.map(aSede);
    });
  }
}
