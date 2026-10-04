import { Injectable } from '@nestjs/common';
import {
  EstadoSesion,
  VerificadorSesion,
} from '../../application/contexto/verificador-sesion.port';
import { PrismaService } from '../prisma/prisma.service';

/**
 * Lee identity.sessions (sin RLS: no es dato de un comercio). Una sesión de un
 * usuario suspendido por VECI también cuenta como cerrada.
 */
@Injectable()
export class PrismaVerificadorSesion implements VerificadorSesion {
  constructor(private readonly prisma: PrismaService) {}

  async estado(sesionId: string, usuarioId: string): Promise<EstadoSesion> {
    const sesion = await this.prisma.sessions.findFirst({
      where: { id: sesionId, user_id: usuarioId },
      select: {
        revoked_at: true,
        expires_at: true,
        users_sessions_user_idTousers: {
          select: { user_statuses: { select: { allows_login: true } } },
        },
      },
    });
    if (!sesion || sesion.revoked_at) return 'cerrada';
    if (!sesion.users_sessions_user_idTousers.user_statuses.allows_login) return 'cerrada';
    return sesion.expires_at.getTime() <= Date.now() ? 'vencida' : 'activa';
  }
}
