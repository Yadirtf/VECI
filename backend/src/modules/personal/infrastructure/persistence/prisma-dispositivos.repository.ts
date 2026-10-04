import { Injectable } from '@nestjs/common';
import { TransaccionComercio } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import {
  DispositivoDelNegocio,
  DispositivosRepository,
} from '../../application/puertos/dispositivos.repository';

interface FilaSesion {
  sesionId: string;
  usuarioId: string;
  nombre: string;
  abiertaDesde: string;
  ultimoUso: string;
}

interface FilaDispositivo {
  dispositivo_id: string;
  nombre: string | null;
  plataforma: string;
  registrado_en: Date;
  ultima_vez: Date;
  sesiones: FilaSesion[];
}

/**
 * tenancy.tenant_devices (RLS del comercio) con las sesiones abiertas en cada uno.
 * identity.sessions no tiene RLS: se limita a quienes son del equipo de este
 * comercio con la subconsulta sobre memberships, que sí la tiene.
 */
@Injectable()
export class PrismaDispositivosRepository implements DispositivosRepository {
  constructor(private readonly transaccion: TransaccionComercio) {}

  listar(): Promise<DispositivoDelNegocio[]> {
    return this.transaccion.ejecutar(async (tx) => {
      const filas = await tx.$queryRaw<FilaDispositivo[]>`
        SELECT td.device_id::text AS dispositivo_id, coalesce(td.name, d.model) AS nombre,
               p.code AS plataforma, td.registered_at AS registrado_en, d.last_seen_at AS ultima_vez,
               coalesce(json_agg(json_build_object(
                 'sesionId', s.id, 'usuarioId', s.user_id, 'nombre', pe.given_names,
                 'abiertaDesde', s.created_at, 'ultimoUso', s.last_refreshed_at)
                 ORDER BY s.created_at) FILTER (WHERE s.id IS NOT NULL), '[]') AS sesiones
          FROM tenancy.tenant_devices td
          JOIN identity.devices d ON d.id = td.device_id
          JOIN identity.device_platforms p ON p.id = d.device_platform_id
          LEFT JOIN identity.sessions s ON s.device_id = td.device_id AND s.revoked_at IS NULL
                AND s.expires_at > now() AND s.user_id IN (SELECT m.user_id FROM tenancy.memberships m)
          LEFT JOIN identity.users u ON u.id = s.user_id
          LEFT JOIN identity.people pe ON pe.id = u.person_id
         WHERE td.revoked_at IS NULL
         GROUP BY td.device_id, td.name, d.model, p.code, td.registered_at, d.last_seen_at
         ORDER BY d.last_seen_at DESC`;
      return filas.map((f) => ({
        dispositivoId: f.dispositivo_id,
        nombre: f.nombre,
        plataforma: f.plataforma,
        registradoEn: f.registrado_en,
        ultimaVez: f.ultima_vez,
        sesiones: f.sesiones.map((s) => ({
          ...s,
          abiertaDesde: new Date(s.abiertaDesde),
          ultimoUso: new Date(s.ultimoUso),
        })),
      }));
    });
  }

  existe(dispositivoId: string): Promise<boolean> {
    return this.transaccion.ejecutar(
      async (tx) =>
        (await tx.tenant_devices.count({ where: { device_id: dispositivoId, revoked_at: null } })) >
        0,
    );
  }

  cerrarSesiones(dispositivoId: string, porUsuarioId: string): Promise<number> {
    return this.transaccion.ejecutar(
      (tx) => tx.$executeRaw`
      UPDATE identity.sessions
         SET revoked_at = now(), revoked_by_user_id = ${porUsuarioId}::uuid,
             revocation_reason_id = (SELECT id FROM identity.session_revocation_reasons
                                      WHERE code = 'REMOTE_LOGOUT')
       WHERE device_id = ${dispositivoId}::uuid AND revoked_at IS NULL
         AND user_id IN (SELECT m.user_id FROM tenancy.memberships m)`,
    );
  }
}
