import createClient from 'openapi-fetch';
import type { components, paths } from './esquema';

export type { components, paths } from './esquema';
export type Horario = components['schemas']['HorarioResponse'];
export type CrearHorario = components['schemas']['CrearHorarioRequest'];

/** Quien sabe el token de acceso vigente y cómo renovarlo (la funcionalidad de sesión). */
export interface FuenteDeToken {
  tokenVigente(): Promise<string | null>;
  renovar(): Promise<string | null>;
}

export interface OpcionesCliente {
  /** URL del API, por ejemplo https://veci-api-staging.onrender.com */
  urlBase: string;
  sesion?: FuenteDeToken;
  fetch?: typeof fetch;
}

/**
 * fetch que pone el token en cada petición y, si la API dice que venció, renueva una vez
 * y repite la petición. Así ninguna pantalla tiene que pensar en tokens.
 */
export function fetchConSesion(sesion: FuenteDeToken, base: typeof fetch = fetch): typeof fetch {
  const conToken = (peticion: Request, token: string | null) => {
    const copia = new Request(peticion);
    if (token) copia.headers.set('authorization', `Bearer ${token}`);
    return base(copia);
  };
  return async (entrada, init) => {
    const peticion = new Request(entrada, init);
    const respaldo = peticion.clone();
    const respuesta = await conToken(peticion, await sesion.tokenVigente());
    if (respuesta.status !== 401) return respuesta;
    const nuevo = await sesion.renovar();
    return nuevo ? conToken(respaldo, nuevo) : respuesta;
  };
}

/**
 * Cliente tipado del API: rutas, cabeceras, cuerpos y respuestas salen del contrato
 * OpenAPI. El negocio activo (x-veci-comercio) se pasa en cada operación que lo exige.
 */
export function crearClienteVeci(opciones: OpcionesCliente) {
  const base = opciones.fetch ?? ((...args: Parameters<typeof fetch>) => fetch(...args));
  const fetchFinal = opciones.sesion ? fetchConSesion(opciones.sesion, base) : base;
  return createClient<paths>({ baseUrl: opciones.urlBase, fetch: fetchFinal });
}

export type ClienteVeci = ReturnType<typeof crearClienteVeci>;
