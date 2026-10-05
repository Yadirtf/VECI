import type { Metadata } from 'next';
import { Baloo_2, Nunito } from 'next/font/google';
import type { ReactNode } from 'react';
import { ProveedorSesion } from '@/features/sesion';
import './globals.css';

const nunito = Nunito({ subsets: ['latin'], variable: '--font-nunito', display: 'swap' });
// Títulos y cifras con letra de letrero pintado de tienda; el texto corrido sigue en Nunito.
const letrero = Baloo_2({
  subsets: ['latin'],
  weight: ['600', '800'],
  variable: '--font-letrero',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'VECI · Tu vecino aliado',
  description: 'Tiqueteras, consumos y clientes de tu negocio, en un solo lugar.',
};

export default function RaizLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="es-CO" className={`${nunito.variable} ${letrero.variable}`}>
      <body>
        <ProveedorSesion>{children}</ProveedorSesion>
      </body>
    </html>
  );
}
