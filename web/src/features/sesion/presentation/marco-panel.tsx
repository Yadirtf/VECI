'use client';

import Link from 'next/link';
import type { ReactNode } from 'react';

export interface MarcoPanelProps {
  negocio: string;
  nombre: string;
  menu: ReadonlyArray<{ href: string; texto: string }>;
  puedeCambiarNegocio: boolean;
  alCambiarNegocio(): void;
  alSalir(): void;
  children: ReactNode;
}

/** Encabezado del panel con el negocio activo, el menú y la salida. */
export function MarcoPanel(p: MarcoPanelProps) {
  return (
    <div className="min-h-screen">
      <header className="bg-selva-oscuro text-superficie">
        <div className="mx-auto flex max-w-5xl flex-wrap items-center justify-between gap-m px-m py-s">
          <div>
            <Link href="/" className="text-titulo font-fuerte">
              VECI
            </Link>
            <span className="ml-m text-cuerpo">{p.negocio}</span>
          </div>
          <div className="flex items-center gap-m text-cuerpo">
            <span>Hola, {p.nombre}</span>
            {p.puedeCambiarNegocio && (
              <button type="button" className="underline" onClick={p.alCambiarNegocio}>
                Cambiar de negocio
              </button>
            )}
            <button type="button" className="font-medio underline" onClick={p.alSalir}>
              Salir
            </button>
          </div>
        </div>
        <nav
          aria-label="Menú del panel"
          className="mx-auto flex max-w-5xl flex-wrap gap-l px-m pb-m text-subtitulo"
        >
          {p.menu.map((item) => (
            <Link key={item.href} href={item.href} className="font-medio hover:underline">
              {item.texto}
            </Link>
          ))}
        </nav>
      </header>
      <main className="mx-auto flex max-w-5xl flex-col gap-l px-m py-xl">{p.children}</main>
    </div>
  );
}
