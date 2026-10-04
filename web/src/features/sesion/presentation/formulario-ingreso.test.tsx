import { fireEvent, render, screen } from '@testing-library/react';
import { vi } from 'vitest';
import { FormularioIngreso } from './formulario-ingreso';
import { PasoPinNuevo } from './paso-pin-nuevo';

const escribir = (etiqueta: string | RegExp, valor: string) =>
  fireEvent.change(screen.getByLabelText(etiqueta), { target: { value: valor } });

describe('FormularioIngreso', () => {
  it('entra con celular y PIN', async () => {
    const alEntrarConPin = vi.fn(async () => undefined);
    render(<FormularioIngreso alEntrarConPin={alEntrarConPin} alEntrarConContrasena={vi.fn()} />);
    escribir('Celular', '310 000 0101');
    escribir(/^PIN/, '246813');
    fireEvent.click(screen.getByRole('button', { name: 'Entrar' }));
    expect(alEntrarConPin).toHaveBeenCalledWith('310 000 0101', '246813');
  });

  it('explica qué falta sin llamar al servidor', () => {
    const alEntrarConPin = vi.fn();
    render(<FormularioIngreso alEntrarConPin={alEntrarConPin} alEntrarConContrasena={vi.fn()} />);
    escribir('Celular', '12');
    fireEvent.click(screen.getByRole('button', { name: 'Entrar' }));
    expect(screen.getByRole('alert')).toHaveTextContent('empieza por 3');
    expect(alEntrarConPin).not.toHaveBeenCalled();
  });

  it('muestra el mensaje de la API si no coinciden', async () => {
    const falla = vi.fn(async () => {
      throw new Error('El celular o el PIN no coinciden.');
    });
    render(<FormularioIngreso alEntrarConPin={vi.fn()} alEntrarConContrasena={falla} />);
    fireEvent.click(screen.getByRole('tab', { name: 'Correo' }));
    escribir('Correo', 'marta@lavecina.co');
    escribir(/^Contraseña/, 'otra');
    fireEvent.click(screen.getByRole('button', { name: 'Entrar' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('no coinciden');
  });
});

describe('PasoPinNuevo', () => {
  it('pide escribir el PIN dos veces igual', async () => {
    const alCrear = vi.fn(async () => undefined);
    render(<PasoPinNuevo nombre="Jhon" alCrear={alCrear} />);
    escribir(/^PIN nuevo/, '730284');
    escribir('Escríbelo otra vez', '730285');
    fireEvent.click(screen.getByRole('button', { name: 'Guardar mi PIN' }));
    expect(screen.getByRole('alert')).toHaveTextContent('no coinciden');
    escribir('Escríbelo otra vez', '730284');
    fireEvent.click(screen.getByRole('button', { name: 'Guardar mi PIN' }));
    expect(alCrear).toHaveBeenCalledWith('730284');
  });
});
