import type { ReactNode } from 'react';
import { Panel } from '@/features/sesion';

const MENU = [
  { href: '/negocio', texto: 'Mi negocio' },
  { href: '/horarios', texto: 'Horarios' },
  { href: '/sedes', texto: 'Sedes' },
  { href: '/equipo', texto: 'Equipo' },
  { href: '/dispositivos', texto: 'Dispositivos' },
  { href: '/mi-cuenta', texto: 'Mi cuenta' },
  { href: '/disenio', texto: 'Sistema de diseño' },
];

export default function PanelLayout({ children }: { children: ReactNode }) {
  return <Panel menu={MENU}>{children}</Panel>;
}
