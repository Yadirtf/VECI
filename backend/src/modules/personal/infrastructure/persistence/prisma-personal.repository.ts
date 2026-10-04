import { Inject, Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../generated/prisma/client';
import {
  GENERADOR_IDS,
  GeneradorIds,
} from '../../../../shared/application/puertos/generador-ids.port';
import { TransaccionComercio } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { EstadoMembresia, Miembro } from '../../domain/entities/miembro';
import { CupoDeCajeros } from '../../domain/rules/reglas-personal.rule';
import {
  Invitacion,
  MembresiaExistente,
  PersonalRepository,
  UsuarioEncontrado,
} from '../../application/puertos/personal.repository';
import { aMiembro, CONSULTA_CUPO, consultaMiembros, FilaMiembro } from './consultas-personal';
import { crearMembresia, mapearErrorDeAlta } from './alta-de-cajero';

/** Equipo del comercio activo. Todo corre con el comercio fijado (RLS). */
@Injectable()
export class PrismaPersonalRepository implements PersonalRepository {
  constructor(
    private readonly transaccion: TransaccionComercio,
    @Inject(GENERADOR_IDS) private readonly ids: GeneradorIds,
  ) {}

  listar(): Promise<Miembro[]> {
    return this.miembros(Prisma.sql`TRUE`);
  }

  async buscar(membresiaId: string): Promise<Miembro | null> {
    const [miembro] = await this.miembros(Prisma.sql`m.id = ${membresiaId}::uuid`);
    return miembro ?? null;
  }

  cupoDeCajeros(): Promise<CupoDeCajeros> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<CupoDeCajeros[]>(CONSULTA_CUPO);
      return { ocupados: fila.ocupados, limite: fila.limite };
    });
  }

  buscarUsuarioPorCelular(celular: string): Promise<UsuarioEncontrado | null> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<{ usuario_id: string; tiene_pin: boolean }[]>`
        SELECT i.user_id::text AS usuario_id,
               EXISTS (SELECT 1 FROM identity.user_credentials uc
                         JOIN identity.credential_types ct ON ct.id = uc.credential_type_id
                        WHERE uc.user_id = i.user_id AND ct.code = 'PIN'
                          AND uc.revoked_at IS NULL AND NOT uc.must_change) AS tiene_pin
          FROM identity.user_login_identifiers i
          JOIN core.contact_types ct ON ct.id = i.contact_type_id AND ct.code = 'MOBILE_PHONE'
         WHERE i.value = ${celular} AND i.revoked_at IS NULL`;
      return fila ? { usuarioId: fila.usuario_id, tienePinPropio: fila.tiene_pin } : null;
    });
  }

  buscarPorDocumento(
    tipo: string,
    numero: string,
  ): Promise<{ personaId: string; usuarioId: string | null } | null> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<{ persona_id: string; usuario_id: string | null }[]>`
        SELECT f.person_id::text AS persona_id,
               (SELECT u.id::text FROM identity.users u WHERE u.person_id = f.person_id) AS usuario_id
          FROM customers.find_person_by_document(${tipo}::varchar::core.catalog_code,
                                                 ${numero}::varchar) f`;
      return fila ? { personaId: fila.persona_id, usuarioId: fila.usuario_id } : null;
    });
  }

  membresiaDe(usuarioId: string): Promise<MembresiaExistente | null> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<{ id: string; estado: EstadoMembresia }[]>`
        SELECT m.id::text, ms.code AS estado FROM tenancy.memberships m
          JOIN tenancy.membership_statuses ms ON ms.id = m.membership_status_id
         WHERE m.user_id = ${usuarioId}::uuid`;
      return fila ? { membresiaId: fila.id, estado: fila.estado } : null;
    });
  }

  async invitar(invitacion: Invitacion): Promise<{ membresiaId: string; usuarioId: string }> {
    try {
      return await this.transaccion.ejecutar((tx) => crearMembresia(tx, invitacion, this.ids));
    } catch (error) {
      throw mapearErrorDeAlta(error);
    }
  }

  async cambiarEstado(
    membresiaId: string,
    estado: EstadoMembresia,
    porUsuarioId: string,
  ): Promise<void> {
    try {
      await this.transaccion.ejecutar(async (tx) => {
        await tx.$executeRaw`
          UPDATE tenancy.memberships
             SET membership_status_id = (SELECT id FROM tenancy.membership_statuses WHERE code = ${estado})
           WHERE id = ${membresiaId}::uuid`;
        if (estado !== 'REMOVED') return;
        await tx.$executeRaw`
          UPDATE tenancy.membership_roles SET revoked_at = now(), revoked_by_user_id = ${porUsuarioId}::uuid
           WHERE membership_id = ${membresiaId}::uuid AND revoked_at IS NULL`;
      });
    } catch (error) {
      throw mapearErrorDeAlta(error);
    }
  }

  private miembros(filtro: Prisma.Sql): Promise<Miembro[]> {
    return this.transaccion.ejecutar(async (tx) =>
      (await tx.$queryRaw<FilaMiembro[]>(consultaMiembros(filtro))).map(aMiembro),
    );
  }
}
