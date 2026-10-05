import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { vi } from 'vitest';
import type { Horario, RepositorioHorarios } from '../domain/horario';
import { CaminoDelSol } from './camino-del-sol';

const almuerzo: Horario = {
  id: 'h1',
  servicioId: 's1',
  servicioNombre: 'Almuerzo',
  sedeId: 'principal',
  dia: 'MONDAY',
  horaInicio: '11:30',
  horaFin: '15:00',
  activo: true,
};

function repositorio(horarios: Horario[] | Error): RepositorioHorarios {
  return {
    listar: vi.fn(() =>
      horarios instanceof Error ? Promise.reject(horarios) : Promise.resolve(horarios),
    ),
    servicios: vi.fn(async () => [{ id: 's1', nombre: 'Almuerzo' }]),
    sedes: vi.fn(async () => [{ id: 'principal', nombre: 'Principal' }]),
    crear: vi.fn(async () => undefined),
    editar: vi.fn(async () => 'h2'),
    cambiarEstado: vi.fn(async () => undefined),
    crearServicio: vi.fn(async (nombre: string) => ({ id: 's9', nombre })),
  };
}

const elegirLunes = () => fireEvent.click(screen.getByRole('radio', { name: /Lun/ }));

describe('CaminoDelSol', () => {
  it('estira un servicio con los botones y guarda las horas nuevas', async () => {
    const repo = repositorio([almuerzo]);
    render(<CaminoDelSol repositorio={repo} />);
    await screen.findByRole('radiogroup', { name: 'Día de la semana' });
    elegirLunes();
    fireEvent.click(screen.getByRole('button', { name: /Almuerzo, 11:30 a\. m\. a 3:00 p\. m\./ }));
    fireEvent.click(screen.getByRole('button', { name: 'Termina 15 minutos después' }));
    fireEvent.click(screen.getByRole('button', { name: 'Guardar nuevas horas' }));
    await waitFor(() => expect(repo.editar).toHaveBeenCalledWith('h1', '11:30', '15:15'));
  });

  it('pone en pausa un servicio sin borrarlo', async () => {
    const repo = repositorio([almuerzo]);
    render(<CaminoDelSol repositorio={repo} />);
    await screen.findByRole('radiogroup', { name: 'Día de la semana' });
    elegirLunes();
    fireEvent.click(screen.getByRole('button', { name: /^Almuerzo,/ }));
    fireEvent.click(screen.getByRole('button', { name: 'Pausar este servicio' }));
    await waitFor(() => expect(repo.cambiarEstado).toHaveBeenCalledWith('h1', false));
  });

  it('un día sin servicios se ve como descanso', async () => {
    render(<CaminoDelSol repositorio={repositorio([almuerzo])} />);
    await screen.findByRole('radiogroup', { name: 'Día de la semana' });
    fireEvent.click(screen.getByRole('radio', { name: /Dom/ }));
    expect(screen.getByText('Domingo descansas')).toBeInTheDocument();
  });

  it('explica qué hacer si falla la conexión', async () => {
    render(<CaminoDelSol repositorio={repositorio(new Error('x'))} />);
    expect(await screen.findByRole('alert')).toHaveTextContent('Revisa tu internet');
  });
});
