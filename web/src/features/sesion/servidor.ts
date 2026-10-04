import { entorno } from '@/shared/config/entorno';
import {
  BffSesion,
  type PeticionBff,
  type RespuestaBff,
} from './infrastructure/servidor/bff-sesion';
import { COOKIE_DISPOSITIVO, COOKIE_RENOVACION } from './infrastructure/servidor/cookies-sesion';

// Interfaz del servidor del panel para las rutas /api/sesion/* (no se importa desde el navegador).
export type { PeticionBff, RespuestaBff };
export { COOKIE_DISPOSITIVO, COOKIE_RENOVACION };

const bff = new BffSesion({
  urlApi: process.env.VECI_API_URL ?? entorno.urlApi,
  diasSesion: Number(process.env.VECI_DIAS_SESION ?? 30),
});

export function atenderSesion(peticion: PeticionBff): Promise<RespuestaBff> {
  return bff.atender(peticion);
}
