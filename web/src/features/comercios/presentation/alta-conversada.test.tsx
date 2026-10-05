import { fireEvent, render, renderHook, screen, waitFor, act } from '@testing-library/react';
import { vi } from 'vitest';
import { useAlta, type AlmacenBorrador } from '../application/use-alta';
import { BORRADOR_VACIO } from '../domain/alta';
import type { RepositorioComercios } from '../domain/comercio';
import { AltaConversada } from './alta-conversada';

const repositorio = {
  tipos: vi.fn(async () => [
    {
      codigo: 'RESTAURANT',
      nombre: 'Restaurante',
      servicios: [{ nombre: 'Almuerzo', horaInicio: '11:30', horaFin: '15:00' }],
    },
  ]),
  municipios: vi.fn(async () => [{ id: 86001, nombre: 'Mocoa' }]),
  registrar: vi.fn(async () => ({ comercioId: 'c1' })),
} as unknown as RepositorioComercios;

const sinMemoria: AlmacenBorrador = { leer: () => null, guardar: () => undefined };
const catalogos = async () => ({
  tipos: await repositorio.tipos(),
  municipios: await repositorio.municipios(),
});
const seguir = () => fireEvent.click(screen.getByRole('button', { name: 'Seguir' }));
const escribir = (etiqueta: RegExp, valor: string) =>
  fireEvent.change(screen.getByLabelText(etiqueta), { target: { value: valor } });

function Alta({ alRegistrar }: { alRegistrar(id: string): Promise<void> }) {
  const alta = useAlta(repositorio, sinMemoria);
  return <AltaConversada alta={alta} cargarCatalogos={catalogos} alRegistrar={alRegistrar} />;
}

describe('AltaConversada', () => {
  it('pregunta una cosa a la vez, pone el dígito del NIT y registra el negocio', async () => {
    const alRegistrar = vi.fn(async () => undefined);
    render(<Alta alRegistrar={alRegistrar} />);
    await screen.findByLabelText(/Nombre como lo conoce/);
    escribir(/Nombre como lo conoce/, 'Restaurante La Vecina');
    seguir();
    fireEvent.click(await screen.findByRole('button', { name: 'Restaurante' }));
    expect(screen.getByText(/nace con Almuerzo/)).toBeInTheDocument();
    seguir();
    escribir(/NIT, solo los 9/, '800197268');
    expect(screen.getByText(/dígito de verificación es 4/)).toBeInTheDocument();
    seguir();
    escribir(/Celular del negocio/, '310 000 0101');
    seguir();
    seguir();
    fireEvent.click(screen.getByRole('button', { name: 'Abrir mi negocio en VECI' }));
    await waitFor(() => expect(alRegistrar).toHaveBeenCalledWith('c1'));
    expect(repositorio.registrar).toHaveBeenCalledWith(
      expect.objectContaining({ numeroDocumento: '8001972684', celular: '3100000101' }),
    );
  });

  it('no deja seguir sin nombre y dice qué falta', async () => {
    render(<Alta alRegistrar={vi.fn()} />);
    await screen.findByLabelText(/Nombre como lo conoce/);
    seguir();
    expect(screen.getByRole('status')).toHaveTextContent('Mínimo 3 letras');
  });

  it('recuerda lo que se llevaba escrito', () => {
    const almacen: AlmacenBorrador = {
      leer: () => ({ ...BORRADOR_VACIO, nombre: 'Panadería Sol' }),
      guardar: vi.fn(),
    };
    const { result } = renderHook(() => useAlta(repositorio, almacen));
    expect(result.current.borrador.nombre).toBe('Panadería Sol');
    act(() => result.current.cambiar({ nombre: 'Panadería Luna' }));
    expect(almacen.guardar).toHaveBeenCalledWith(
      expect.objectContaining({ nombre: 'Panadería Luna' }),
    );
  });
});
