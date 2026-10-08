import { fireEvent, render, screen } from '@testing-library/react';
import { vi } from 'vitest';
import type { RepositorioCuentas, VentaReciente } from '../domain/tiquetera';
import { cuenta } from '../pruebas';
import { PantallaVentas, pagoLegible } from './pantalla-ventas';

const venta = (cambios: Partial<VentaReciente> = {}): VentaReciente => ({
  ventaId: 'v1',
  clienteId: 'c1',
  cliente: 'Luz Marina Chindoy',
  tiquetera: '20 almuerzos',
  precio: 220000,
  pago: { medio: 'BANK_TRANSFER', canal: 'NEQUI', referencia: null },
  ocurridaEn: new Date('2026-10-08T15:00:00Z'),
  sinConexion: true,
  anulada: false,
  cajero: 'Ana Lucía',
  saldo: 20,
  ...cambios,
});

function repositorio(): RepositorioCuentas {
  return {
    catalogo: vi.fn(),
    cuenta: vi.fn(),
    vender: vi.fn(),
    ventas: vi.fn(async () => [venta(), venta({ ventaId: 'v2', cliente: 'Rosa', anulada: true })]),
    motivos: vi.fn(async () => [
      { codigo: 'DATA_ENTRY_ERROR', nombre: 'Error al registrar' },
      { codigo: 'OTHER', nombre: 'Otro' },
    ]),
    anular: vi.fn(async () => cuenta()),
    ajustar: vi.fn(),
  };
}

describe('PantallaVentas', () => {
  it('lista las ventas con quién, cómo pagó y si fue sin señal', async () => {
    render(<PantallaVentas repositorio={repositorio()} />);
    expect((await screen.findAllByText(/Transferencia · Nequi/))[0]).toHaveTextContent(
      'vendió Ana Lucía · hecha sin señal',
    );
    expect(screen.getByText(/Anulada: sigue en la historia/)).toBeInTheDocument();
    expect(screen.getAllByRole('button', { name: 'Anular' })).toHaveLength(1);
  });

  it('anular pide motivo y nota con «Otro»', async () => {
    const repo = repositorio();
    render(<PantallaVentas repositorio={repo} />);
    fireEvent.click(await screen.findByRole('button', { name: 'Anular' }));
    fireEvent.click(screen.getByRole('button', { name: 'Anular venta' }));
    expect(await screen.findByText('Elige el motivo.')).toBeInTheDocument();
    fireEvent.change(screen.getByLabelText('Motivo'), { target: { value: 'OTHER' } });
    fireEvent.click(screen.getByRole('button', { name: 'Anular venta' }));
    expect(await screen.findByText('Con «Otro» cuenta en la nota qué pasó.')).toBeInTheDocument();
    fireEvent.change(screen.getByLabelText(/^Nota/), { target: { value: 'Se cobró dos veces' } });
    fireEvent.click(screen.getByRole('button', { name: 'Anular venta' }));
    expect(await screen.findByText(/Anulada la venta de Luz Marina Chindoy/)).toBeInTheDocument();
    expect(repo.anular).toHaveBeenCalledWith('v1', { motivo: 'OTHER', nota: 'Se cobró dos veces' });
  });

  it('el pago en efectivo se lee sin canal', () => {
    expect(pagoLegible({ pago: { medio: 'CASH', canal: null, referencia: null } })).toBe(
      'Efectivo',
    );
  });
});
