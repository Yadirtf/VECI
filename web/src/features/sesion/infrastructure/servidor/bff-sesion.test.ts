// @vitest-environment node
import { describe, expect, it, vi } from 'vitest';
import { BffSesion, type PeticionBff } from './bff-sesion';
import { nombreDelNavegador } from './cookies-sesion';

const sesionApi = {
  tokenAcceso: 'acceso',
  tokenRenovacion: 'sid.secreto',
  segundosAcceso: 900,
  usuario: { id: 'u1', nombre: 'Marta' },
  espacios: [],
};

const json = (estado: number, cuerpo: unknown) =>
  new Response(JSON.stringify(cuerpo), {
    status: estado,
    headers: { 'content-type': 'application/json' },
  });

function preparar(respuesta: Response) {
  const fetch = vi.fn<(peticion: Request) => Promise<Response>>(async () => respuesta);
  const bff = new BffSesion({ urlApi: 'http://api', diasSesion: 30, fetch: fetch as never });
  return { fetch, bff };
}

const peticion = (accion: string, extra: Partial<PeticionBff> = {}): PeticionBff => ({
  accion,
  cuerpo: { celular: '3100000101', pin: '246813' },
  renovacion: undefined,
  dispositivoId: undefined,
  agente: 'Mozilla/5.0 (Windows NT 10.0) Chrome/140.0',
  autorizacion: null,
  ...extra,
});

describe('BffSesion', () => {
  it('al entrar guarda la renovación en una cookie httpOnly y no la devuelve', async () => {
    const { bff, fetch } = preparar(json(200, { requiereCambioDePin: false, sesion: sesionApi }));
    const r = await bff.atender(peticion('con-pin'));
    expect(r.cuerpo).toEqual({
      tipo: 'sesion',
      sesion: expect.not.objectContaining({ tokenRenovacion: expect.anything() }),
    });
    const renovacion = r.cookies.find((c) => c.nombre === 'veci_renovacion');
    expect(renovacion).toMatchObject({ valor: 'sid.secreto', httpOnly: true, path: '/api/sesion' });
    expect(r.cookies.some((c) => c.nombre === 'veci_dispositivo')).toBe(true);
    const enviado = await (fetch.mock.calls[0][0] as Request).json();
    expect(enviado.dispositivo).toMatchObject({ plataforma: 'WEB', modelo: 'Chrome en Windows' });
  });

  it('con PIN temporal entrega el token de cambio, sin cookie de sesión', async () => {
    const { bff } = preparar(
      json(200, { requiereCambioDePin: true, tokenCambio: 'tc', nombre: 'Jhon' }),
    );
    const r = await bff.atender(peticion('con-pin', { dispositivoId: 'd1' }));
    expect(r.cuerpo).toEqual({ tipo: 'cambio-de-pin', tokenCambio: 'tc', nombre: 'Jhon' });
    expect(r.cookies).toEqual([]);
  });

  it('renovar sin cookie responde que no hay sesión, sin llamar a la API', async () => {
    const { bff, fetch } = preparar(json(200, sesionApi));
    const r = await bff.atender(peticion('renovar'));
    expect(r.estado).toBe(401);
    expect(fetch).not.toHaveBeenCalled();
  });

  it('si la API cierra la sesión al renovar, borra la cookie', async () => {
    const { bff } = preparar(json(401, { codigo: 'SESION_CERRADA', message: 'x' }));
    const r = await bff.atender(peticion('renovar', { renovacion: 'viejo', dispositivoId: 'd1' }));
    expect(r.estado).toBe(401);
    expect(r.cookies[0]).toMatchObject({ nombre: 'veci_renovacion', maxAge: 0 });
  });

  it('salir avisa a la API y borra la cookie', async () => {
    const { bff, fetch } = preparar(new Response(null, { status: 204 }));
    const r = await bff.atender(peticion('salir', { autorizacion: 'Bearer acceso' }));
    expect(r.estado).toBe(204);
    expect((fetch.mock.calls[0][0] as Request).headers.get('authorization')).toBe('Bearer acceso');
  });

  it('rechaza acciones que no existen', async () => {
    const { bff } = preparar(json(200, {}));
    expect((await bff.atender(peticion('otra'))).estado).toBe(404);
  });

  it('pone nombre amable al navegador', () => {
    expect(nombreDelNavegador('Mozilla/5.0 (Linux; Android 13) Chrome/140 Mobile Safari/537')).toBe(
      'Chrome en Android',
    );
    expect(nombreDelNavegador(null)).toBe('Navegador');
  });
});
