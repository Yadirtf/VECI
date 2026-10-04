import { Injectable } from '@nestjs/common';
import { VerificadorPlataforma } from '../../application/contexto/verificador-plataforma.port';
import { PrismaService } from '../prisma/prisma.service';

/** Permisos por los roles internos vigentes (identity.user_platform_roles, sin RLS). */
@Injectable()
export class PrismaVerificadorPlataforma implements VerificadorPlataforma {
  constructor(private readonly prisma: PrismaService) {}

  async permisosDePlataforma(usuarioId: string): Promise<ReadonlySet<string>> {
    const filas = await this.prisma.$queryRaw<{ code: string }[]>`
      SELECT DISTINCT p.code
        FROM identity.user_platform_roles upr
        JOIN identity.roles r ON r.id = upr.role_id AND r.is_active
        JOIN identity.role_permissions rp ON rp.role_id = r.id
        JOIN identity.permissions p ON p.id = rp.permission_id
        JOIN identity.users u ON u.id = upr.user_id
        JOIN identity.user_statuses us ON us.id = u.user_status_id AND us.allows_login
       WHERE upr.user_id = ${usuarioId}::uuid AND upr.revoked_at IS NULL`;
    return new Set(filas.map((fila) => fila.code));
  }
}
