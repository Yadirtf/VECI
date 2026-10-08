import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { SolicitudDeNegocio } from '../../domain/entities/solicitud';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { RegistrarComercioInput } from '../dto/comercios.dto';
import { SolicitudesRepository } from '../puertos/solicitudes.repository';
import { RegistrarComercio } from './registrar-comercio.use-case';

export interface DependenciasSolicitar {
  solicitudes: SolicitudesRepository;
  registrar: RegistrarComercio;
  ids: GeneradorIds;
  auditoria: Auditoria;
}

/**
 * Cualquier persona con cuenta (cliente, cajera...) pide registrar su negocio desde
 * Ajustes. No crea nada todavía: valida los datos como el alta, exige un municipio
 * con cobertura y deja la solicitud en revisión para Administración VECI.
 */
export class SolicitarRegistroDeNegocio {
  constructor(private readonly d: DependenciasSolicitar) {}

  async ejecutar(
    usuarioId: string,
    entrada: RegistrarComercioInput & { municipioId: number },
  ): Promise<void> {
    if (entrada.municipioId == null) throw new DatoInvalido('¿En qué municipio queda tu negocio?');
    const alta = await this.d.registrar.preparar(usuarioId, entrada, usuarioId);
    const solicitudId = this.d.ids.siguiente();
    await this.d.solicitudes.radicar({ solicitudId, solicitanteId: usuarioId, alta });
    await this.d.auditoria.registrar({
      accion: 'BUSINESS_APPLICATION_SUBMITTED',
      tabla: 'tenancy.business_applications',
      entidadId: solicitudId,
      actorUsuarioId: usuarioId,
      comercioId: null,
      despues: { nombre: alta.nombre.valor, tipo: alta.tipoNegocio },
    });
  }

  mias(usuarioId: string): Promise<SolicitudDeNegocio[]> {
    return this.d.solicitudes.mias(usuarioId);
  }
}
