import { Injectable } from '@nestjs/common';
import { VerificadorMembresia } from '../../application/contexto/verificador-membresia.port';
import { TransaccionComercio } from '../prisma/transaccion-comercio';

/**
 * Consulta tenancy.memberships con el comercio pedido ya fijado: RLS impide
 * leer membresías de otros comercios. Los estados se juzgan por sus columnas
 * de regla (allows_login), nunca por ids ni códigos fijos (ADR-0006).
 */
@Injectable()
export class PrismaVerificadorMembresia implements VerificadorMembresia {
  constructor(private readonly transaccion: TransaccionComercio) {}

  esMiembroActivo(usuarioId: string, comercioId: string): Promise<boolean> {
    return this.transaccion.ejecutarComo({ comercioId, usuarioId }, async (tx) => {
      const membresia = await tx.memberships.findFirst({
        select: { id: true },
        where: {
          tenant_id: comercioId,
          user_id: usuarioId,
          membership_statuses: { allows_login: true },
          users_memberships_user_idTousers: { user_statuses: { allows_login: true } },
        },
      });
      return membresia !== null;
    });
  }
}
