import { Injectable } from '@nestjs/common';
import { Auditoria, EntradaAuditoria } from '../../application/puertos/auditoria.port';
import { ClienteTransaccion, TransaccionComercio } from '../prisma/transaccion-comercio';
import { PrismaService } from '../prisma/prisma.service';

function json(valor: Readonly<Record<string, unknown>> | undefined): string | null {
  return valor ? JSON.stringify(valor) : null;
}

/**
 * Escribe en audit.audit_log (inmutable). Con comercio, la fila entra con ese
 * contexto fijado (RLS); sin comercio, queda como acción de plataforma.
 * La acción se busca por código en audit.actions (ADR-0006).
 */
@Injectable()
export class PrismaAuditoria implements Auditoria {
  constructor(
    private readonly prisma: PrismaService,
    private readonly transaccion: TransaccionComercio,
  ) {}

  async registrar(entrada: EntradaAuditoria): Promise<void> {
    if (entrada.comercioId) {
      const contexto = { comercioId: entrada.comercioId, usuarioId: entrada.actorUsuarioId ?? '' };
      await this.transaccion.ejecutarComo(contexto, (tx) => this.insertar(tx, entrada));
      return;
    }
    await this.insertar(this.prisma, entrada);
  }

  private async insertar(
    tx: ClienteTransaccion | PrismaService,
    e: EntradaAuditoria,
  ): Promise<void> {
    const insertadas = await tx.$executeRaw`
      INSERT INTO audit.audit_log (tenant_id, action_id, actor_user_id, actor_membership_id,
                                   entity_table, entity_id, device_id, before_data, after_data)
      SELECT ${e.comercioId}::uuid, a.id, ${e.actorUsuarioId}::uuid,
             (SELECT m.id FROM tenancy.memberships m
               WHERE m.tenant_id = ${e.comercioId}::uuid AND m.user_id = ${e.actorUsuarioId}::uuid),
             ${e.tabla}, ${e.entidadId}::uuid, ${e.dispositivoId ?? null}::uuid,
             ${json(e.antes)}::jsonb, ${json(e.despues)}::jsonb
        FROM audit.actions a
       WHERE a.code = ${e.accion}`;
    if (insertadas === 0) throw new Error(`Acción de auditoría desconocida: ${e.accion}`);
  }
}
