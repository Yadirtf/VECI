import { fireEvent, render, screen, waitFor, within } from '@testing-library/react';
import { vi } from 'vitest';
import {
  ProblemaClientes,
  type ClienteEnLibreta,
  type FichaCliente,
  type RepositorioClientes,
} from '../domain/cliente';
import { PantallaClientes } from './pantalla-clientes';

const renglon = (
  clienteId: string,
  nombre: string,
  documentoFinal: string,
  cuenta: ClienteEnLibreta['cuenta'],
): ClienteEnLibreta => ({
  clienteId,
  nombre,
  nombreBusqueda: nombre.toLowerCase(),
  documento: `****${documentoFinal}`,
  documentoFinal,
  celular: null,
  celularFinal: null,
  cuenta,
  estado: 'ACTIVE',
});

const luz = renglon('c1', 'Luz Marina Chindoy', '5678', 'PENDIENTE');
const jose = renglon('c2', 'Jose Munoz', '1234', 'ACTIVA');
const ana = renglon('c3', 'Ana Jamioy', '9012', 'SIN_CUENTA');

const ficha = (cambios: Partial<FichaCliente> = {}): FichaCliente => ({
  clienteId: 'c1',
  personaId: 'p1',
  nombre: 'Luz Marina Chindoy',
  nombres: 'Luz Marina',
  apellidos: 'Chindoy',
  tipoDocumento: 'CC',
  documento: '1124505678',
  celular: '+573157778888',
  datosCompletos: true,
  cuenta: 'PENDIENTE',
  estado: 'ACTIVE',
  canal: 'ASSISTED_REGISTRATION',
  afiliadoEn: new Date('2026-10-04T15:00:00Z'),
  ...cambios,
});

const politica = {
  id: 'pol-1',
  version: '1.0',
  publicadaEn: new Date('2026-10-04T15:00:00Z'),
  enCorto: {
    anotamos: ['Tu nombre', 'Tu celular'],
    nuncaHacemos: ['Vender ni prestar tus datos'],
    paraQue: 'Para saber cuántos almuerzos te quedan.',
  },
  secciones: [],
};

function repositorio(cambios: Partial<RepositorioClientes> = {}): RepositorioClientes {
  return {
    libreta: vi.fn(async () => [luz, jose]),
    buscar: vi.fn(async () => []),
    ficha: vi.fn(async () => ficha()),
    darPinBienvenida: vi.fn(async () => '482915'),
    politica: vi.fn(async () => politica),
    tiposDocumento: vi.fn(async () => [
      { codigo: 'CC', nombre: 'Cédula de ciudadanía', patron: '^[0-9]{6,10}$' },
    ]),
    revisar: vi.fn(async () => null),
    registrar: vi.fn(async () => ({
      vinculado: false,
      cliente: ficha({ clienteId: 'c3', nombre: 'Ana Jamioy', nombres: 'Ana' }),
      pinBienvenida: '730284',
    })),
    ...cambios,
  };
}

const libreta = () => screen.findByRole('list', { name: 'Clientes' });
const nombresEn = (lista: HTMLElement) =>
  within(lista)
    .getAllByRole('button')
    .map((b) => b.querySelector('span')?.textContent);
const escribir = (etiqueta: string | RegExp, valor: string) =>
  fireEvent.change(screen.getByLabelText(etiqueta), { target: { value: valor } });

describe('PantallaClientes · libreta', () => {
  it('filtra al escribir y con "Sin app aún"', async () => {
    render(<PantallaClientes repositorio={repositorio()} />);
    expect(nombresEn(await libreta())).toEqual(['Jose Munoz', 'Luz Marina Chindoy']);
    expect(screen.getByText('2 clientes · 1 sin app aún')).toBeInTheDocument();
    escribir(/Buscar por nombre/, 'luz');
    expect(nombresEn(await libreta())).toEqual(['Luz Marina Chindoy']);
    escribir(/Buscar por nombre/, '');
    fireEvent.click(screen.getByRole('button', { name: 'Sin app aún' }));
    expect(nombresEn(await libreta())).toEqual(['Luz Marina Chindoy']);
  });

  it('desde 3 caracteres también busca en el servidor (documento completo)', async () => {
    const repo = repositorio({ buscar: vi.fn(async () => [ana]) });
    render(<PantallaClientes repositorio={repo} />);
    await libreta();
    escribir(/Buscar por nombre/, '1124509012');
    expect(await screen.findByText('Ana Jamioy')).toBeInTheDocument();
    expect(repo.buscar).toHaveBeenCalledWith('1124509012');
  });

  it('sin resultados ofrece registrar con lo escrito', async () => {
    const repo = repositorio();
    render(<PantallaClientes repositorio={repo} />);
    await libreta();
    escribir(/Buscar por nombre/, '1124500777');
    fireEvent.click(await screen.findByRole('button', { name: 'Registrar a «1124500777»' }));
    expect(await screen.findByLabelText('Número de documento')).toHaveValue('1124500777');
  });

  it('dice el error de la API si no trae la libreta', async () => {
    const libretaQueFalla = vi.fn(async () => {
      throw new Error('No pudimos conectarnos. Revisa el internet e intenta otra vez.');
    });
    render(<PantallaClientes repositorio={repositorio({ libreta: libretaQueFalla })} />);
    expect(await screen.findByRole('alert')).toHaveTextContent(/No pudimos conectarnos/);
  });
});

describe('PantallaClientes · ficha', () => {
  it('el dueño ve todo y la leyenda explica que la caja lo ve tapado', async () => {
    render(<PantallaClientes repositorio={repositorio()} />);
    fireEvent.click(await screen.findByText('Luz Marina Chindoy'));
    const f = await screen.findByRole('region', { name: 'Ficha de Luz Marina Chindoy' });
    expect(f).toHaveTextContent('CC 1124505678');
    expect(f).toHaveTextContent('315 777 8888');
    expect(f).toHaveTextContent('4 de octubre de 2026');
    expect(f).toHaveTextContent(/tu equipo los ve tapados, así: \*\*\*\*5678/);
  });

  it('quien no es dueño ve los datos tapados', async () => {
    const tapada = ficha({ documento: '****5678', celular: '••• 8888', datosCompletos: false });
    render(<PantallaClientes repositorio={repositorio({ ficha: vi.fn(async () => tapada) })} />);
    fireEvent.click(await screen.findByText('Luz Marina Chindoy'));
    const f = await screen.findByRole('region', { name: 'Ficha de Luz Marina Chindoy' });
    expect(f).toHaveTextContent('CC ****5678');
    expect(f).toHaveTextContent('se ven tapados para cuidar a tus clientes');
  });

  it('da el PIN de bienvenida a quien aún no activa su app', async () => {
    const repo = repositorio();
    render(<PantallaClientes repositorio={repo} />);
    fireEvent.click(await screen.findByText('Luz Marina Chindoy'));
    fireEvent.click(await screen.findByRole('button', { name: 'Dar PIN de bienvenida' }));
    const pin = await screen.findByRole('status', { name: 'PIN de bienvenida' });
    expect(pin).toHaveTextContent('482915');
    expect(pin).toHaveTextContent('Sirve 7 días. Con su celular y este PIN activa su app.');
    expect(repo.darPinBienvenida).toHaveBeenCalledWith('c1');
  });

  it('a quien ya usa la app no se le ofrece PIN', async () => {
    const activa = ficha({ cuenta: 'ACTIVA' });
    render(<PantallaClientes repositorio={repositorio({ ficha: vi.fn(async () => activa) })} />);
    fireEvent.click(await screen.findByText('Luz Marina Chindoy'));
    await screen.findByRole('region', { name: 'Ficha de Luz Marina Chindoy' });
    expect(screen.queryByRole('button', { name: 'Dar PIN de bienvenida' })).toBeNull();
  });
});

const revisarDocumento = async (numero: string) => {
  fireEvent.click(screen.getByRole('button', { name: 'Registrar cliente' }));
  fireEvent.change(await screen.findByLabelText('Número de documento'), {
    target: { value: numero },
  });
  fireEvent.click(screen.getByRole('button', { name: 'Revisar documento' }));
};

const anotarPersona = async () => {
  escribir('Nombres', 'Ana');
  escribir('Celular', '315 777 8888');
  fireEvent.click(screen.getByRole('button', { name: 'Sí aceptó · Registrar' }));
};

describe('PantallaClientes · registro asistido', () => {
  it('registra a una persona nueva, dicta el PIN y la deja elegida', async () => {
    const repo = repositorio();
    render(<PantallaClientes repositorio={repo} />);
    await libreta();
    await revisarDocumento('1124509012');
    await screen.findByText('Es nueva en VECI. Anota sus datos.');
    expect(screen.getByRole('region', { name: 'Léele esto en voz alta' })).toHaveTextContent(
      'Vender ni prestar tus datos',
    );
    await anotarPersona();
    const pin = await screen.findByRole('status', { name: 'PIN de bienvenida' });
    expect(pin).toHaveTextContent('730284');
    expect(repo.registrar).toHaveBeenCalledWith({
      tipoDocumento: 'CC',
      numeroDocumento: '1124509012',
      nombres: 'Ana',
      apellidos: undefined,
      celular: '315 777 8888',
      celularCompartido: false,
      politicaVersionId: 'pol-1',
    });
    expect(await screen.findByText('¡Listo, veci! Ana quedó en tu libreta.')).toBeInTheDocument();
    expect(repo.ficha).toHaveBeenCalledWith('c3');
    expect(repo.libreta).toHaveBeenCalledTimes(2);
  });

  it('si el celular ya es de otra persona, lo deja como celular de la familia', async () => {
    const mensaje = 'Ese celular ya es de otra persona en VECI. ¿Es el de la familia?';
    const registrar = vi
      .fn<RepositorioClientes['registrar']>()
      .mockRejectedValueOnce(new ProblemaClientes('CELULAR_EN_USO', mensaje))
      .mockResolvedValueOnce({ vinculado: false, cliente: ficha(), pinBienvenida: null });
    render(<PantallaClientes repositorio={repositorio({ registrar })} />);
    await libreta();
    await revisarDocumento('1124509012');
    await screen.findByText('Es nueva en VECI. Anota sus datos.');
    await anotarPersona();
    expect(await screen.findByRole('alert')).toHaveTextContent(mensaje);
    fireEvent.click(screen.getByRole('button', { name: 'Es el celular compartido de la familia' }));
    await waitFor(() =>
      expect(registrar).toHaveBeenLastCalledWith(
        expect.objectContaining({ celular: '315 777 8888', celularCompartido: true }),
      ),
    );
    expect(await screen.findByText(/Luz Marina quedó en tu libreta/)).toBeInTheDocument();
    expect(screen.queryByRole('status', { name: 'PIN de bienvenida' })).toBeNull();
  });

  it('si ya está en VECI, muestra su nombre tapado y la afilia', async () => {
    const persona = { personaId: 'p9', nombre: 'Rosa M.', documento: '****4321', clienteId: null };
    const repo = repositorio({ revisar: vi.fn(async () => persona) });
    render(<PantallaClientes repositorio={repo} />);
    await libreta();
    await revisarDocumento('1087654321');
    expect(await screen.findByText('Rosa M.')).toBeInTheDocument();
    expect(screen.getByText(/Documento \*\*\*\*4321/)).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: 'Afiliar a esta persona' }));
    await waitFor(() =>
      expect(repo.registrar).toHaveBeenCalledWith({
        tipoDocumento: 'CC',
        numeroDocumento: '1087654321',
        celularCompartido: false,
        politicaVersionId: 'pol-1',
      }),
    );
  });

  it('si ya es cliente, abre su ficha; y no revisa un número que no sirve', async () => {
    const persona = { personaId: 'p1', nombre: 'Luz M.', documento: '****5678', clienteId: 'c1' };
    const repo = repositorio({ revisar: vi.fn(async () => persona) });
    render(<PantallaClientes repositorio={repo} />);
    await libreta();
    await revisarDocumento('12');
    expect(await screen.findByText(/no parece de cédula/)).toBeInTheDocument();
    expect(repo.revisar).not.toHaveBeenCalled();
    escribir('Número de documento', '1124505678');
    fireEvent.click(screen.getByRole('button', { name: 'Revisar documento' }));
    fireEvent.click(await screen.findByRole('button', { name: 'Ver su ficha' }));
    expect(await screen.findByRole('region', { name: /Ficha de/ })).toBeInTheDocument();
    expect(repo.ficha).toHaveBeenCalledWith('c1');
  });
});
