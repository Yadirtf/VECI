import { fireEvent, render, screen } from '@testing-library/react';
import { Boton } from './boton';
import { Saldo } from './saldo';

describe('Boton', () => {
  it('es un botón accesible que responde al toque', () => {
    const alTocar = vi.fn();
    render(<Boton onClick={alTocar}>Vender tiquetera</Boton>);
    fireEvent.click(screen.getByRole('button', { name: 'Vender tiquetera' }));
    expect(alTocar).toHaveBeenCalledOnce();
  });

  it('el tamaño grande usa la altura de toque grande', () => {
    render(<Boton grande>Cobrar</Boton>);
    expect(screen.getByRole('button').className).toContain('min-h-toque-boton-grande');
  });
});

describe('Saldo', () => {
  it('usa singular o plural según las unidades', () => {
    const { rerender } = render(<Saldo unidades={1} singular="almuerzo" plural="almuerzos" />);
    expect(screen.getByLabelText('Saldo: 1 almuerzo')).toBeInTheDocument();
    rerender(<Saldo unidades={12} singular="almuerzo" plural="almuerzos" />);
    expect(screen.getByLabelText('Saldo: 12 almuerzos')).toBeInTheDocument();
  });
});
