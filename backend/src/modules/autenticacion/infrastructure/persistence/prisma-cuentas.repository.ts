import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../generated/prisma/client';
import { ClienteTransaccion } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import { Cuenta } from '../../domain/entities/cuenta';
import { CorreoEnUso } from '../../domain/errors/correo-en-uso.error';
import { CuentasRepository, TipoIdentificador } from '../../application/puertos/cuentas.repository';
import { codigoPostgres, VIOLACION_UNICA } from './error-postgres';

interface FilaUsuario {
  usuario_id: string;
  persona_id: string;
  puede_entrar: boolean;
  pendiente: boolean;
}

/**
 * identity.users e identificadores (sin RLS). El nombre está en identity.people,
 * que sí tiene RLS: se lee fijando app.person_id de la propia persona.
 */
@Injectable()
export class PrismaCuentasRepository implements CuentasRepository {
  constructor(private readonly prisma: PrismaService) {}

  buscarPorIdentificador(tipo: TipoIdentificador, valor: string): Promise<Cuenta | null> {
    return this.buscar(Prisma.sql`
      JOIN identity.user_login_identifiers i ON i.user_id = u.id AND i.revoked_at IS NULL
      JOIN core.contact_types ct ON ct.id = i.contact_type_id
     WHERE ct.code = ${tipo} AND i.value = ${valor}`);
  }

  buscarPorId(usuarioId: string): Promise<Cuenta | null> {
    return this.buscar(Prisma.sql`WHERE u.id = ${usuarioId}::uuid`);
  }

  async activar(usuarioId: string): Promise<void> {
    await this.prisma.$executeRaw`
      UPDATE identity.users
         SET user_status_id = (SELECT id FROM identity.user_statuses WHERE code = 'ACTIVE'),
             activated_at = now()
       WHERE id = ${usuarioId}::uuid
         AND user_status_id IN (SELECT id FROM identity.user_statuses WHERE is_initial)`;
  }

  async registrarIngreso(usuarioId: string): Promise<void> {
    await this.prisma.$executeRaw`
      UPDATE identity.users SET last_login_at = now() WHERE id = ${usuarioId}::uuid`;
  }

  async asignarCorreo(usuarioId: string, correo: string): Promise<void> {
    try {
      await this.prisma.$transaction((tx) => this.reemplazarCorreo(tx, usuarioId, correo));
    } catch (error) {
      if (codigoPostgres(error) === VIOLACION_UNICA) throw new CorreoEnUso();
      throw error;
    }
  }

  private async reemplazarCorreo(
    tx: ClienteTransaccion,
    usuarioId: string,
    correo: string,
  ): Promise<void> {
    await tx.$executeRaw`
      UPDATE identity.user_login_identifiers i SET revoked_at = now()
        FROM core.contact_types ct
       WHERE ct.id = i.contact_type_id AND ct.code = 'EMAIL'
         AND i.user_id = ${usuarioId}::uuid AND i.revoked_at IS NULL AND i.value <> ${correo}`;
    await tx.$executeRaw`
      INSERT INTO identity.user_login_identifiers (user_id, contact_type_id, value)
      SELECT ${usuarioId}::uuid, ct.id, ${correo} FROM core.contact_types ct
       WHERE ct.code = 'EMAIL'
         AND NOT EXISTS (SELECT 1 FROM identity.user_login_identifiers i
                          WHERE i.user_id = ${usuarioId}::uuid AND i.contact_type_id = ct.id
                            AND i.value = ${correo} AND i.revoked_at IS NULL)`;
  }

  private buscar(filtro: Prisma.Sql): Promise<Cuenta | null> {
    return this.prisma.$transaction(async (tx) => {
      const [fila] = await tx.$queryRaw<FilaUsuario[]>`
        SELECT u.id::text AS usuario_id, u.person_id::text AS persona_id,
               us.allows_login AS puede_entrar, us.is_initial AS pendiente
          FROM identity.users u
          JOIN identity.user_statuses us ON us.id = u.user_status_id
          ${filtro}`;
      if (!fila) return null;
      return { ...this.aCuenta(fila), nombre: await this.nombre(tx, fila.persona_id) };
    });
  }

  private async nombre(tx: ClienteTransaccion, personaId: string): Promise<string> {
    await tx.$executeRaw`SELECT set_config('app.person_id', ${personaId}, true)`;
    const [persona] = await tx.$queryRaw<{ nombre: string }[]>`
      SELECT given_names AS nombre FROM identity.people WHERE id = ${personaId}::uuid`;
    return persona?.nombre ?? 'veci';
  }

  private aCuenta(fila: FilaUsuario): Omit<Cuenta, 'nombre'> {
    return {
      usuarioId: fila.usuario_id,
      personaId: fila.persona_id,
      puedeEntrar: fila.puede_entrar,
      pendienteDeActivar: fila.pendiente,
    };
  }
}
