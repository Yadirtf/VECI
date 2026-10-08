import { render, renderHook, screen } from '@testing-library/react';
import { vi } from 'vitest';
import { useAlta, type AlmacenBorrador } from '../application/use-alta';
import type { RepositorioComercios, Solicitud } from '../domain/comercio';
import { SolicitudDeNegocio } from './solicitud-de-negocio';

vi.mock('next/link', () => ({
  default: ({ children, href }: { children: React.ReactNode; href: string }) => (
    <a href={href}>{children}</a>
  ),
}));

const sinMemoria: AlmacenBorrador = { leer: () => null, guardar: () => undefined };
const repositorio = {
  tipos: vi.fn(async () => []),
  municipios: vi.fn(async () => [{ id: 86001, nombre: 'Mocoa' }]),
  solicitar: vi.fn(async () => undefined),
} as unknown as RepositorioComercios;
const catalogos = async () => ({ tipos: [], municipios: [{ id: 86001, nombre: 'Mocoa' }] });
const solicitud = (cambios: Partial<Solicitud>): Solicitud => ({
  solicitudId: 's1',
  estado: 'PENDING',
  nombre: 'Asadero El Vecino',
  municipio: 'Mocoa',
  nota: null,
  comercioId: null,
  radicadaEn: '2026-10-08T15:00:00Z',
  ...cambios,
});

function pintar(solicitudes: Solicitud[]) {
  const { result } = renderHook(() => useAlta(repositorio, sinMemoria));
  render(
    <SolicitudDeNegocio
      alta={result.current}
      cargarCatalogos={catalogos}
      misSolicitudes={async () => solicitudes}
    />,
  );
}

describe('SolicitudDeNegocio', () => {
  it('con una solicitud en revisión no deja enviar otra', async () => {
    pintar([solicitud({})]);
    expect(await screen.findByText('Recibimos tu solicitud, veci')).toBeInTheDocument();
    expect(screen.getByText('Asadero El Vecino')).toBeInTheDocument();
  });

  it('si la última fue rechazada cuenta por qué y deja pedir de nuevo', async () => {
    pintar([solicitud({ estado: 'REJECTED', nota: 'El NIT no es del negocio.' })]);
    expect(await screen.findByText(/El NIT no es del negocio\./)).toBeInTheDocument();
    expect(await screen.findByLabelText(/Nombre como lo conoce/)).toBeInTheDocument();
  });
});
