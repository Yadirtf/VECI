import { EstadoSolicitud, SolicitudDeNegocio } from '../../domain/entities/solicitud';
import { AltaDeComercio } from './comercios.repository';

/** Lo que la persona radica: los datos del negocio, ya validados como un alta. */
export interface NuevaSolicitud {
  solicitudId: string;
  solicitanteId: string;
  /** Se guardan sus datos; el id del comercio se asigna al aprobar. */
  alta: AltaDeComercio;
}

/**
 * Solicitudes de registro (tenancy.business_applications). La persona solo ve las
 * suyas; Administración VECI las ve todas y las decide (políticas RLS).
 */
export interface SolicitudesRepository {
  /** Lanza SolicitudEnRevision si ya tiene una sin revisar. */
  radicar(nueva: NuevaSolicitud): Promise<void>;
  mias(usuarioId: string): Promise<SolicitudDeNegocio[]>;
  listar(revisorId: string, estado: EstadoSolicitud | null): Promise<SolicitudDeNegocio[]>;
  buscar(revisorId: string, solicitudId: string): Promise<SolicitudDeNegocio | null>;
  /**
   * En una sola transacción: crea el comercio completo (con la persona como
   * propietaria) y marca la solicitud aprobada. Devuelve el slug, o null si ya
   * no estaba en revisión (nada se crea).
   */
  aprobar(revisorId: string, solicitudId: string, alta: AltaDeComercio): Promise<string | null>;
  /** false si ya no estaba en revisión. */
  rechazar(revisorId: string, solicitudId: string, motivo: string): Promise<boolean>;
}

export const SOLICITUDES_REPOSITORY = Symbol('SolicitudesRepository');
