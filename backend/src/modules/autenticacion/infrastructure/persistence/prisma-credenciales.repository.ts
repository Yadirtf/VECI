import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import { Credencial, TipoCredencial } from '../../domain/entities/credencial.entity';
import {
  CredencialesRepository,
  NuevaCredencial,
} from '../../application/puertos/credenciales.repository';

interface FilaCredencial {
  id: string;
  usuario_id: string;
  tipo: TipoCredencial;
  hash: string;
  debe_cambiar: boolean;
  intentos: number;
  bloqueada_hasta: Date | null;
  max_intentos: number;
  minutos_bloqueo: number;
  horas_temporal: number | null;
  emitida_en: Date;
}

/** identity.user_credentials. Las reglas de bloqueo salen de credential_types. */
@Injectable()
export class PrismaCredencialesRepository implements CredencialesRepository {
  constructor(private readonly prisma: PrismaService) {}

  async vigente(usuarioId: string, tipo: TipoCredencial): Promise<Credencial | null> {
    const [fila] = await this.prisma.$queryRaw<FilaCredencial[]>`
      SELECT uc.id::text, uc.user_id::text AS usuario_id, ct.code AS tipo, uc.secret_hash AS hash,
             uc.must_change AS debe_cambiar, uc.failed_attempts AS intentos,
             uc.locked_until AS bloqueada_hasta, ct.max_failed_attempts AS max_intentos,
             ct.lock_minutes AS minutos_bloqueo, ct.temporary_valid_hours AS horas_temporal,
             uc.created_at AS emitida_en
        FROM identity.user_credentials uc
        JOIN identity.credential_types ct ON ct.id = uc.credential_type_id AND ct.is_active
       WHERE uc.user_id = ${usuarioId}::uuid AND ct.code = ${tipo} AND uc.revoked_at IS NULL`;
    if (!fila) return null;
    return Credencial.desde({
      id: fila.id,
      usuarioId: fila.usuario_id,
      tipo: fila.tipo,
      hash: fila.hash,
      debeCambiar: fila.debe_cambiar,
      intentosFallidos: fila.intentos,
      bloqueadaHasta: fila.bloqueada_hasta,
      reglas: {
        maxIntentos: fila.max_intentos,
        minutosBloqueo: fila.minutos_bloqueo,
        horasTemporal: fila.horas_temporal,
      },
      emitidaEn: fila.emitida_en,
    });
  }

  async guardarIntentos(credencial: Credencial): Promise<void> {
    await this.prisma.$executeRaw`
      UPDATE identity.user_credentials
         SET failed_attempts = ${credencial.intentosFallidos}, locked_until = ${credencial.bloqueadaHasta}
       WHERE id = ${credencial.id}::uuid`;
  }

  reemplazar(nueva: NuevaCredencial): Promise<string> {
    return this.prisma.$transaction(async (tx) => {
      await tx.$executeRaw`
        UPDATE identity.user_credentials uc
           SET revoked_at = now(),
               revocation_reason_id = (SELECT id FROM identity.credential_revocation_reasons
                                        WHERE code = ${nueva.motivo})
          FROM identity.credential_types ct
         WHERE ct.id = uc.credential_type_id AND ct.code = ${nueva.tipo}
           AND uc.user_id = ${nueva.usuarioId}::uuid AND uc.revoked_at IS NULL`;
      const [fila] = await tx.$queryRaw<{ id: string }[]>`
        INSERT INTO identity.user_credentials
               (user_id, credential_type_id, secret_hash, must_change, created_by_user_id)
        SELECT ${nueva.usuarioId}::uuid, ct.id, ${nueva.hash}, ${nueva.debeCambiar},
               ${nueva.creadaPor}::uuid
          FROM identity.credential_types ct WHERE ct.code = ${nueva.tipo}
        RETURNING id::text`;
      return fila.id;
    });
  }
}
