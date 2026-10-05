import { fireEvent, render, screen } from '@testing-library/react';
import { Boton } from './boton';
import { Aviso } from './aviso';
import { Saldo } from './saldo';
import { anguloDelSello, Sello } from './sello';

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

describe('Saldo con total', () => {
  it('dice cuántas quedan de cuántas y dibuja una casilla por unidad', () => {
    const { container } = render(
      <Saldo unidades={8} singular="almuerzo" plural="almuerzos" total={20} />,
    );
    expect(screen.getByLabelText('Saldo: 8 almuerzos de 20')).toBeInTheDocument();
    expect(container.querySelectorAll('li')).toHaveLength(20);
  });
});

describe('Sello', () => {
  it('se lee completo y su giro es estable y pequeño', () => {
    render(<Sello arriba="¡Listo, veci!" cifra="12" abajo="almuerzos" semilla="c-1" />);
    expect(screen.getByRole('status', { name: '¡Listo, veci! 12 almuerzos' })).toBeInTheDocument();
    expect(anguloDelSello('c-1')).toBe(anguloDelSello('c-1'));
    for (const semilla of ['a', 'consumo-77', 'xyz-123']) {
      expect(Math.abs(anguloDelSello(semilla))).toBeLessThanOrEqual(8);
    }
  });
});

describe('Aviso', () => {
  it('el error se anuncia como alerta y el sello no se lee dos veces', () => {
    render(<Aviso tono="error">Este QR es de otro negocio.</Aviso>);
    expect(screen.getByRole('alert')).toHaveTextContent(/^✕Este QR es de otro negocio\.$/);
    expect(screen.getByText('✕')).toHaveAttribute('aria-hidden', 'true');
  });
});
