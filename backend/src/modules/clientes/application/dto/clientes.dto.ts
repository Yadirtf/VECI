import { Cliente, PersonaPorAfiliar } from '../../domain/entities/cliente';

/** Quién actúa y en qué comercio. */
export interface Actor {
  usuarioId: string;
  comercioId: string;
}

/** Qué hacer con lo que escaneó la caja (HU-04-03). */
export type LecturaDeQr =
  | { resultado: 'PERSONA_POR_AFILIAR'; persona: PersonaPorAfiliar }
  | { resultado: 'CLIENTE'; cliente: Cliente }
  | { resultado: 'QR_CAMBIADO' | 'OTRO_NEGOCIO' | 'NO_ES_DE_VECI' };

export interface AfiliacionOutput {
  yaEstaba: boolean;
  cliente: Cliente;
}

export interface RegistroAsistidoInput {
  tipoDocumento: string;
  numeroDocumento: string;
  nombres: string | null;
  apellidos: string | null;
  celular: string | null;
  /** El cajero confirmó que el celular es de otra persona de la familia. */
  celularCompartido: boolean;
  /** Versión de la política que el cajero leyó y el cliente aceptó. */
  politicaVersionId: string;
}

export interface RegistroAsistidoOutput {
  /** Ya existía en VECI y solo se afilió: no se duplicó. */
  vinculado: boolean;
  cliente: Cliente;
  /** Seis dígitos para dictarle; null si ya tenía cuenta o el celular es compartido. */
  pinBienvenida: string | null;
}

export interface RevisionDeDocumento {
  persona: PersonaPorAfiliar | null;
}

/** QR personal listo para mostrar en la app (sirve sin internet). */
export interface MiQrOutput {
  token: string;
  version: number;
  emitidoEn: Date;
}

export interface ComercioDelClienteOutput {
  comercioId: string;
  nombre: string;
  tipoNegocio: string;
  afiliadoEn: Date;
  /** Token del QR del cliente en ese negocio (firmado por el negocio). */
  qr: { token: string; version: number } | null;
}
