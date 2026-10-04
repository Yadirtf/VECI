import { fireEvent, render, screen, within } from '@testing-library/react';
import { vi } from 'vitest';
import type { Miembro, RepositorioEquipo } from '../domain/equipo';
import { PantallaDispositivos } from './pantalla-dispositivos';
import { PantallaEquipo } from './pantalla-equipo';

const jhon: Miembro = {
  membresiaId: 'm2',
  usuarioId: 'u2',
  nombre: 'Jhon Mutumbajoy',
  celular: '+573100000102',
  estado: 'ACTIVE',
  roles: ['CASHIER'],
};

function repositorio(): RepositorioEquipo {
  return {
    listar: vi.fn(async () => [jhon]),
    invitar: vi.fn(async () => ({ membresiaId: 'm3', pinTemporal: '482915' })),
    cambiarEstado: vi.fn(async () => undefined),
    restablecerPin: vi.fn(async () => '730284'),
    dispositivos: vi.fn(async () => [
      {
        dispositivoId: 'd1',
        nombre: 'Moto E13',
        plataforma: 'ANDROID',
        ultimaVez: new Date(),
        sesiones: [{ sesionId: 's1', nombre: 'Jhon', ultimoUso: new Date() }],
      },
    ]),
    cerrarSesiones: vi.fn(async () => 1),
  };
}

describe('PantallaEquipo', () => {
  it('al invitar muestra el PIN temporal una sola vez', async () => {
    const repo = repositorio();
    render(<PantallaEquipo repositorio={repo} />);
    fireEvent.change(screen.getByLabelText('Nombres'), { target: { value: 'Ana' } });
    fireEvent.change(screen.getByLabelText('Celular'), { target: { value: '3124567890' } });
    fireEvent.change(screen.getByLabelText('Número de documento'), {
      target: { value: '1124500777' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Invitar' }));
    const aviso = await screen.findByRole('status', { name: 'PIN temporal' });
    expect(aviso).toHaveTextContent('482915');
    fireEvent.click(within(aviso).getByRole('button', { name: 'Ya lo anoté' }));
    expect(screen.queryByText('482915')).not.toBeInTheDocument();
  });

  it('pide confirmar antes de retirar a alguien', async () => {
    const repo = repositorio();
    render(<PantallaEquipo repositorio={repo} />);
    const tarjeta = await screen.findByRole('region', { name: 'Jhon Mutumbajoy' });
    const retirar = within(tarjeta).getByRole('button', { name: 'Retirar del equipo' });
    fireEvent.click(retirar);
    expect(repo.cambiarEstado).not.toHaveBeenCalled();
    fireEvent.click(retirar);
    expect(repo.cambiarEstado).toHaveBeenCalledWith('m2', 'RETIRAR');
    expect(await screen.findByText(/ya no hace parte del equipo/)).toBeInTheDocument();
  });

  it('da un PIN nuevo al cajero que lo olvidó', async () => {
    render(<PantallaEquipo repositorio={repositorio()} />);
    const tarjeta = await screen.findByRole('region', { name: 'Jhon Mutumbajoy' });
    fireEvent.click(within(tarjeta).getByRole('button', { name: 'Darle un PIN nuevo' }));
    expect(await screen.findByRole('status', { name: 'PIN temporal' })).toHaveTextContent('730284');
  });
});

describe('PantallaDispositivos', () => {
  it('cierra la sesión de un celular a distancia', async () => {
    const repo = repositorio();
    render(<PantallaDispositivos repositorio={repo} />);
    fireEvent.click(
      await screen.findByRole('button', { name: 'Cerrar sesión en este dispositivo' }),
    );
    expect(await screen.findByText('Listo. Cerramos la sesión en Moto E13.')).toBeInTheDocument();
    expect(repo.cerrarSesiones).toHaveBeenCalledWith('d1');
  });
});
