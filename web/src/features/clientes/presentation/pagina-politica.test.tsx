import { fireEvent, render, screen, within } from '@testing-library/react';
import { vi } from 'vitest';
import type { FuentePolitica } from '../domain/cliente';
import { PaginaPolitica } from './pagina-politica';

const fuente: FuentePolitica = {
  politica: vi.fn(async () => ({
    id: 'pol-1',
    version: '1.0',
    publicadaEn: new Date('2026-10-04T15:00:00Z'),
    enCorto: {
      anotamos: ['Tu nombre', 'Tu celular', 'Tu documento'],
      nuncaHacemos: ['Vender ni prestar tus datos'],
      paraQue: 'Para saber cuántos almuerzos te quedan.',
    },
    secciones: [
      {
        titulo: 'Quién ve tus datos',
        enPalabrasDeVecino: 'La cajera ve tu nombre y los últimos 4 números de tu documento.',
        texto: 'El Responsable garantiza que el personal autorizado del Comercio…',
      },
    ],
  })),
};

describe('PaginaPolitica', () => {
  it('muestra versión, el en corto y cada sección con su explicación arriba', async () => {
    render(<PaginaPolitica fuente={fuente} />);
    expect(
      await screen.findByText(/versión 1\.0\. Vigente desde el 4 de octubre de 2026/),
    ).toBeInTheDocument();
    expect(screen.getByRole('region', { name: 'En corto' })).toHaveTextContent(
      'Vender ni prestar tus datos',
    );
    const seccion = screen.getByRole('region', { name: 'Quién ve tus datos' });
    const vecino = within(seccion).getByText(/La cajera ve tu nombre/);
    const legal = within(seccion).getByText(/El Responsable garantiza/);
    expect(vecino.compareDocumentPosition(legal) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });

  it('se puede imprimir', async () => {
    const imprimir = vi.spyOn(window, 'print').mockImplementation(() => undefined);
    render(<PaginaPolitica fuente={fuente} />);
    fireEvent.click(await screen.findByRole('button', { name: 'Imprimir' }));
    expect(imprimir).toHaveBeenCalled();
  });

  it('si no carga, dice qué pasó', async () => {
    const falla = { politica: vi.fn(async () => Promise.reject(new Error('Sin señal, veci.'))) };
    render(<PaginaPolitica fuente={falla} />);
    expect(await screen.findByRole('alert')).toHaveTextContent('Sin señal, veci.');
  });
});
