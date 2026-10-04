import { Dispositivo } from '../puertos/sesiones.repository';

/** Con qué entra: celular + PIN (app y panel) o correo + contraseña (panel). */
export type ViaIngreso = 'PIN' | 'CONTRASENA';

export interface IngresoInput {
  via: ViaIngreso;
  identificador: string;
  secreto: string;
  dispositivo: Dispositivo;
  ip: string | null;
}
