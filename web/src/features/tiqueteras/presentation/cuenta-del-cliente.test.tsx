import { fireEvent, render, screen, within } from '@testing-library/react';
import { vi } from 'vitest';
import { ProblemaTiqueteras, type RepositorioCuentas } from '../domain/tiquetera';
import { cuenta, tipo, tiquetera } from '../pruebas';
import { CuentaDelCliente } from './cuenta-del-cliente';

const transferencia = {
  codigo: 'BANK_TRANSFER',
  nombre: 'Transferencia',
  necesitaCanal: true,
  canales: [{ codigo: 'NEQUI', nombre: 'Nequi' }],
};

function repositorio(cambios: Partial<RepositorioCuentas> = {}): RepositorioCuentas {
  return {
    catalogo: vi.fn(async () => ({ tipos: [tipo()], medios: [transferencia] })),
    cuenta: vi.fn(async () => cuenta()),
    vender: vi.fn(async () => cuenta({ saldos: [] })),
    ventas: vi.fn(),
    motivos: vi.fn(async () => [{ codigo: 'COURTESY', nombre: 'Cortesía' }]),
    anular: vi.fn(),
    ajustar: vi.fn(async () => cuenta()),
    ...cambios,
  };
}

let n = 0;
const nuevoId = () => `venta-${++n}`;

describe('CuentaDelCliente', () => {
  beforeEach(() => {
    n = 0;
  });

  it('muestra el saldo, la que se gasta primero y la historia', async () => {
    render(<CuentaDelCliente repositorio={repositorio()} clienteId="c1" nuevoId={nuevoId} />);
    expect(await screen.findByRole('img', { name: 'Saldo: 14 almuerzos' })).toBeInTheDocument();
    expect(screen.getByText(/sirve hasta el 6 nov 2026/)).toBeInTheDocument();
    expect(screen.getByText(/Se gasta primero · 20 almuerzos/)).toBeInTheDocument();
    const historia = screen.getByRole('region', { name: 'Historia del saldo' });
    expect(within(historia).getByText('+20')).toBeInTheDocument();
  });

  it('vende con transferencia; pide el canal y usa el mismo id si reintenta', async () => {
    const repo = repositorio({
      vender: vi
        .fn()
        .mockRejectedValueOnce(new ProblemaTiqueteras('SIN_CONEXION', 'No pudimos conectarnos.'))
        .mockResolvedValue(cuenta()),
    });
    render(<CuentaDelCliente repositorio={repo} clienteId="c1" nuevoId={nuevoId} />);
    fireEvent.click(await screen.findByRole('button', { name: 'Vender tiquetera' }));
    const cobrar = await screen.findByRole('button', { name: 'Cobrar $ 220.000' });
    fireEvent.click(cobrar);
    expect(await screen.findByText(/¿Por dónde llegó/)).toBeInTheDocument();
    fireEvent.change(screen.getByLabelText('Por dónde'), { target: { value: 'NEQUI' } });
    fireEvent.click(cobrar);
    expect(await screen.findByText('No pudimos conectarnos.')).toBeInTheDocument();
    fireEvent.click(cobrar);
    expect(await screen.findByText(/Vendida: «20 almuerzos»/)).toBeInTheDocument();
    const ids = vi.mocked(repo.vender).mock.calls.map(([v]) => v.ventaId);
    expect(ids).toEqual(['venta-1', 'venta-1']);
  });

  it('ajusta con motivo y no deja el saldo en negativo', async () => {
    const repo = repositorio();
    render(<CuentaDelCliente repositorio={repo} clienteId="c1" nuevoId={nuevoId} />);
    fireEvent.click(await screen.findByRole('button', { name: 'Ajustar' }));
    const unidades = await screen.findByLabelText(/^Unidades/);
    fireEvent.change(unidades, { target: { value: '-20' } });
    fireEvent.change(screen.getByLabelText('Motivo'), { target: { value: 'COURTESY' } });
    fireEvent.click(screen.getByRole('button', { name: 'Guardar ajuste' }));
    expect(await screen.findByText('Solo le quedan 14 almuerzos.')).toBeInTheDocument();
    fireEvent.change(unidades, { target: { value: '2' } });
    fireEvent.click(screen.getByRole('button', { name: 'Guardar ajuste' }));
    expect(await screen.findByText(/Ajuste guardado/)).toBeInTheDocument();
    expect(repo.ajustar).toHaveBeenCalledWith('q1', 2, { motivo: 'COURTESY', nota: null });
  });

  it('sin saldo lo dice; sin tiqueteras en venta, también', async () => {
    const vencida = tiquetera({ vigente: false, turno: null, saldo: 20 });
    const repo = repositorio({
      cuenta: vi.fn(async () => cuenta({ saldos: [], tiqueteras: [vencida], movimientos: [] })),
      catalogo: vi.fn(async () => ({ tipos: [], medios: [] })),
    });
    render(<CuentaDelCliente repositorio={repo} clienteId="c1" nuevoId={nuevoId} />);
    expect(await screen.findByText('No tiene saldo vigente.')).toBeInTheDocument();
    expect(screen.getByText(/Vigente \(venció\)/)).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: 'Vender tiquetera' }));
    expect(await screen.findByText(/No hay tiqueteras en venta/)).toBeInTheDocument();
  });
});
