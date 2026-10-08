import { fireEvent, render, screen, waitFor, within } from '@testing-library/react';
import { vi } from 'vitest';
import type { RepositorioPlataforma, SolicitudPorRevisar } from '../domain/solicitud';
import { PantallaSolicitudes } from './pantalla-solicitudes';

const asadero: SolicitudPorRevisar = {
  solicitudId: 's1',
  nombre: 'Asadero El Vecino',
  tipoNegocio: 'RESTAURANT',
  tipoDocumento: 'NIT',
  numeroDocumento: '8001972684',
  celular: '+573100000101',
  correo: null,
  municipio: 'Mocoa',
  direccion: 'Barrio San Agustín',
  solicitante: { nombre: 'Rosa Chindoy', celular: '+573124567890' },
  radicadaEn: new Date('2026-10-08T15:00:00Z'),
};

function repositorio(): RepositorioPlataforma {
  return {
    pendientes: vi.fn().mockResolvedValueOnce([asadero]).mockResolvedValue([]),
    aprobar: vi.fn(async () => undefined),
    rechazar: vi.fn(async () => undefined),
  };
}

describe('PantallaSolicitudes', () => {
  it('muestra quién pide qué y al aprobar avisa y saca la solicitud de la lista', async () => {
    const repo = repositorio();
    render(<PantallaSolicitudes repositorio={repo} />);
    const tarjeta = await screen.findByRole('article', { name: 'Asadero El Vecino' });
    expect(within(tarjeta).getByText('NIT 800.197.268-4')).toBeInTheDocument();
    expect(within(tarjeta).getByText('Rosa Chindoy · +573124567890')).toBeInTheDocument();
    fireEvent.click(within(tarjeta).getByRole('button', { name: 'Aprobar y crear el negocio' }));
    expect(await screen.findByText('Asadero El Vecino ya está en VECI.')).toBeInTheDocument();
    expect(repo.aprobar).toHaveBeenCalledWith('s1');
    expect(await screen.findByText(/No hay solicitudes por revisar/)).toBeInTheDocument();
  });

  it('para rechazar pide el motivo y se lo envía a la persona', async () => {
    const repo = repositorio();
    render(<PantallaSolicitudes repositorio={repo} />);
    fireEvent.click(await screen.findByRole('button', { name: 'Rechazar' }));
    const confirmar = screen.getByRole('button', { name: 'Rechazar con este motivo' });
    fireEvent.click(confirmar);
    expect(screen.getByRole('status')).toHaveTextContent('10 letras');
    expect(repo.rechazar).not.toHaveBeenCalled();
    fireEvent.change(screen.getByLabelText(/Por qué no se aprueba/), {
      target: { value: 'El NIT no corresponde al negocio' },
    });
    fireEvent.click(confirmar);
    await waitFor(() =>
      expect(repo.rechazar).toHaveBeenCalledWith('s1', 'El NIT no corresponde al negocio'),
    );
    expect(await screen.findByText('Le contamos a Rosa Chindoy por qué.')).toBeInTheDocument();
  });

  it('a quien no es del equipo VECI le muestra el mensaje del servidor', async () => {
    const repo = repositorio();
    repo.pendientes = vi.fn(async () => {
      throw new Error('Esta acción es solo para el equipo de VECI.');
    });
    render(<PantallaSolicitudes repositorio={repo} />);
    expect(await screen.findByRole('alert')).toHaveTextContent('solo para el equipo de VECI');
  });
});
