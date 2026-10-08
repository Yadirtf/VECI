/** Estado de la solicitud (tenancy.business_application_statuses). */
export type EstadoSolicitud = 'PENDING' | 'APPROVED' | 'REJECTED';

/** Quién pide registrar el negocio; solo lo ve Administración VECI. */
export interface Solicitante {
  readonly usuarioId: string;
  readonly nombre: string;
  readonly celular: string | null;
}

/**
 * Pedido de una persona para registrar su negocio. Mientras está en revisión no
 * existe el comercio: nace al aprobarla, con ella como propietaria.
 */
export interface SolicitudDeNegocio {
  readonly solicitudId: string;
  readonly estado: EstadoSolicitud;
  readonly nombre: string;
  readonly tipoNegocio: string;
  readonly tipoDocumento: string;
  readonly numeroDocumento: string;
  readonly celular: string;
  readonly correo: string | null;
  readonly logoUrl: string | null;
  readonly municipioId: number;
  readonly municipio: string;
  readonly direccion: string | null;
  readonly solicitante: Solicitante;
  /** Por qué se rechazó (o una nota al aprobar). */
  readonly nota: string | null;
  /** El comercio que nació al aprobarla. */
  readonly comercioId: string | null;
  readonly radicadaEn: Date;
  readonly revisadaEn: Date | null;
}
