import type { Metadata } from 'next';
import { Nunito } from 'next/font/google';
import type { ReactNode } from 'react';
import { ProveedorSesion } from '@/features/sesion';
import './globals.css';

const nunito = Nunito({ subsets: ['latin'], variable: '--font-nunito', display: 'swap' });

export const metadata: Metadata = {
  title: 'VECI · Tu vecino aliado',
  description: 'Tiqueteras, consumos y clientes de tu negocio, en un solo lugar.',
};

export default function RaizLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="es-CO" className={nunito.variable}>
      <body>
        <ProveedorSesion>{children}</ProveedorSesion>
      </body>
    </html>
  );
}
