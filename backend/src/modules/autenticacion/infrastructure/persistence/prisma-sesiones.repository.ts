import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import {
  Dispositivo,
  MotivoCierre,
  NuevaSesion,
  SesionesRepository,
  SesionGuardada,
} from '../../application/puertos/sesiones.repository';

interface FilaSesion {
  id: string;
  usuario_id: string;
  dispositivo_id: string;
  huella: string;
  expira_en: Date;
  cerrada: boolean;
}

/** identity.devices e identity.sessions (sin RLS: son de la persona, no de un comercio). */
@Injectable()
export class PrismaSesionesRepository implements SesionesRepository {
  constructor(private readonly prisma: PrismaService) {}

  async registrarDispositivo(d: Dispositivo): Promise<void> {
    await this.prisma.$executeRaw`
      INSERT INTO identity.devices (id, device_platform_id, model, os_version, app_version)
      SELECT ${d.id}::uuid, p.id, ${d.modelo ?? null}, ${d.versionSo ?? null}, ${d.versionApp ?? null}
        FROM identity.device_platforms p WHERE p.code = ${d.plataforma}
      ON CONFLICT (id) DO UPDATE
         SET last_seen_at = now(),
             model = coalesce(EXCLUDED.model, identity.devices.model),
             os_version = coalesce(EXCLUDED.os_version, identity.devices.os_version),
             app_version = coalesce(EXCLUDED.app_version, identity.devices.app_version)`;
  }

  async crear(s: NuevaSesion): Promise<void> {
    await this.prisma.$executeRaw`
      INSERT INTO identity.sessions (id, user_id, device_id, refresh_token_hash, expires_at)
      VALUES (${s.id}::uuid, ${s.usuarioId}::uuid, ${s.dispositivoId}::uuid,
              decode(${s.huella}, 'hex'), ${s.expiraEn})`;
  }

  async buscar(sesionId: string): Promise<SesionGuardada | null> {
    if (!/^[0-9a-f-]{36}$/i.test(sesionId)) return null;
    const [fila] = await this.prisma.$queryRaw<FilaSesion[]>`
      SELECT id::text, user_id::text AS usuario_id, device_id::text AS dispositivo_id,
             encode(refresh_token_hash, 'hex') AS huella, expires_at AS expira_en,
             revoked_at IS NOT NULL AS cerrada
        FROM identity.sessions WHERE id = ${sesionId}::uuid`;
    if (!fila) return null;
    return {
      id: fila.id,
      usuarioId: fila.usuario_id,
      dispositivoId: fila.dispositivo_id,
      huella: fila.huella,
      expiraEn: fila.expira_en,
      cerrada: fila.cerrada,
    };
  }

  async rotar(
    sesionId: string,
    huellaAnterior: string,
    huellaNueva: string,
    expiraEn: Date,
  ): Promise<boolean> {
    const filas = await this.prisma.$executeRaw`
      UPDATE identity.sessions
         SET refresh_token_hash = decode(${huellaNueva}, 'hex'), last_refreshed_at = now(),
             expires_at = ${expiraEn}
       WHERE id = ${sesionId}::uuid AND revoked_at IS NULL
         AND refresh_token_hash = decode(${huellaAnterior}, 'hex')`;
    return filas === 1;
  }

  async cerrar(sesionId: string, motivo: MotivoCierre, porUsuarioId: string | null): Promise<void> {
    await this.prisma.$executeRaw`
      UPDATE identity.sessions
         SET revoked_at = now(), revoked_by_user_id = ${porUsuarioId}::uuid,
             revocation_reason_id = (SELECT id FROM identity.session_revocation_reasons
                                      WHERE code = ${motivo})
       WHERE id = ${sesionId}::uuid AND revoked_at IS NULL`;
  }

  cerrarTodasDe(
    usuarioId: string,
    motivo: MotivoCierre,
    porUsuarioId: string | null,
  ): Promise<number> {
    return this.prisma.$executeRaw`
      UPDATE identity.sessions
         SET revoked_at = now(), revoked_by_user_id = ${porUsuarioId}::uuid,
             revocation_reason_id = (SELECT id FROM identity.session_revocation_reasons
                                      WHERE code = ${motivo})
       WHERE user_id = ${usuarioId}::uuid AND revoked_at IS NULL`;
  }
}
