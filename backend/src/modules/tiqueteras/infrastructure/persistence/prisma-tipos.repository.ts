import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../generated/prisma/client';
import {
  codigoPostgres,
  VIOLACION_UNICA,
} from '../../../../shared/infrastructure/prisma/errores-postgres';
import {
  ClienteTransaccion,
  TransaccionComercio,
} from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import {
  DatosDeTipo,
  EstadoTipo,
  TipoDeTiquetera,
  UnidadDeConsumo,
} from '../../domain/entities/tipo-de-tiquetera';
import { NombreDeTipoRepetido } from '../../domain/errors/errores-tiqueteras';
import { TiposRepository } from '../../application/puertos/tipos.repository';

interface FilaTipo {
  tipo_id: string;
  nombre: string;
  unidad_codigo: string;
  singular: string;
  plural: string;
  unidades: number;
  precio: number;
  vigencia_dias: number;
  estado: EstadoTipo;
  vendidas: number;
  vigentes: number;
}

const aTipo = (f: FilaTipo): TipoDeTiquetera => ({
  tipoId: f.tipo_id,
  nombre: f.nombre,
  unidad: { codigo: f.unidad_codigo, singular: f.singular, plural: f.plural },
  unidades: f.unidades,
  precio: f.precio,
  vigenciaDias: f.vigencia_dias,
  estado: f.estado,
  vendidas: f.vendidas,
  vigentes: f.vigentes,
});

/** La unidad por su código: la propia del comercio gana sobre la de VECI. */
const UNIDAD = (codigo: string) => Prisma.sql`(
  SELECT u.id FROM prepaid.consumption_units u
   WHERE u.code = ${codigo} AND u.is_active
   ORDER BY u.tenant_id NULLS LAST LIMIT 1)`;

const ESTADO = (codigo: EstadoTipo) =>
  Prisma.sql`(SELECT id FROM prepaid.package_type_statuses WHERE code = ${codigo})`;

function consultaTipos(filtro: Prisma.Sql): Prisma.Sql {
  return Prisma.sql`
    SELECT pt.id::text AS tipo_id, pt.name AS nombre, u.code AS unidad_codigo,
           u.singular_name AS singular, u.plural_name AS plural, pt.units_quantity AS unidades,
           pt.price_amount::int AS precio, pt.validity_days AS vigencia_dias, st.code AS estado,
           (SELECT count(*)::int FROM prepaid.packages p WHERE p.package_type_id = pt.id) AS vendidas,
           (SELECT count(*)::int FROM prepaid.packages p
              JOIN prepaid.package_statuses ps ON ps.id = p.package_status_id
             WHERE p.package_type_id = pt.id AND ps.allows_consumption
               AND p.expires_at > now() AND p.units_balance > 0) AS vigentes
      FROM prepaid.package_types pt
      JOIN prepaid.consumption_units u ON u.id = pt.consumption_unit_id
      JOIN prepaid.package_type_statuses st ON st.id = pt.package_type_status_id
     WHERE ${filtro}
     ORDER BY st.sort_order, st.id, pt.price_amount, pt.name`;
}

/** La pizarra del comercio activo (HU-05-01). Todo con el comercio fijado (RLS). */
@Injectable()
export class PrismaTiposRepository implements TiposRepository {
  constructor(private readonly transaccion: TransaccionComercio) {}

  listar(): Promise<TipoDeTiquetera[]> {
    return this.consultar(Prisma.sql`st.code <> 'ARCHIVED'`);
  }

  async buscar(tipoId: string): Promise<TipoDeTiquetera | null> {
    const [tipo] = await this.consultar(Prisma.sql`pt.id = ${tipoId}::uuid`);
    return tipo ?? null;
  }

  /** Una por código (la propia del comercio gana), en el orden en que se crearon. */
  unidades(): Promise<UnidadDeConsumo[]> {
    return this.transaccion.ejecutar(
      (tx) => tx.$queryRaw<UnidadDeConsumo[]>`
        SELECT codigo, singular, plural
          FROM (SELECT DISTINCT ON (code) code AS codigo, singular_name AS singular,
                       plural_name AS plural, id
                  FROM prepaid.consumption_units
                 WHERE is_active
                 ORDER BY code, tenant_id NULLS LAST) u
         ORDER BY id`,
    );
  }

  crear(tipoId: string, d: DatosDeTipo, actorUsuarioId: string): Promise<void> {
    return this.escribir(
      (tx) => tx.$executeRaw`
        INSERT INTO prepaid.package_types (id, tenant_id, name, consumption_unit_id, units_quantity,
                                           price_amount, validity_days, package_type_status_id,
                                           created_by_user_id)
        VALUES (${tipoId}::uuid, core.current_tenant_id(), ${d.nombre}, ${UNIDAD(d.unidad)},
                ${d.unidades}, ${d.precio}, ${d.vigenciaDias}, ${ESTADO('ACTIVE')},
                ${actorUsuarioId}::uuid)`,
    );
  }

  actualizar(tipoId: string, d: DatosDeTipo): Promise<void> {
    return this.escribir(
      (tx) => tx.$executeRaw`
        UPDATE prepaid.package_types
           SET name = ${d.nombre}, consumption_unit_id = ${UNIDAD(d.unidad)},
               units_quantity = ${d.unidades}, price_amount = ${d.precio},
               validity_days = ${d.vigenciaDias}
         WHERE id = ${tipoId}::uuid`,
    );
  }

  cambiarEstado(tipoId: string, estado: EstadoTipo): Promise<void> {
    return this.escribir(
      (tx) => tx.$executeRaw`
        UPDATE prepaid.package_types
           SET package_type_status_id = ${ESTADO(estado)}, status_changed_at = now()
         WHERE id = ${tipoId}::uuid`,
    );
  }

  versionCatalogo(): Promise<string> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<{ version: string }[]>`
        SELECT coalesce(max(sync_version), 0)::text || '.' || count(*)::text AS version
          FROM prepaid.package_types`;
      return fila.version;
    });
  }

  private consultar(filtro: Prisma.Sql): Promise<TipoDeTiquetera[]> {
    return this.transaccion.ejecutar(async (tx) =>
      (await tx.$queryRaw<FilaTipo[]>(consultaTipos(filtro))).map(aTipo),
    );
  }

  private async escribir(trabajo: (tx: ClienteTransaccion) => Promise<number>): Promise<void> {
    try {
      await this.transaccion.ejecutar(trabajo);
    } catch (error) {
      if (codigoPostgres(error) === VIOLACION_UNICA) throw new NombreDeTipoRepetido();
      throw error;
    }
  }
}
