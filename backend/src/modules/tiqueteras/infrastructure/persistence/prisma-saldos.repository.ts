import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../generated/prisma/client';
import { anotarEnBitacora } from '../../../../shared/infrastructure/auditoria/prisma-auditoria';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import {
  ClienteTransaccion,
  TransaccionComercio,
} from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { TransaccionUsuario } from '../../../../shared/infrastructure/prisma/transaccion-usuario';
import { Movimiento } from '../../domain/entities/movimiento';
import { Tiquetera } from '../../domain/entities/tiquetera';
import { TiqueteraNoEncontrada } from '../../domain/errors/errores-tiqueteras';
import {
  Ajuste,
  SaldosRepository,
  TiqueterasEnComercio,
} from '../../application/puertos/saldos.repository';
import {
  aMovimiento,
  aTiquetera,
  consultaMovimientos,
  consultaTiqueteras,
  FilaMovimiento,
  FilaTiquetera,
} from './consultas-tiqueteras';
import { anotarAsiento, anotarEvento } from './libro';

type FilaDeLaPersona = FilaTiquetera & { comercio_id: string; comercio: string; zona: string };

/** En la app se ven las vigentes y lo que terminó hace poco; lo viejo queda en el libro. */
const DE_LA_PERSONA = Prisma.sql`
  p.affiliation_id IN (SELECT id FROM customers.affiliations
                        WHERE person_id = core.current_person_id())
  AND (ps.code = 'ACTIVE' OR p.status_changed_at > now() - interval '60 days')`;

/** Saldos del comercio activo o de la persona en su app (HU-05-03, HU-05-05). */
@Injectable()
export class PrismaSaldosRepository implements SaldosRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly transaccion: TransaccionComercio,
    private readonly usuario: TransaccionUsuario,
  ) {}

  zonaHoraria(): Promise<string> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<{ zona: string }[]>`
        SELECT time_zone AS zona FROM tenancy.tenants WHERE id = core.current_tenant_id()`;
      return fila.zona;
    });
  }

  delCliente(clienteId: string): Promise<Tiquetera[] | null> {
    return this.transaccion.ejecutar(async (tx) => {
      const [cliente] = await tx.$queryRaw<{ id: string }[]>`
        SELECT id::text FROM customers.affiliations WHERE id = ${clienteId}::uuid`;
      if (!cliente) return null;
      return this.tiqueteras(tx, Prisma.sql`p.affiliation_id = ${clienteId}::uuid`);
    });
  }

  movimientos(clienteId: string, limite: number): Promise<Movimiento[]> {
    return this.transaccion.ejecutar(async (tx) =>
      (await tx.$queryRaw<FilaMovimiento[]>(consultaMovimientos(clienteId, limite))).map(
        aMovimiento,
      ),
    );
  }

  tiquetera(tiqueteraId: string): Promise<Tiquetera | null> {
    return this.transaccion.ejecutar(async (tx) => {
      const [t] = await this.tiqueteras(tx, Prisma.sql`p.id = ${tiqueteraId}::uuid`);
      return t ?? null;
    });
  }

  ajustar(a: Ajuste, revisar: (actual: Tiquetera) => void): Promise<void> {
    return this.transaccion.ejecutar(async (tx) => {
      const filtro = Prisma.sql`p.id = ${a.tiqueteraId}::uuid`;
      const [fila] = await tx.$queryRaw<FilaTiquetera[]>(consultaTiqueteras(filtro, true));
      if (!fila) throw new TiqueteraNoEncontrada();
      const actual = aTiquetera(fila);
      revisar(actual);
      await anotarEvento(tx, {
        id: a.ajusteId,
        tipo: 'ADJUSTMENT',
        origen: 'ONLINE',
        clienteId: actual.clienteId,
        ocurridoEn: new Date(),
        actorUsuarioId: a.actorUsuarioId,
        dispositivoId: a.dispositivoId,
        motivo: a.motivo.codigo,
        nota: a.motivo.nota,
      });
      await anotarAsiento(tx, a.ajusteId, a.tiqueteraId, a.unidades);
      await this.auditarAjuste(tx, a, actual);
    });
  }

  async deLaPersona(usuarioId: string): Promise<TiqueterasEnComercio[]> {
    const [persona] = await this.prisma.$queryRaw<{ persona_id: string }[]>`
      SELECT person_id::text AS persona_id FROM identity.users WHERE id = ${usuarioId}::uuid`;
    if (!persona) return [];
    const filas = await this.usuario.ejecutarComo(
      { usuarioId, personaId: persona.persona_id },
      (tx) => tx.$queryRaw<FilaDeLaPersona[]>`
        SELECT x.*, t.id::text AS comercio_id, t.display_name AS comercio, t.time_zone AS zona
          FROM (${consultaTiqueteras(DE_LA_PERSONA)}) x
          JOIN customers.affiliations a ON a.id = x.cliente_id::uuid
          JOIN tenancy.tenants t ON t.id = a.tenant_id`,
    );
    return agruparPorComercio(filas);
  }

  private async tiqueteras(tx: ClienteTransaccion, filtro: Prisma.Sql): Promise<Tiquetera[]> {
    return (await tx.$queryRaw<FilaTiquetera[]>(consultaTiqueteras(filtro))).map(aTiquetera);
  }

  private auditarAjuste(tx: ClienteTransaccion, a: Ajuste, antes: Tiquetera): Promise<void> {
    return anotarEnBitacora(tx, {
      accion: 'BALANCE_ADJUSTED',
      tabla: 'prepaid.packages',
      entidadId: a.tiqueteraId,
      actorUsuarioId: a.actorUsuarioId,
      comercioId: null,
      dispositivoId: a.dispositivoId,
      antes: { saldo: antes.saldo, estado: antes.estado },
      despues: {
        saldo: antes.saldo + a.unidades,
        unidades: a.unidades,
        motivo: a.motivo.codigo,
        nota: a.motivo.nota,
      },
    });
  }
}

function agruparPorComercio(filas: FilaDeLaPersona[]): TiqueterasEnComercio[] {
  const comercios = new Map<string, TiqueterasEnComercio>();
  for (const f of filas) {
    const grupo = comercios.get(f.comercio_id) ?? {
      comercioId: f.comercio_id,
      comercio: f.comercio,
      zonaHoraria: f.zona,
      tiqueteras: [],
    };
    grupo.tiqueteras.push(aTiquetera(f));
    comercios.set(f.comercio_id, grupo);
  }
  return [...comercios.values()];
}
