import { fireEvent, render, screen, waitFor, within } from '@testing-library/react';
import { vi } from 'vitest';
import type { Horario, NuevoHorario, RepositorioHorarios } from '../domain/horario';
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

const desayunoMiercoles: Horario = {
  ...almuerzo,
  id: 'h2',
  servicioId: 's2',
  servicioNombre: 'Desayuno',
  dia: 'WEDNESDAY',
  horaInicio: '07:00',
  horaFin: '12:00',
};

function repositorio(horarios: Horario[] | Error): RepositorioHorarios {
  return {
    listar: vi.fn(() =>
      horarios instanceof Error ? Promise.reject(horarios) : Promise.resolve(horarios),
    ),
    servicios: vi.fn(async () => [
      { id: 's1', nombre: 'Almuerzo' },
      { id: 's2', nombre: 'Desayuno' },
      { id: 's3', nombre: 'Cena' },
    ]),
    sedes: vi.fn(async () => [{ id: 'principal', nombre: 'Principal' }]),
    programar: vi.fn(async ({ dias }: NuevoHorario) =>
      dias.map((dia) => ({ ...almuerzo, id: `n-${dia}`, dia })),
    ),
    cambiarEstado: vi.fn(async () => undefined),
    crearServicio: vi.fn(async (nombre: string) => ({ id: 's9', nombre })),
  };
}

const elegirDia = (nombre: RegExp) => fireEvent.click(screen.getByRole('radio', { name: nombre }));
const tocar = (nombre: string | RegExp) =>
  fireEvent.click(screen.getByRole('button', { name: nombre }));

async function abrir(horarios: Horario[]) {
  const repo = repositorio(horarios);
  render(<CaminoDelSol repositorio={repo} />);
  await screen.findByRole('radiogroup', { name: 'Día de la semana' });
  return repo;
}

describe('CaminoDelSol', () => {
  it('estira un servicio con los botones y guarda las horas nuevas ese día', async () => {
    const repo = await abrir([almuerzo]);
    elegirDia(/Lun/);
    tocar(/Almuerzo, 11:30 a\. m\. a 3:00 p\. m\./);
    tocar('Termina 15 minutos después');
    tocar('Guardar en lunes');
    await waitFor(() =>
      expect(repo.programar).toHaveBeenCalledWith({
        servicioId: 's1',
        sedeId: 'principal',
        dias: ['MONDAY'],
        horaInicio: '11:30',
        horaFin: '15:15',
      }),
    );
  });

  it('guarda las mismas horas de lunes a viernes de una vez', async () => {
    const repo = await abrir([almuerzo]);
    elegirDia(/Lun/);
    tocar(/^Almuerzo,/);
    tocar('Termina 15 minutos después');
    tocar('Lunes a viernes');
    tocar('Guardar en 5 días');
    await waitFor(() =>
      expect(repo.programar).toHaveBeenCalledWith(
        expect.objectContaining({
          dias: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
          horaFin: '15:15',
        }),
      ),
    );
  });

  it('avisa qué día se cruza con otro servicio y no deja guardar', async () => {
    const repo = await abrir([almuerzo, desayunoMiercoles]);
    elegirDia(/Lun/);
    tocar(/^Almuerzo,/);
    tocar('Lunes a viernes');
    expect(screen.getByRole('alert')).toHaveTextContent(
      'El miércoles se cruza con Desayuno (7:00 a. m. a 12:00 p. m.)',
    );
    expect(screen.getByRole('button', { name: 'Guardar en 5 días' })).toBeDisabled();
    expect(repo.programar).not.toHaveBeenCalled();
  });

  it('agrega la cena con sus horas de costumbre en varios días', async () => {
    const repo = await abrir([]);
    elegirDia(/Lun/);
    const formulario = screen.getByText('Agregar un servicio').closest('details')!;
    fireEvent.click(within(formulario).getByRole('button', { name: 'Cena' }));
    tocar('Toda la semana');
    tocar('Guardar en toda la semana');
    await waitFor(() =>
      expect(repo.programar).toHaveBeenCalledWith(
        expect.objectContaining({
          servicioId: 's3',
          dias: expect.arrayContaining(['MONDAY', 'SUNDAY']),
          horaInicio: '18:00',
          horaFin: '21:00',
        }),
      ),
    );
  });

  it('pone en pausa un servicio sin borrarlo', async () => {
    const repo = await abrir([almuerzo]);
    elegirDia(/Lun/);
    tocar(/^Almuerzo,/);
    tocar('Pausar este servicio');
    await waitFor(() => expect(repo.cambiarEstado).toHaveBeenCalledWith('h1', false));
  });

  it('un día sin servicios se ve como descanso', async () => {
    await abrir([almuerzo]);
    elegirDia(/Dom/);
    expect(screen.getByText('Domingo descansas')).toBeInTheDocument();
  });

  it('explica qué hacer si falla la conexión', async () => {
    render(<CaminoDelSol repositorio={repositorio(new Error('x'))} />);
    expect(await screen.findByRole('alert')).toHaveTextContent('Revisa tu internet');
  });
});
