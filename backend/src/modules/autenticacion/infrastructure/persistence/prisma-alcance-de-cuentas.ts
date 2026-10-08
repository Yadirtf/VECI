import { Injectable } from '@nestjs/common';
import { TransaccionUsuario } from '../../../../shared/infrastructure/prisma/transaccion-usuario';
import { AlcanceDeCuentas } from '../../application/puertos/alcance-de-cuentas.port';
import { AlcanceDeCuenta } from '../../domain/rules/alcance-de-cuenta.rule';

/**
 * Cuenta las membresías no terminales de la persona (política staff_self, con su
 * propio usuario como contexto de solo lectura) y sus roles de plataforma vigentes.
 */
@Injectable()
export class PrismaAlcanceDeCuentas implements AlcanceDeCuentas {
  constructor(private readonly usuario: TransaccionUsuario) {}

  async de(usuarioId: string, comercioId: string | null): Promise<AlcanceDeCuenta> {
    const [fila] = await this.usuario.ejecutarComo(
      { usuarioId, personaId: '' },
      (tx) =>
        tx.$queryRaw<{ otros: number; veci: boolean }[]>`
        SELECT (SELECT count(DISTINCT m.tenant_id)::int
                  FROM tenancy.memberships m
                  JOIN tenancy.membership_statuses ms ON ms.id = m.membership_status_id
                 WHERE m.user_id = core.current_user_id() AND NOT ms.is_terminal
                   AND m.tenant_id IS DISTINCT FROM ${comercioId}::uuid) AS otros,
               EXISTS (SELECT 1 FROM identity.user_platform_roles upr
                        WHERE upr.user_id = ${usuarioId}::uuid AND upr.revoked_at IS NULL) AS veci`,
    );
    return { otrosNegociosComoPersonal: fila.otros, esEquipoVeci: fila.veci };
  }
}
