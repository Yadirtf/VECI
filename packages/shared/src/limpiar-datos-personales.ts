/**
 * Quita del evento de error todo lo que pueda identificar a una persona antes de
 * enviarlo a Sentry desde la API o el panel (HU-01-07, Ley 1581): cuerpo, cabeceras, cookies, consulta,
 * IP y usuario. Se conservan la ruta, el método, la versión y el comercio.
 */
export interface EventoDeError {
  request?: {
    url?: string;
    method?: string;
    data?: unknown;
    headers?: unknown;
    cookies?: unknown;
    query_string?: unknown;
    env?: unknown;
  };
  user?: unknown;
  extra?: Record<string, unknown>;
}

export function limpiarDatosPersonales<T extends EventoDeError>(evento: T): T {
  if (evento.request) {
    const { url, method } = evento.request;
    evento.request = { url: url?.split('?')[0], method };
  }
  delete evento.user;
  delete evento.extra;
  return evento;
}
