import { Inject, Injectable } from '@nestjs/common';
import {
  GENERADOR_IDS,
  GeneradorIds,
} from '../../../../shared/application/puertos/generador-ids.port';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import {
  ClienteTransaccion,
  TransaccionComercio,
} from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { VencimientoRepository } from '../../application/puertos/vencimiento.repository';
import { anotarAsiento, anotarEvento, cambiarEstadoTiquetera } from './libro';

interface PorVencer {
  tiquetera_id: string;
  cliente_id: string;
  saldo: number;
  vence_en: Date;
}

/**
 * Vencimiento (HU-05-04). La lista de comercios sale de una función que solo devuelve
 * ids; cada comercio se vence con su contexto fijado (RLS), como lo haría su caja.
 */
@Injectable()
export class PrismaVencimientoRepository implements VencimientoRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly transaccion: TransaccionComercio,
    @Inject(GENERADOR_IDS) private readonly ids: GeneradorIds,
  ) {}

  async comerciosConVencidas(ahora: Date): Promise<string[]> {
    const filas = await this.prisma.$queryRaw<{ id: string }[]>`
      SELECT t::text AS id FROM prepaid.tenants_with_due_packages(${ahora}) t`;
    return filas.map((f) => f.id);
  }

  vencer(comercioId: string, ahora: Date): Promise<number> {
    return this.transaccion.ejecutarComo({ comercioId, usuarioId: '' }, async (tx) => {
      // SKIP LOCKED: si una caja está tocando esa tiquetera, se vence en la siguiente vuelta.
      const vencen = await tx.$queryRaw<PorVencer[]>`
        SELECT p.id::text AS tiquetera_id, p.affiliation_id::text AS cliente_id,
               p.units_balance AS saldo, p.expires_at AS vence_en
          FROM prepaid.packages p
          JOIN prepaid.package_statuses s ON s.id = p.package_status_id
         WHERE s.code = 'ACTIVE' AND p.expires_at <= ${ahora}
           FOR UPDATE OF p SKIP LOCKED`;
      for (const t of vencen) await this.vencerUna(tx, t);
      return vencen.length;
    });
  }

  /** Primero el estado (así el asiento no la vuelve agotada) y luego las unidades perdidas. */
  private async vencerUna(tx: ClienteTransaccion, t: PorVencer): Promise<void> {
    await cambiarEstadoTiquetera(tx, t.tiquetera_id, 'EXPIRED');
    const eventoId = this.ids.siguiente();
    await anotarEvento(tx, {
      id: eventoId,
      tipo: 'EXPIRATION',
      origen: 'SYSTEM_JOB',
      clienteId: t.cliente_id,
      ocurridoEn: t.vence_en,
    });
    if (t.saldo > 0) await anotarAsiento(tx, eventoId, t.tiquetera_id, -t.saldo);
  }
}
