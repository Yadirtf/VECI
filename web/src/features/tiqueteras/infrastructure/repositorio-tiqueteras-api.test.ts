import { describe, expect, it, vi } from 'vitest';
import { crearClienteVeci } from '@/shared/api/cliente';
import { ProblemaTiqueteras } from '../domain/tiquetera';
import { CuentasApi, PizarraApi } from './repositorio-tiqueteras-api';

const json = (cuerpo: unknown, status = 200) =>
  new Response(JSON.stringify(cuerpo), { status, headers: { 'content-type': 'application/json' } });

const almuerzo = { codigo: 'LUNCH', singular: 'almuerzo', plural: 'almuerzos' };
const tipoApi = {
  tipoId: 't1',
  nombre: '20 almuerzos',
  unidad: almuerzo,
  unidades: 20,
  precio: 220000,
  precioPorUnidad: 11000,
  vigenciaDias: 30,
  estado: 'ACTIVE',
  vendidas: 0,
  vigentes: 0,
};
const cuentaApi = {
  clienteId: 'c1',
  saldos: [
    {
      unidad: almuerzo,
      disponibles: 20,
      proximoVencimiento: '2026-11-07T05:00:00Z',
      ultimoDia: '2026-11-06',
      tiqueteras: 1,
    },
  ],
  tiqueteras: [
    {
      tiqueteraId: 'q1',
      clienteId: 'c1',
      ventaId: 'v1',
      tipoId: 't1',
      nombre: '20 almuerzos',
      unidad: almuerzo,
      compradas: 20,
      saldo: 20,
      estado: 'ACTIVE',
      compradaEn: '2026-10-08T15:00:00Z',
      venceEn: '2026-11-07T05:00:00Z',
      ultimoDia: '2026-11-06',
      vigente: true,
      turno: 1,
      precio: 220000,
    },
  ],
  movimientos: [
    {
      eventoId: 'e1',
      tipo: 'SALE',
      ocurridoEn: '2026-10-08T15:00:00Z',
      unidades: 20,
      tiquetera: '20 almuerzos',
      motivo: null,
      nota: null,
      quien: 'Ana',
      corrigeA: null,
    },
  ],
};

function preparar(respuesta: (r: Request) => Response) {
  const peticiones: Request[] = [];
  const fetch = vi.fn(async (entrada: RequestInfo | URL, init?: RequestInit) => {
    const peticion = new Request(entrada, init);
    peticiones.push(peticion);
    return respuesta(peticion);
  });
  const cliente = crearClienteVeci({ urlBase: 'http://api', fetch });
  return {
    pizarra: new PizarraApi(cliente, 'neg-1'),
    cuentas: new CuentasApi(cliente, 'neg-1'),
    peticiones,
  };
}

describe('PizarraApi', () => {
  it('lista, crea, cambia y desactiva con el negocio en la cabecera', async () => {
    const { pizarra, peticiones } = preparar((r) =>
      r.url.endsWith('/unidades')
        ? json([almuerzo])
        : r.method === 'GET'
          ? json([tipoApi])
          : json(tipoApi),
    );
    expect(await pizarra.tipos()).toEqual([tipoApi]);
    expect(await pizarra.unidades()).toEqual([almuerzo]);
    const datos = {
      nombre: '20 almuerzos',
      unidad: 'LUNCH',
      unidades: 20,
      precio: 220000,
      vigenciaDias: 30,
    };
    await pizarra.crear(datos);
    await pizarra.editar('t1', datos);
    await pizarra.cambiarEstado('t1', false);
    expect(peticiones.map((p) => `${p.method} ${p.url}`)).toEqual([
      'GET http://api/tiqueteras/tipos',
      'GET http://api/tiqueteras/unidades',
      'POST http://api/tiqueteras/tipos',
      'PATCH http://api/tiqueteras/tipos/t1',
      'PATCH http://api/tiqueteras/tipos/t1/estado',
    ]);
    expect(peticiones.every((p) => p.headers.get('x-veci-comercio') === 'neg-1')).toBe(true);
    expect(await peticiones[4].json()).toEqual({ activo: false });
  });

  it('cuando la API dice que no, entrega su código y su mensaje', async () => {
    const { pizarra } = preparar(() =>
      json({ codigo: 'NOMBRE_REPETIDO', message: 'Ya tienes una.' }, 409),
    );
    const error = await pizarra.tipos().catch((e: unknown) => e);
    expect(error).toBeInstanceOf(ProblemaTiqueteras);
    expect(error).toMatchObject({ codigo: 'NOMBRE_REPETIDO', message: 'Ya tienes una.' });
  });
});

describe('CuentasApi', () => {
  it('vende con el id del panel y vuelve a traer la cuenta con su historia', async () => {
    const { cuentas, peticiones } = preparar((r) =>
      r.method === 'POST'
        ? json({ ...cuentaApi, ventaId: 'v1', repetida: false, origen: 'ONLINE' })
        : json(cuentaApi),
    );
    const cuenta = await cuentas.vender({
      ventaId: 'v1',
      clienteId: 'c1',
      tipoId: 't1',
      precio: 220000,
      pago: { medio: 'CASH', canal: null, referencia: null },
    });
    expect(await peticiones[0].json()).toEqual({
      ventaId: 'v1',
      clienteId: 'c1',
      tipoId: 't1',
      precio: 220000,
      sinConexion: false,
      pago: { medio: 'CASH' },
    });
    expect(peticiones[1].url).toBe('http://api/tiqueteras/cliente/c1');
    expect(cuenta.tiqueteras[0].compradaEn).toEqual(new Date('2026-10-08T15:00:00Z'));
    expect(cuenta.movimientos[0]).toMatchObject({ tipo: 'SALE', quien: 'Ana' });
  });

  it('trae catálogo, ventas y motivos; anula y ajusta con motivo', async () => {
    const venta = {
      ventaId: 'v1',
      clienteId: 'c1',
      cliente: 'Luz',
      tiquetera: '20 almuerzos',
      precio: 220000,
      pago: { medio: 'BANK_TRANSFER', canal: 'NEQUI', referencia: null },
      ocurridaEn: '2026-10-08T15:00:00Z',
      origen: 'OFFLINE_SYNC',
      estado: 'VOIDED',
      cajero: null,
      saldo: 0,
    };
    const { cuentas, peticiones } = preparar((r) => {
      if (r.url.endsWith('/catalogo')) return json({ version: '1', tipos: [tipoApi], medios: [] });
      if (r.url.endsWith('/motivos')) return json([{ codigo: 'OTHER', nombre: 'Otro' }]);
      if (r.method === 'GET') return json([venta]);
      return json(cuentaApi);
    });
    expect((await cuentas.catalogo()).tipos).toHaveLength(1);
    expect(await cuentas.ventas()).toEqual([
      expect.objectContaining({
        sinConexion: true,
        anulada: true,
        cajero: null,
        ocurridaEn: new Date('2026-10-08T15:00:00Z'),
      }),
    ]);
    expect(await cuentas.motivos()).toEqual([{ codigo: 'OTHER', nombre: 'Otro' }]);
    await cuentas.anular('v1', { motivo: 'OTHER', nota: ' doble ' });
    await cuentas.ajustar('q1', -2, { motivo: 'COURTESY', nota: null });
    expect(await peticiones[3].json()).toEqual({ motivo: 'OTHER', nota: 'doble' });
    expect(peticiones[4].url).toBe('http://api/tiqueteras/q1/ajustes');
    expect(await peticiones[4].json()).toEqual({ unidades: -2, motivo: 'COURTESY' });
  });
});
