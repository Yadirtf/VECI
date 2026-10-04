import { randomUUID } from 'node:crypto';
import createClient from 'openapi-fetch';
import type { components, paths } from '@/shared/api/esquema';
import {
  type CookieBff,
  cookieDispositivo,
  cookieRenovacion,
  nombreDelNavegador,
} from './cookies-sesion';

type SesionApi = components['schemas']['SesionResponse'];
type IngresoApi = components['schemas']['IngresoResponse'];
type Dispositivo = { id: string; plataforma: 'WEB'; modelo: string };

export type AccionSesion = 'con-pin' | 'con-contrasena' | 'pin-nuevo' | 'renovar' | 'salir';

export interface PeticionBff {
  accion: string;
  cuerpo: Record<string, unknown>;
  renovacion: string | undefined;
  dispositivoId: string | undefined;
  agente: string | null;
  autorizacion: string | null;
}

export interface RespuestaBff {
  estado: number;
  cuerpo: unknown;
  cookies: CookieBff[];
}

export interface OpcionesBff {
  urlApi: string;
  diasSesion: number;
  fetch?: typeof fetch;
}

const NO_EXISTE = { codigo: 'NO_EXISTE', message: 'Esa ruta no existe.' };
const SIN_SESION = { codigo: 'SIN_SESION', message: 'Entra de nuevo para seguir, veci.' };
const ACCIONES: readonly string[] = ['con-pin', 'con-contrasena', 'pin-nuevo', 'renovar', 'salir'];

/**
 * Servidor del panel entre el navegador y la API (patrón BFF): guarda el token de
 * renovación en una cookie httpOnly y al navegador solo le entrega el token de acceso.
 */
export class BffSesion {
  private readonly api;

  constructor(private readonly opciones: OpcionesBff) {
    this.api = createClient<paths>({ baseUrl: opciones.urlApi, fetch: opciones.fetch });
  }

  async atender(p: PeticionBff): Promise<RespuestaBff> {
    if (!ACCIONES.includes(p.accion)) return { estado: 404, cuerpo: NO_EXISTE, cookies: [] };
    const id = p.dispositivoId ?? randomUUID();
    const nuevas = p.dispositivoId ? [] : [cookieDispositivo(id)];
    const dispositivo: Dispositivo = {
      id,
      plataforma: 'WEB',
      modelo: nombreDelNavegador(p.agente),
    };
    switch (p.accion as AccionSesion) {
      case 'renovar':
        return this.renovar(p.renovacion);
      case 'salir':
        return this.salir(p.autorizacion);
      case 'pin-nuevo':
        return this.pinNuevo(p.cuerpo, dispositivo, nuevas);
      default:
        return this.entrar(p, dispositivo, nuevas);
    }
  }

  private async entrar(p: PeticionBff, dispositivo: Dispositivo, nuevas: CookieBff[]) {
    const ruta = p.accion === 'con-pin' ? '/sesion/con-pin' : '/sesion/con-contrasena';
    const body = { ...p.cuerpo, dispositivo } as never;
    const { data, error, response } = await this.api.POST(ruta, { body });
    return data ? this.deIngreso(data, nuevas) : this.fallo(response, error, nuevas);
  }

  private async pinNuevo(cuerpo: object, dispositivo: Dispositivo, nuevas: CookieBff[]) {
    const body = { ...cuerpo, dispositivo } as never;
    const { data, error, response } = await this.api.POST('/sesion/pin-nuevo', { body });
    return data ? this.conSesion(data, nuevas) : this.fallo(response, error, nuevas);
  }

  private async renovar(tokenRenovacion: string | undefined): Promise<RespuestaBff> {
    const borrar = [cookieRenovacion('', 0)];
    if (!tokenRenovacion) return { estado: 401, cuerpo: SIN_SESION, cookies: borrar };
    const { data, error, response } = await this.api.POST('/sesion/renovar', {
      body: { tokenRenovacion },
    });
    if (data) return this.conSesion(data, []);
    return this.fallo(response, error, response.status === 401 ? borrar : []);
  }

  private async salir(autorizacion: string | null): Promise<RespuestaBff> {
    if (autorizacion) {
      await this.api
        .POST('/sesion/salir', { headers: { authorization: autorizacion } })
        .catch(() => undefined);
    }
    return { estado: 204, cuerpo: null, cookies: [cookieRenovacion('', 0)] };
  }

  private conSesion(sesion: SesionApi, extra: CookieBff[]): RespuestaBff {
    const { tokenRenovacion, ...publica } = sesion;
    const cookies = [...extra, cookieRenovacion(tokenRenovacion, this.opciones.diasSesion)];
    return { estado: 200, cuerpo: { tipo: 'sesion', sesion: publica }, cookies };
  }

  private deIngreso(ingreso: IngresoApi, extra: CookieBff[]): RespuestaBff {
    if (ingreso.sesion) return this.conSesion(ingreso.sesion, extra);
    const { tokenCambio, nombre } = ingreso;
    return { estado: 200, cuerpo: { tipo: 'cambio-de-pin', tokenCambio, nombre }, cookies: extra };
  }

  private fallo(respuesta: Response, error: unknown, cookies: CookieBff[] = []): RespuestaBff {
    return { estado: respuesta.status, cuerpo: error, cookies };
  }
}
