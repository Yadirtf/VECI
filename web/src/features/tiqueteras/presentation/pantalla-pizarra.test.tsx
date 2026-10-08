import { fireEvent, render, screen, waitFor, within } from '@testing-library/react';
import { vi } from 'vitest';
import { ProblemaTiqueteras, type RepositorioPizarra } from '../domain/tiquetera';
import { almuerzo, tipo } from '../pruebas';
import { PantallaPizarra } from './pantalla-pizarra';

function repositorio(cambios: Partial<RepositorioPizarra> = {}): RepositorioPizarra {
  return {
    tipos: vi.fn(async () => [
      tipo({ vendidas: 3, vigentes: 2 }),
      tipo({ tipoId: 't2', nombre: 'Viejo', estado: 'INACTIVE' }),
    ]),
    unidades: vi.fn(async () => [almuerzo]),
    crear: vi.fn(async () => tipo()),
    editar: vi.fn(async () => tipo()),
    cambiarEstado: vi.fn(async () => tipo()),
    ...cambios,
  };
}

const escribir = (etiqueta: string, valor: string) =>
  fireEvent.change(screen.getByLabelText(new RegExp(`^${etiqueta.replace(/[()]/g, '\\$&')}`)), {
    target: { value: valor },
  });

describe('PantallaPizarra', () => {
  it('muestra lo que se vende y lo guardado borroso', async () => {
    render(<PantallaPizarra repositorio={repositorio()} />);
    const pizarra = await screen.findByRole('region', { name: 'Pizarra de tiqueteras' });
    expect(within(pizarra).getAllByText('20 almuerzos · $ 220.000 · sirve 30 días')).toHaveLength(
      2,
    );
    expect(within(pizarra).getByText(/3 vendidas · 2 vigentes/)).toBeInTheDocument();
    expect(within(pizarra).getByText(/no se vende/)).toBeInTheDocument();
    expect(within(pizarra).getByRole('button', { name: 'Volver a vender' })).toBeInTheDocument();
  });

  it('escribe una tiquetera nueva y avisa los errores antes de enviar', async () => {
    const repo = repositorio();
    render(<PantallaPizarra repositorio={repo} />);
    fireEvent.click(await screen.findByRole('button', { name: 'Escribir tiquetera' }));
    escribir('Nombre', '20 almuerzos');
    escribir('Cantidad', '20');
    escribir('Precio en pesos', '220.000');
    expect(screen.getByText('Sale a $ 11.000 cada una.')).toBeInTheDocument();
    escribir('Sirve por (días)', '0');
    fireEvent.click(screen.getByRole('button', { name: 'Guardar en la pizarra' }));
    expect(await screen.findByText('La vigencia va de 1 a 365 días.')).toBeInTheDocument();
    escribir('Sirve por (días)', '30');
    fireEvent.click(screen.getByRole('button', { name: 'Guardar en la pizarra' }));
    await screen.findByText(/ya está en la pizarra/);
    expect(repo.crear).toHaveBeenCalledWith({
      nombre: '20 almuerzos',
      unidad: 'LUNCH',
      unidades: 20,
      precio: 220000,
      vigenciaDias: 30,
    });
  });

  it('con ventas no deja cambiar la cantidad; se puede dejar de vender', async () => {
    const repo = repositorio();
    render(<PantallaPizarra repositorio={repo} />);
    fireEvent.click((await screen.findAllByRole('button', { name: 'Cambiar' }))[0]);
    expect(screen.getByLabelText(/^Cantidad/)).toBeDisabled();
    escribir('Precio en pesos', '240000');
    fireEvent.click(screen.getByRole('button', { name: 'Guardar en la pizarra' }));
    await screen.findByText(/Lo vendido no cambia/);
    expect(repo.editar).toHaveBeenCalledWith('t1', expect.objectContaining({ precio: 240000 }));
    fireEvent.click(screen.getByRole('button', { name: 'Dejar de vender' }));
    await screen.findByText(/se dejó de vender/);
    expect(repo.cambiarEstado).toHaveBeenCalledWith('t1', false);
  });

  it('muestra lo que dice la API cuando no se puede', async () => {
    const repo = repositorio({
      crear: vi.fn(async () => {
        throw new ProblemaTiqueteras('NOMBRE_REPETIDO', 'Ya tienes una tiquetera con ese nombre.');
      }),
      tipos: vi.fn(async () => []),
    });
    render(<PantallaPizarra repositorio={repo} />);
    expect(await screen.findByText(/La pizarra está limpia/)).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: 'Escribir tiquetera' }));
    escribir('Nombre', '20 almuerzos');
    escribir('Cantidad', '20');
    escribir('Precio en pesos', '220000');
    fireEvent.click(screen.getByRole('button', { name: 'Guardar en la pizarra' }));
    expect(await screen.findByText('Ya tienes una tiquetera con ese nombre.')).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: 'Cancelar' }));
    await waitFor(() => expect(screen.queryByLabelText(/^Nombre/)).not.toBeInTheDocument());
  });

  it('si no carga, lo dice', async () => {
    render(
      <PantallaPizarra
        repositorio={repositorio({
          tipos: vi.fn(async () => {
            throw new Error('Sin internet.');
          }),
        })}
      />,
    );
    expect(await screen.findByText('Sin internet.')).toBeInTheDocument();
  });
});
