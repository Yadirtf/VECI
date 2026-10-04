import { PersonaNueva } from '../puertos/personal.repository';

/** Quién actúa y en qué comercio. */
export interface Actor {
  usuarioId: string;
  comercioId: string;
}

export type InvitarCajeroInput = PersonaNueva;

export interface InvitacionOutput {
  membresiaId: string;
  /** Seis dígitos para entregar en persona. null si ya tenía PIN propio. */
  pinTemporal: string | null;
}
