import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { EstadoSolicitud, SolicitudDeNegocio } from '../../domain/entities/solicitud';
import {
  SolicitudNoEncontrada,
  SolicitudYaRevisada,
} from '../../domain/errors/errores-solicitudes';
import { ComercioRegistradoOutput } from '../dto/comercios.dto';
import { SolicitudesRepository } from '../puertos/solicitudes.repository';
import { RegistrarComercio } from './registrar-comercio.use-case';

export interface DependenciasRevisar {
  solicitudes: SolicitudesRepository;
  registrar: RegistrarComercio;
  auditoria: Auditoria;
}

/**
 * Administración VECI revisa las solicitudes. Aprobar crea el comercio con quien lo
 * pidió como propietaria (ya tiene cuenta y PIN: no hace falta invitarla); rechazar
 * exige decirle por qué. Una solicitud solo se decide una vez.
 */
export class RevisarSolicitudes {
  constructor(private readonly d: DependenciasRevisar) {}

  listar(revisorId: string, estado: EstadoSolicitud | null): Promise<SolicitudDeNegocio[]> {
    return this.d.solicitudes.listar(revisorId, estado);
  }

  async aprobar(revisorId: string, solicitudId: string): Promise<ComercioRegistradoOutput> {
    const s = await this.pendiente(revisorId, solicitudId);
    const alta = await this.d.registrar.preparar(revisorId, s, s.solicitante.usuarioId);
    const slug = await this.d.solicitudes.aprobar(revisorId, solicitudId, alta);
    if (slug === null) throw new SolicitudYaRevisada();
    await this.auditar(revisorId, solicitudId, alta.comercioId, 'APPROVED');
    await this.d.auditoria.registrar({
      accion: 'TENANT_CREATED',
      tabla: 'tenancy.tenants',
      entidadId: alta.comercioId,
      actorUsuarioId: revisorId,
      comercioId: alta.comercioId,
      despues: { nombre: alta.nombre.valor, tipo: alta.tipoNegocio, slug, solicitudId },
    });
    return { comercioId: alta.comercioId, slug };
  }

  async rechazar(revisorId: string, solicitudId: string, motivo: string): Promise<void> {
    const nota = motivo.trim();
    if (nota.length < 10) {
      throw new DatoInvalido('Cuéntale a la persona por qué, en una frase (10 letras o más).');
    }
    await this.pendiente(revisorId, solicitudId);
    if (!(await this.d.solicitudes.rechazar(revisorId, solicitudId, nota))) {
      throw new SolicitudYaRevisada();
    }
    await this.auditar(revisorId, solicitudId, null, 'REJECTED');
  }

  private async pendiente(revisorId: string, solicitudId: string): Promise<SolicitudDeNegocio> {
    const solicitud = await this.d.solicitudes.buscar(revisorId, solicitudId);
    if (!solicitud) throw new SolicitudNoEncontrada();
    if (solicitud.estado !== 'PENDING') throw new SolicitudYaRevisada();
    return solicitud;
  }

  private auditar(
    revisorId: string,
    solicitudId: string,
    comercioId: string | null,
    estado: EstadoSolicitud,
  ): Promise<void> {
    return this.d.auditoria.registrar({
      accion: 'BUSINESS_APPLICATION_REVIEWED',
      tabla: 'tenancy.business_applications',
      entidadId: solicitudId,
      actorUsuarioId: revisorId,
      comercioId,
      antes: { estado: 'PENDING' },
      despues: { estado },
    });
  }
}
