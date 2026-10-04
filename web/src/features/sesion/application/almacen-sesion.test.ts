import { describe, expect, it, vi } from 'vitest';
import type { PreferenciasSesion, RepositorioSesion, SesionActiva } from '../domain/sesion';
import { AlmacenSesion } from './almacen-sesion';

const sesion = (token: string, venceEn = 1_000_000): SesionActiva => ({
  tokenAcceso: token,
  venceEn,
  usuario: { id: 'u1', nombre: 'Marta' },
  espacios: [
    {
      comercioId: 'c1',
      nombre: 'La Vecina',
      tipoNegocio: 'RESTAURANT',
      roles: ['OWNER'],
      invitacionPendiente: false,
    },
  ],
});

function preparar(ahora = 0) {
  const repositorio: RepositorioSesion = {
    entrarConPin: vi.fn(async () => ({ tipo: 'sesion' as const, sesion: sesion('t1') })),
    entrarConContrasena: vi.fn(),
    crearPinNuevo: vi.fn(async () => sesion('t-nuevo')),
    renovar: vi.fn(async () => sesion('t2', ahora + 900_000)),
    elegirComercio: vi.fn(async () => undefined),
    salir: vi.fn(async () => undefined),
  };
  let guardado: string | null = null;
  const preferencias: PreferenciasSesion = {
    comercioGuardado: () => guardado,
    guardarComercio: (id) => {
      guardado = id;
    },
  };
  return { repositorio, almacen: new AlmacenSesion(repositorio, preferencias, () => ahora) };
}

describe('AlmacenSesion', () => {
  it('sin cookie de renovación queda sin sesión', async () => {
    const { repositorio, almacen } = preparar();
    vi.mocked(repositorio.renovar).mockResolvedValueOnce(null);
    await almacen.iniciar();
    expect(almacen.estado()).toEqual({ fase: 'sin-sesion' });
  });

  it('al entrar con su único negocio, lo deja elegido', async () => {
    const { almacen } = preparar();
    await almacen.entrarConPin('3100000101', '246813');
    expect(almacen.estado()).toMatchObject({ fase: 'activa', comercioId: 'c1' });
  });

  it('con PIN temporal pide crear el propio antes de abrir la sesión', async () => {
    const { repositorio, almacen } = preparar();
    vi.mocked(repositorio.entrarConPin).mockResolvedValueOnce({
      tipo: 'cambio-de-pin',
      tokenCambio: 'tc',
      nombre: 'Jhon',
    });
    await almacen.entrarConPin('3100000102', '482915');
    expect(almacen.estado()).toMatchObject({ fase: 'cambio-de-pin', nombre: 'Jhon' });
    await almacen.crearPinNuevo('730284');
    expect(repositorio.crearPinNuevo).toHaveBeenCalledWith('tc', '730284');
    expect(almacen.estado()).toMatchObject({ fase: 'activa' });
  });

  it('renueva una sola vez aunque varias peticiones encuentren el token vencido', async () => {
    const { repositorio, almacen } = preparar(10_000);
    vi.mocked(repositorio.entrarConPin).mockResolvedValueOnce({
      tipo: 'sesion',
      sesion: sesion('viejo', 20_000),
    });
    await almacen.entrarConPin('3100000101', '246813');
    const tokens = await Promise.all([almacen.tokenVigente(), almacen.tokenVigente()]);
    expect(tokens).toEqual(['t2', 't2']);
    expect(repositorio.renovar).toHaveBeenCalledTimes(1);
  });

  it('si la sesión se cerró en otro lado, vuelve a pedir el ingreso', async () => {
    const { repositorio, almacen } = preparar();
    await almacen.entrarConPin('3100000101', '246813');
    vi.mocked(repositorio.renovar).mockRejectedValueOnce(new Error('SESION_CERRADA'));
    await expect(almacen.renovar()).resolves.toBeNull();
    expect(almacen.estado()).toEqual({ fase: 'sin-sesion' });
  });

  it('salir cierra la sesión y olvida el negocio', async () => {
    const { repositorio, almacen } = preparar();
    await almacen.entrarConPin('3100000101', '246813');
    await almacen.salir();
    expect(repositorio.salir).toHaveBeenCalledWith('t1');
    expect(almacen.estado()).toEqual({ fase: 'sin-sesion' });
  });

  it('avisa a quien escucha cada cambio', async () => {
    const { almacen } = preparar();
    const oyente = vi.fn();
    const soltar = almacen.suscribir(oyente);
    await almacen.entrarConPin('3100000101', '246813');
    almacen.cambiarDeNegocio();
    soltar();
    expect(oyente).toHaveBeenCalledTimes(2);
    expect(almacen.estado()).toMatchObject({ comercioId: null });
  });
});
