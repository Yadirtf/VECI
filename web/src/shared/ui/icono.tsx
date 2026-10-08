import type { SVGProps } from 'react';

// Trazos de 24×24 con línea redondeada, del mismo grosor en todo el panel.
const TRAZOS = {
  inicio: 'M3 10.5 12 3l9 7.5M5 9v11h5v-6h4v6h5V9',
  clientes:
    'M16 20v-1.5a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4V20M9.5 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7M21 20v-1.5a4 4 0 0 0-3-3.9M15.5 4.2a3.5 3.5 0 0 1 0 6.6',
  tiqueteras:
    'M3 8a2 2 0 0 0 2-2h14a2 2 0 0 0 2 2v2a2 2 0 0 0 0 4v2a2 2 0 0 0-2 2H5a2 2 0 0 0-2-2v-2a2 2 0 0 0 0-4zM10 6v12',
  ventas: 'M6 3h12v18l-3-2-3 2-3-2-3 2zM9 8h6M9 12h6M9 16h3',
  negocio:
    'M4 10v10h16V10M3 6l1.5-3h15L21 6v1.5a3 3 0 0 1-6 0 3 3 0 0 1-6 0 3 3 0 0 1-6 0zM10 20v-5h4v5',
  horarios: 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 7v5l3 2',
  sedes:
    'M12 21s7-6.2 7-11.5a7 7 0 0 0-14 0C5 14.8 12 21 12 21M12 12a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5',
  equipo: 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8M4 21v-1a6 6 0 0 1 6-6h4a6 6 0 0 1 6 6v1',
  dispositivos: 'M7 2h10a1 1 0 0 1 1 1v18a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1V3a1 1 0 0 1 1-1M11 18h2',
  cuenta:
    'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 13a3 3 0 1 0 0-6 3 3 0 0 0 0 6M6.2 18.5a6.5 6.5 0 0 1 11.6 0',
  disenio:
    'M12 21a9 9 0 1 1 9-9c0 2-1.5 3-3.5 3H15a2 2 0 0 0-1.5 3.3c.5.6.3 2.7-1.5 2.7M7.5 11.5h.01M10 7.5h.01M15 7.5h.01',
  menu: 'M4 6h16M4 12h16M4 18h16',
  cerrar: 'M6 6l12 12M18 6 6 18',
  salir: 'M15 4h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3M10 17l5-5-5-5M15 12H4',
  cambiar: 'M17 3l4 4-4 4M21 7H8M7 21l-4-4 4-4M3 17h13',
} as const;

export type NombreIcono = keyof typeof TRAZOS;

export interface IconoProps extends Omit<SVGProps<SVGSVGElement>, 'children'> {
  nombre: NombreIcono;
  tamano?: number;
}

/** Ícono de línea que acompaña al texto; es decorativo, el texto siempre dice qué es. */
export function Icono({ nombre, tamano = 24, ...props }: IconoProps) {
  return (
    <svg
      viewBox="0 0 24 24"
      width={tamano}
      height={tamano}
      fill="none"
      stroke="currentColor"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
      {...props}
    >
      <path d={TRAZOS[nombre]} />
    </svg>
  );
}
