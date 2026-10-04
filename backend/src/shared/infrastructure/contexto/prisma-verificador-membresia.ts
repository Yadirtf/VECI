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

  /** Permisos de los roles vigentes de la membresía activa (HU-02-03). */
  permisosEn(usuarioId: string, comercioId: string): Promise<ReadonlySet<string>> {
    return this.transaccion.ejecutarComo({ comercioId, usuarioId }, async (tx) => {
      const filas = await tx.$queryRaw<{ code: string }[]>`
        SELECT DISTINCT p.code
          FROM tenancy.memberships m
          JOIN tenancy.membership_statuses ms ON ms.id = m.membership_status_id AND ms.allows_login
          JOIN tenancy.membership_roles mr ON mr.membership_id = m.id AND mr.revoked_at IS NULL
          JOIN identity.roles r ON r.id = mr.role_id AND r.is_active
          JOIN identity.role_permissions rp ON rp.role_id = r.id
          JOIN identity.permissions p ON p.id = rp.permission_id
         WHERE m.user_id = ${usuarioId}::uuid`;
      return new Set(filas.map((fila) => fila.code));
    });
  }
}
