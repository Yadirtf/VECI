import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { vi } from 'vitest';
import type { MapaDeSedes, RepositorioSedes } from '../domain/sede';
import { PantallaSedes } from './pantalla-sedes';

const principal = {
  id: 'p',
  nombre: 'Principal',
  principal: true,
  activa: true,
  municipio: 'Mocoa',
  direccion: null,
};
const parque = { ...principal, id: 'q', nombre: 'Parque', principal: false };

function repositorio(mapa: MapaDeSedes): RepositorioSedes {
  return {
    mapa: vi.fn(async () => mapa),
    crear: vi.fn(async () => undefined),
    cambiarActiva: vi.fn(async () => undefined),
    asignar: vi.fn(async () => undefined),
  };
}

describe('PantallaSedes', () => {
  it('en el plan Básico invita a Pro en vez de dejar armar otra casa', async () => {
    const repo = repositorio({
      sedes: [principal],
      cajeros: [],
      cupo: { ocupadas: 1, limite: 1, variasSedes: false },
    });
    render(<PantallaSedes repositorio={repo} />);
    fireEvent.click(await screen.findByRole('button', { name: 'Con el plan Pro armas otra sede' }));
    expect(screen.getByText(/vienen con el plan Pro/)).toBeInTheDocument();
  });

  it('con Pro arma una sede nueva', async () => {
    const repo = repositorio({
      sedes: [principal],
      cajeros: [],
      cupo: { ocupadas: 1, limite: 3, variasSedes: true },
    });
    render(<PantallaSedes repositorio={repo} />);
    fireEvent.click(await screen.findByRole('button', { name: 'Armar otra sede' }));
    fireEvent.change(screen.getByLabelText(/nueva sede/), { target: { value: 'Parque' } });
    fireEvent.click(screen.getByRole('button', { name: 'Armar la casa' }));
    await waitFor(() => expect(repo.crear).toHaveBeenCalledWith('Parque', null));
  });

  it('quita a un cajero de una sede y lo deja en las demás', async () => {
    const cajeros = [{ membresiaId: 'm1', nombre: 'Ana', sedeIds: [] }];
    const repo = repositorio({
      sedes: [principal, parque],
      cajeros,
      cupo: { ocupadas: 2, limite: 3, variasSedes: true },
    });
    render(<PantallaSedes repositorio={repo} />);
    fireEvent.click(await screen.findByRole('button', { name: 'Parque', pressed: true }));
    await waitFor(() => expect(repo.asignar).toHaveBeenCalledWith('m1', ['p']));
  });
});
