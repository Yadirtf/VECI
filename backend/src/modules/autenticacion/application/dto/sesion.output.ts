import { Espacio } from '../../domain/entities/espacio';

export interface SesionOutput {
  tokenAcceso: string;
  tokenRenovacion: string;
  /** Segundos que dura el token de acceso (15 minutos). */
  segundosAcceso: number;
  usuario: { id: string; nombre: string };
  espacios: Espacio[];
}

/** O entra directo, o primero debe crear su PIN (invitado o PIN restablecido). */
export type ResultadoIngreso =
  | { tipo: 'SESION'; sesion: SesionOutput }
  | { tipo: 'CAMBIO_DE_PIN'; tokenCambio: string; nombre: string };
