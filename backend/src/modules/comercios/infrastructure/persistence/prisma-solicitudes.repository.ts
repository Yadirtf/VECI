import { Inject, Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../generated/prisma/client';
import {
  GENERADOR_IDS,
  GeneradorIds,
} from '../../../../shared/application/puertos/generador-ids.port';
import {
  codigoPostgres,
  VIOLACION_UNICA,
} from '../../../../shared/infrastructure/prisma/errores-postgres';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import { ClienteTransaccion } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { TransaccionUsuario } from '../../../../shared/infrastructure/prisma/transaccion-usuario';
import { EstadoSolicitud, SolicitudDeNegocio } from '../../domain/entities/solicitud';
import { SolicitudEnRevision } from '../../domain/errors/errores-solicitudes';
import { AltaDeComercio } from '../../application/puertos/comercios.repository';
import {
  NuevaSolicitud,
  SolicitudesRepository,
} from '../../application/puertos/solicitudes.repository';
import {
  crearComercio,
  crearContactos,
  crearPropietario,
  crearSedeYServicios,
  iniciarPrueba,
} from './alta-de-comercio';
import { aSolicitud, consultaSolicitudes, FilaSolicitud } from './consultas-solicitudes';

/**
 * Solicitudes con el usuario de la sesión como contexto (app.user_id): RLS deja a la
 * persona ver y radicar las suyas, y a Administración VECI verlas todas y decidirlas.
 */
@Injectable()
export class PrismaSolicitudesRepository implements SolicitudesRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usuario: TransaccionUsuario,
    @Inject(GENERADOR_IDS) private readonly ids: GeneradorIds,
  ) {}

  async radicar({ solicitudId, solicitanteId, alta }: NuevaSolicitud): Promise<void> {
    try {
      await this.como(
        solicitanteId,
        (tx) => tx.$executeRaw`
        INSERT INTO tenancy.business_applications (id, applicant_user_id, display_name, document_type_id,
               document_number, business_type_id, contact_phone, contact_email, logo_url,
               municipality_id, address_line, business_application_status_id)
        SELECT ${solicitudId}::uuid, core.current_user_id(), ${alta.nombre.valor}, dt.id,
               ${alta.documento.numero}, bt.id, ${alta.celular}, ${alta.correo}, ${alta.logoUrl},
               ${alta.municipioId}::integer, ${alta.direccion}, st.id
          FROM core.document_types dt, tenancy.business_types bt,
               tenancy.business_application_statuses st
         WHERE dt.code = ${alta.documento.tipo} AND bt.code = ${alta.tipoNegocio} AND st.is_initial`,
      );
    } catch (error) {
      if (codigoPostgres(error) === VIOLACION_UNICA) throw new SolicitudEnRevision();
      throw error;
    }
  }

  mias(usuarioId: string): Promise<SolicitudDeNegocio[]> {
    return this.leer(usuarioId, Prisma.sql`b.applicant_user_id = core.current_user_id()`);
  }

  listar(revisorId: string, estado: EstadoSolicitud | null): Promise<SolicitudDeNegocio[]> {
    return this.leer(revisorId, estado ? Prisma.sql`st.code = ${estado}` : Prisma.sql`true`);
  }

  async buscar(revisorId: string, solicitudId: string): Promise<SolicitudDeNegocio | null> {
    const [solicitud] = await this.leer(revisorId, Prisma.sql`b.id = ${solicitudId}::uuid`);
    return solicitud ?? null;
  }

  aprobar(revisorId: string, solicitudId: string, alta: AltaDeComercio): Promise<string | null> {
    return this.prisma
      .$transaction(async (tx) => {
        await tx.$executeRaw`SELECT set_config('app.user_id', ${revisorId}, true),
                                  set_config('app.tenant_id', ${alta.comercioId}, true)`;
        const slug = await crearComercio(tx, alta);
        await crearContactos(tx, alta);
        await crearSedeYServicios(tx, alta);
        await crearPropietario(tx, alta, this.ids.siguiente());
        await iniciarPrueba(tx);
        const decididas = await this.decidir(tx, solicitudId, alta.comercioId, null);
        if (decididas === 0) throw new SinCambios();
        return slug;
      })
      .catch((error: unknown) => {
        if (error instanceof SinCambios) return null;
        throw error;
      });
  }

  async rechazar(revisorId: string, solicitudId: string, motivo: string): Promise<boolean> {
    const decididas = await this.como(revisorId, (tx) =>
      this.decidir(tx, solicitudId, null, motivo),
    );
    return decididas === 1;
  }

  /**
   * Pasa la solicitud en revisión a su estado final, a nombre de quien revisa: con
   * comercio, al estado que lo crea (aprobada); sin él, al que no (rechazada).
   */
  private decidir(
    tx: ClienteTransaccion,
    solicitudId: string,
    comercioId: string | null,
    nota: string | null,
  ): Promise<number> {
    const aprobada = comercioId !== null;
    return tx.$executeRaw`
      UPDATE tenancy.business_applications b
         SET business_application_status_id = (SELECT s.id FROM tenancy.business_application_statuses s
                                                WHERE s.is_terminal AND s.creates_tenant = ${aprobada}
                                                ORDER BY s.id LIMIT 1),
             status_changed_at = now(), reviewed_by_user_id = core.current_user_id(),
             review_note = ${nota}, tenant_id = ${comercioId}::uuid
       WHERE b.id = ${solicitudId}::uuid
         AND b.business_application_status_id IN (SELECT s.id FROM tenancy.business_application_statuses s
                                                   WHERE s.is_initial)`;
  }

  private async leer(usuarioId: string, filtro: Prisma.Sql): Promise<SolicitudDeNegocio[]> {
    const filas = await this.como(usuarioId, (tx) =>
      tx.$queryRaw<FilaSolicitud[]>(consultaSolicitudes(filtro)),
    );
    return filas.map(aSolicitud);
  }

  private como<T>(usuarioId: string, trabajo: (tx: ClienteTransaccion) => Promise<T>): Promise<T> {
    return this.usuario.ejecutarComo({ usuarioId, personaId: '' }, trabajo);
  }
}

/** La solicitud ya no estaba en revisión: se deshace el alta completa. */
class SinCambios extends Error {}
