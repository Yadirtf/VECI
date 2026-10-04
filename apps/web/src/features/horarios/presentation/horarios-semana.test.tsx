import { render, screen } from '@testing-library/react';
import type { Horario, RepositorioHorarios } from '../domain/horario';
import { HorariosSemana } from './horarios-semana';

const almuerzo: Horario = {
  id: '1',
  servicioNombre: 'Almuerzo',
  sedeId: 's',
  dia: 'MONDAY',
  horaInicio: '11:30',
  horaFin: '15:00',
};

const repositorio = (resultado: Promise<Horario[]>): RepositorioHorarios => ({
  listar: () => resultado,
});

describe('HorariosSemana', () => {
  it('muestra los horarios agrupados por día', async () => {
    render(<HorariosSemana repositorio={repositorio(Promise.resolve([almuerzo]))} />);
    expect(await screen.findByRole('heading', { name: 'Lunes' })).toBeInTheDocument();
    expect(screen.getByText('11:30 a. m. – 3:00 p. m.')).toBeInTheDocument();
  });

  it('invita a crear el primer horario cuando no hay ninguno', async () => {
    render(<HorariosSemana repositorio={repositorio(Promise.resolve([]))} />);
    expect(await screen.findByText(/Crea el primero/)).toBeInTheDocument();
  });

  it('explica qué hacer si falla la conexión', async () => {
    render(<HorariosSemana repositorio={repositorio(Promise.reject(new Error('x')))} />);
    expect(await screen.findByRole('alert')).toHaveTextContent('Revisa tu internet');
  });
});
