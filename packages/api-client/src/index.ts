import { CABECERA_USUARIO_DESARROLLO } from '@veci/shared';
import createClient from 'openapi-fetch';
import type { components, paths } from './esquema';

export type { components, paths } from './esquema';
export type Horario = components['schemas']['HorarioResponse'];
export type CrearHorario = components['schemas']['CrearHorarioRequest'];

export interface OpcionesCliente {
  /** URL del API, por ejemplo https://api-staging.veci.co */
  urlBase: string;
  /** Solo desarrollo y staging, hasta EP-02. */
  usuarioDesarrolloId?: string;
}

/**
 * Cliente tipado del API: rutas, cabeceras, cuerpos y respuestas salen del contrato
 * OpenAPI. El negocio activo (x-veci-comercio) se pasa en cada operación que lo exige.
 */
export function crearClienteVeci(opciones: OpcionesCliente) {
  const headers: Record<string, string> = {};
  if (opciones.usuarioDesarrolloId) {
    headers[CABECERA_USUARIO_DESARROLLO] = opciones.usuarioDesarrolloId;
  }
  return createClient<paths>({ baseUrl: opciones.urlBase, headers });
}

export type ClienteVeci = ReturnType<typeof crearClienteVeci>;
