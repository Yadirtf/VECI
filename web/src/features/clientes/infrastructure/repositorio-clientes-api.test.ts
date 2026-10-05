import { describe, expect, it, vi } from 'vitest';
import { crearClienteVeci } from '@/shared/api/cliente';
import { ProblemaClientes } from '../domain/cliente';
import { PoliticaApi, RepositorioClientesApi } from './repositorio-clientes-api';

const json = (cuerpo: unknown, status = 200) =>
  new Response(JSON.stringify(cuerpo), {
    status,
    headers: { 'content-type': 'application/json' },
  });

const fichaApi = {
  clienteId: 'c1',
  personaId: 'p1',
  nombre: 'Luz Marina Chindoy',
  nombres: 'Luz Marina',
  apellidos: null,
  tipoDocumento: 'CC',
  documento: '1124505678',
  celular: '+573157778888',
  datosCompletos: true,
  cuenta: 'PENDIENTE',
  estado: 'ACTIVE',
  canal: 'ASSISTED_REGISTRATION',
  afiliadoEn: '2026-10-04T15:00:00Z',
};

function preparar(respuesta: (r: Request) => Response) {
  const peticiones: Request[] = [];
  const fetch = vi.fn(async (entrada: RequestInfo | URL, init?: RequestInit) => {
    const peticion = new Request(entrada, init);
    peticiones.push(peticion);
    return respuesta(peticion);
  });
  const cliente = crearClienteVeci({ urlBase: 'http://api', fetch });
  return { repo: new RepositorioClientesApi(cliente, 'neg-1'), cliente, peticiones };
}

describe('RepositorioClientesApi', () => {
  it('baja la libreta con el negocio activo en la cabecera', async () => {
    const { repo, peticiones } = preparar(() =>
      json({
        version: '1',
        claves: [],
        clientes: [
          {
            ...fichaApi,
            documento: '****5678',
            documentoFinal: '5678',
            nombreBusqueda: 'luz marina chindoy',
          },
        ],
      }),
    );
    const [luz] = await repo.libreta();
    expect(luz).toMatchObject({ clienteId: 'c1', celular: '+573157778888', celularFinal: null });
    expect(peticiones[0].url).toBe('http://api/clientes/copia-local');
    expect(peticiones[0].headers.get('x-veci-comercio')).toBe('neg-1');
  });

  it('lo que encuentra el servidor llega tapado a la libreta', async () => {
    const { repo, peticiones } = preparar(() => json([fichaApi]));
    const [luz] = await repo.buscar('1124505678');
    expect(peticiones[0].url).toBe('http://api/clientes?q=1124505678');
    expect(luz).toMatchObject({ documento: '****5678', celular: '••• 8888' });
  });

  it('trae la ficha con la fecha y da el PIN de bienvenida', async () => {
    const { repo } = preparar((r) =>
      r.url.endsWith('/pin-bienvenida') ? json({ pinBienvenida: '482915' }) : json(fichaApi),
    );
    const ficha = await repo.ficha('c1');
    expect(ficha.afiliadoEn).toEqual(new Date('2026-10-04T15:00:00Z'));
    expect(ficha.apellidos).toBeNull();
    expect(await repo.darPinBienvenida('c1')).toBe('482915');
  });

  it('revisa el documento y registra', async () => {
    const { repo } = preparar((r) => {
      if (r.url.endsWith('/revisar')) return json({ persona: null });
      if (r.url.endsWith('/tipos-documento')) return json([{ codigo: 'CC', nombre: 'Cédula' }]);
      return json({ vinculado: false, cliente: fichaApi, pinBienvenida: null }, 201);
    });
    expect(await repo.revisar({ tipoDocumento: 'CC', numeroDocumento: '1' })).toBeNull();
    expect(await repo.tiposDocumento()).toEqual([{ codigo: 'CC', nombre: 'Cédula', patron: null }]);
    const r = await repo.registrar({
      tipoDocumento: 'CC',
      numeroDocumento: '1124505678',
      celularCompartido: false,
      politicaVersionId: 'pol-1',
    });
    expect(r).toMatchObject({ vinculado: false, pinBienvenida: null });
  });

  it('cuando la API dice que no, entrega su código y su mensaje', async () => {
    const { repo } = preparar(() =>
      json({ codigo: 'CELULAR_EN_USO', message: 'Ese celular ya es de otra persona.' }, 409),
    );
    const error = await repo
      .registrar({
        tipoDocumento: 'CC',
        numeroDocumento: '1',
        celularCompartido: false,
        politicaVersionId: 'pol-1',
      })
      .catch((e: unknown) => e);
    expect(error).toBeInstanceOf(ProblemaClientes);
    expect(error).toMatchObject({
      codigo: 'CELULAR_EN_USO',
      message: 'Ese celular ya es de otra persona.',
    });
  });

  it('la política se lee sin sesión', async () => {
    const { cliente } = preparar(() =>
      json({
        id: 'pol-1',
        version: '1.0',
        huella: 'x',
        publicadaEn: '2026-10-04T15:00:00Z',
        enCorto: { anotamos: [], nuncaHacemos: [], paraQue: 'Para tu tiquetera.' },
        secciones: [],
      }),
    );
    const politica = await new PoliticaApi(cliente).politica();
    expect(politica.publicadaEn).toEqual(new Date('2026-10-04T15:00:00Z'));
  });
});
