import type { ClienteVeci } from '@/shared/api/cliente';
import { leerProblema, problemaSinConexion } from '@/shared/api/problema';
import {
  ErrorDeSesion,
  type Espacio,
  type RepositorioSesion,
  type ResultadoIngreso,
  type SesionActiva,
} from '../domain/sesion';

interface SesionBff {
  tokenAcceso: string;
  segundosAcceso: number;
  usuario: { id: string; nombre: string };
  espacios: Espacio[];
}

type RespuestaIngreso =
  | { tipo: 'sesion'; sesion: SesionBff }
  | { tipo: 'cambio-de-pin'; tokenCambio: string; nombre: string };

const aSesion = (s: SesionBff, ahora: number): SesionActiva => ({
  tokenAcceso: s.tokenAcceso,
  venceEn: ahora + s.segundosAcceso * 1000,
  usuario: s.usuario,
  espacios: s.espacios,
});

const comoError = (error: unknown) => {
  const { codigo, mensaje } = leerProblema(error);
  return new ErrorDeSesion(codigo, mensaje);
};

/**
 * Habla con las rutas /api/sesion/* del propio panel (que guardan la cookie httpOnly) y,
 * para elegir negocio, directo con la API usando el token de acceso.
 */
export class RepositorioSesionBff implements RepositorioSesion {
  constructor(
    private readonly api: ClienteVeci,
    private readonly ahora: () => number = Date.now,
  ) {}

  entrarConPin(celular: string, pin: string): Promise<ResultadoIngreso> {
    return this.ingreso('con-pin', { celular, pin });
  }

  entrarConContrasena(correo: string, contrasena: string): Promise<ResultadoIngreso> {
    return this.ingreso('con-contrasena', { correo, contrasena });
  }

  async crearPinNuevo(tokenCambio: string, pinNuevo: string): Promise<SesionActiva> {
    const r = await this.ingreso('pin-nuevo', { tokenCambio, pinNuevo });
    if (r.tipo !== 'sesion') throw comoError(undefined);
    return r.sesion;
  }

  async renovar(): Promise<SesionActiva | null> {
    const respuesta = await this.llamar('renovar', {});
    if (respuesta.status === 401) return null;
    const cuerpo = (await respuesta.json()) as RespuestaIngreso;
    if (!respuesta.ok || cuerpo.tipo !== 'sesion') throw comoError(cuerpo);
    return aSesion(cuerpo.sesion, this.ahora());
  }

  async elegirComercio(tokenAcceso: string, comercioId: string): Promise<void> {
    const { error } = await this.api.POST('/cuenta/comercio-activo', {
      headers: { authorization: `Bearer ${tokenAcceso}` },
      body: { comercioId },
    });
    if (error) throw comoError(error);
  }

  async salir(tokenAcceso: string | null): Promise<void> {
    const headers: Record<string, string> = tokenAcceso
      ? { authorization: `Bearer ${tokenAcceso}` }
      : {};
    await this.llamar('salir', {}, headers);
  }

  private async ingreso(accion: string, cuerpo: object): Promise<ResultadoIngreso> {
    const respuesta = await this.llamar(accion, cuerpo);
    const datos = (await respuesta.json().catch(() => undefined)) as RespuestaIngreso | undefined;
    if (!respuesta.ok || !datos) throw comoError(datos);
    if (datos.tipo === 'cambio-de-pin') return datos;
    return { tipo: 'sesion', sesion: aSesion(datos.sesion, this.ahora()) };
  }

  private async llamar(accion: string, cuerpo: object, headers: Record<string, string> = {}) {
    try {
      return await fetch(`/api/sesion/${accion}`, {
        method: 'POST',
        headers: { 'content-type': 'application/json', ...headers },
        body: JSON.stringify(cuerpo),
        credentials: 'same-origin',
      });
    } catch {
      const { codigo, mensaje } = problemaSinConexion();
      throw new ErrorDeSesion(codigo, mensaje);
    }
  }
}
