import { describe, expect, it, vi } from 'vitest';
import { fetchConSesion } from './cliente';
import { leerProblema } from './problema';

describe('fetchConSesion', () => {
  it('pone el token y, si venció, renueva una vez y repite', async () => {
    const base = vi
      .fn<typeof fetch>()
      .mockResolvedValueOnce(new Response(null, { status: 401 }))
      .mockResolvedValueOnce(new Response('{}', { status: 200 }));
    const sesion = {
      tokenVigente: vi.fn(async () => 'viejo'),
      renovar: vi.fn(async () => 'nuevo'),
    };
    const respuesta = await fetchConSesion(sesion, base)('http://api/horarios', { method: 'GET' });
    expect(respuesta.status).toBe(200);
    const tokens = base.mock.calls.map(([p]) => (p as Request).headers.get('authorization'));
    expect(tokens).toEqual(['Bearer viejo', 'Bearer nuevo']);
  });

  it('si no se puede renovar, devuelve el 401 original', async () => {
    const base = vi.fn<typeof fetch>().mockResolvedValue(new Response(null, { status: 401 }));
    const sesion = { tokenVigente: async () => 'viejo', renovar: async () => null };
    const respuesta = await fetchConSesion(sesion, base)('http://api/horarios');
    expect(respuesta.status).toBe(401);
    expect(base).toHaveBeenCalledTimes(1);
  });
});

describe('leerProblema', () => {
  it('lee el código y el mensaje de la API', () => {
    expect(leerProblema({ codigo: 'X', message: 'Hola' })).toEqual({
      codigo: 'X',
      mensaje: 'Hola',
    });
    expect(leerProblema({ message: ['a', 'b'] })).toEqual({
      codigo: 'DATOS_INVALIDOS',
      mensaje: 'a b',
    });
    expect(leerProblema(undefined).codigo).toBe('INESPERADO');
  });
});
