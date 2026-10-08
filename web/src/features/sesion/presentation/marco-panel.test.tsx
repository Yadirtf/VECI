import { fireEvent, render, screen, within } from '@testing-library/react';
import { vi } from 'vitest';
import { MarcoPanel, type ItemMenu } from './marco-panel';

vi.mock('next/navigation', () => ({ usePathname: () => '/ventas' }));

const MENU: ItemMenu[] = [
  { href: '/', texto: 'Inicio', icono: 'inicio' },
  { href: '/clientes', texto: 'Clientes', icono: 'clientes', grupo: 'Día a día' },
  { href: '/ventas', texto: 'Ventas', icono: 'ventas', grupo: 'Día a día' },
  { href: '/negocio', texto: 'Mi negocio', icono: 'negocio', grupo: 'Tu negocio' },
];

function marco(puedeCambiarNegocio = false) {
  const acciones = { alCambiarNegocio: vi.fn(), alSalir: vi.fn() };
  render(
    <MarcoPanel
      negocio="Restaurante La Vecina"
      nombre="Marta"
      menu={MENU}
      puedeCambiarNegocio={puedeCambiarNegocio}
      {...acciones}
    >
      <h1>Ventas</h1>
    </MarcoPanel>,
  );
  return acciones;
}

describe('MarcoPanel', () => {
  it('marca la página actual y agrupa el menú por bloques', () => {
    marco();
    const menu = screen.getByRole('navigation', { name: 'Menú del panel' });
    expect(within(menu).getByRole('link', { name: 'Ventas' })).toHaveAttribute(
      'aria-current',
      'page',
    );
    expect(within(menu).getByRole('link', { name: 'Inicio' })).not.toHaveAttribute('aria-current');
    expect(within(menu).getByText('Día a día')).toBeInTheDocument();
    expect(within(menu).getByText('Tu negocio')).toBeInTheDocument();
  });

  it('en celular abre el cajón con el botón y lo cierra con Esc devolviendo el foco', () => {
    marco();
    const abrir = screen.getByRole('button', { name: 'Abrir el menú' });
    expect(abrir).toHaveAttribute('aria-expanded', 'false');
    fireEvent.click(abrir);
    const cajon = screen.getByRole('dialog', { name: 'Menú del panel' });
    expect(abrir).toHaveAttribute('aria-expanded', 'true');
    expect(cajon).toContainElement(document.activeElement as HTMLElement);
    fireEvent.keyDown(document, { key: 'Escape' });
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
    expect(abrir).toHaveFocus();
  });

  it('cierra el cajón con la X', () => {
    marco();
    fireEvent.click(screen.getByRole('button', { name: 'Abrir el menú' }));
    fireEvent.click(screen.getByRole('button', { name: 'Cerrar el menú' }));
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('solo ofrece cambiar de negocio a quien tiene más de uno, y deja salir', () => {
    const acciones = marco(true);
    fireEvent.click(screen.getByRole('button', { name: 'Cambiar de negocio' }));
    expect(acciones.alCambiarNegocio).toHaveBeenCalled();
    fireEvent.click(screen.getByRole('button', { name: 'Salir' }));
    expect(acciones.alSalir).toHaveBeenCalled();
  });

  it('sin más negocios no muestra el cambio', () => {
    marco(false);
    expect(screen.queryByRole('button', { name: 'Cambiar de negocio' })).not.toBeInTheDocument();
  });
});
