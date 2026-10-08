import type { ReactNode } from 'react';
import { Panel } from '@/features/sesion';

const MENU = [
  { href: '/', texto: 'Inicio', icono: 'inicio' },
  { href: '/clientes', texto: 'Clientes', icono: 'clientes', grupo: 'Día a día' },
  { href: '/tiqueteras', texto: 'Tiqueteras', icono: 'tiqueteras', grupo: 'Día a día' },
  { href: '/ventas', texto: 'Ventas', icono: 'ventas', grupo: 'Día a día' },
  { href: '/negocio', texto: 'Mi negocio', icono: 'negocio', grupo: 'Tu negocio' },
  { href: '/horarios', texto: 'Horarios', icono: 'horarios', grupo: 'Tu negocio' },
  { href: '/sedes', texto: 'Sedes', icono: 'sedes', grupo: 'Tu negocio' },
  { href: '/equipo', texto: 'Equipo', icono: 'equipo', grupo: 'Tu equipo' },
  { href: '/dispositivos', texto: 'Dispositivos', icono: 'dispositivos', grupo: 'Tu equipo' },
  { href: '/mi-cuenta', texto: 'Mi cuenta', icono: 'cuenta', grupo: 'Cuenta' },
  { href: '/disenio', texto: 'Sistema de diseño', icono: 'disenio', grupo: 'Cuenta' },
] as const;

export default function PanelLayout({ children }: { children: ReactNode }) {
  return <Panel menu={MENU}>{children}</Panel>;
}
