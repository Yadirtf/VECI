import { Injectable } from '@nestjs/common';
import { TransaccionComercio } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { TransaccionUsuario } from '../../../../shared/infrastructure/prisma/transaccion-usuario';
import { RolEnComercio } from '../../domain/entities/espacio';
import { EspaciosRepository } from '../../application/puertos/espacios.repository';

interface FilaEspacio {
  comercio_id: string;
  nombre: string;
  tipo_negocio: string;
  rol: string;
  es_invitacion: boolean;
}

/**
 * Lee los espacios con el contexto del propio usuario (políticas staff_self y
 * customer_self); escribe en cada comercio con su contexto fijado (RLS).
 */
@Injectable()
export class PrismaEspaciosRepository implements EspaciosRepository {
  constructor(
    private readonly usuario: TransaccionUsuario,
    private readonly comercio: TransaccionComercio,
  ) {}

  async listar(usuarioId: string, personaId: string): Promise<RolEnComercio[]> {
    const filas = await this.usuario.ejecutarComo(
      { usuarioId, personaId },
      (tx) =>
        tx.$queryRaw<FilaEspacio[]>`
        SELECT t.id::text AS comercio_id, t.display_name AS nombre, bt.code AS tipo_negocio,
               r.code AS rol, ms.is_initial AS es_invitacion
          FROM tenancy.memberships m
          JOIN tenancy.membership_statuses ms ON ms.id = m.membership_status_id
                                             AND (ms.allows_login OR ms.is_initial)
          JOIN tenancy.membership_roles mr ON mr.membership_id = m.id AND mr.revoked_at IS NULL
          JOIN identity.roles r ON r.id = mr.role_id AND r.is_active
          JOIN tenancy.tenants t ON t.id = m.tenant_id
          JOIN tenancy.business_types bt ON bt.id = t.business_type_id
         WHERE m.user_id = core.current_user_id()
        UNION ALL
        SELECT t.id::text, t.display_name, bt.code, 'CUSTOMER', false
          FROM customers.affiliations a
          JOIN customers.affiliation_statuses st ON st.id = a.affiliation_status_id
                                                AND st.allows_operations
          JOIN tenancy.tenants t ON t.id = a.tenant_id
          JOIN tenancy.business_types bt ON bt.id = t.business_type_id
         WHERE a.person_id = core.current_person_id()`,
    );
    return filas.map((fila) => ({
      comercioId: fila.comercio_id,
      nombre: fila.nombre,
      tipoNegocio: fila.tipo_negocio,
      rol: fila.rol,
      esInvitacion: fila.es_invitacion,
    }));
  }

  async aceptarInvitacion(usuarioId: string, comercioId: string): Promise<void> {
    await this.comercio.ejecutarComo(
      { comercioId, usuarioId },
      (tx) => tx.$executeRaw`
      UPDATE tenancy.memberships
         SET membership_status_id = (SELECT id FROM tenancy.membership_statuses WHERE code = 'ACTIVE'),
             joined_at = now()
       WHERE user_id = ${usuarioId}::uuid
         AND membership_status_id IN (SELECT id FROM tenancy.membership_statuses WHERE is_initial)`,
    );
  }

  async registrarDispositivoEnComercio(
    comercioId: string,
    dispositivoId: string,
    usuarioId: string,
  ): Promise<void> {
    await this.comercio.ejecutarComo(
      { comercioId, usuarioId },
      (tx) => tx.$executeRaw`
      INSERT INTO tenancy.tenant_devices (tenant_id, device_id, name, registered_by_user_id)
      SELECT core.current_tenant_id(), d.id, d.model, ${usuarioId}::uuid
        FROM identity.devices d
        JOIN identity.device_platforms p ON p.id = d.device_platform_id AND p.code <> 'WEB'
       WHERE d.id = ${dispositivoId}::uuid
         AND NOT EXISTS (SELECT 1 FROM tenancy.tenant_devices td
                          WHERE td.device_id = d.id AND td.revoked_at IS NULL)`,
    );
  }
}
