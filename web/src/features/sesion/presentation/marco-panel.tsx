'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
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

const activa = (ruta: string, href: string) => ruta === href || ruta.startsWith(`${href}/`);

/** Encabezado en arco ("aquí estás") con el negocio activo y el menú en ventanillas. */
export function MarcoPanel(p: MarcoPanelProps) {
  return (
    <div className="min-h-screen">
      <header className="arco-abajo bg-selva-oscuro pb-l text-crema">
        <div className="mx-auto flex max-w-5xl flex-wrap items-end justify-between gap-m px-m pt-m">
          <div className="flex flex-col">
            <Link
              href="/"
              className="font-[family-name:var(--font-letrero)] text-grande leading-none font-fuerte text-maiz"
            >
              VECI
            </Link>
            <span className="text-subtitulo font-medio">{p.negocio}</span>
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
        <Menu menu={p.menu} />
      </header>
      <main className="mx-auto flex max-w-5xl flex-col gap-l px-m py-xl">{p.children}</main>
    </div>
  );
}

/** Menú en ventanillas: la de la página actual queda abierta, del color del fondo. */
function Menu({ menu }: { menu: MarcoPanelProps['menu'] }) {
  const ruta = usePathname() ?? '/';
  return (
    <nav
      aria-label="Menú del panel"
      className="mx-auto mt-m flex max-w-5xl flex-wrap gap-s px-m text-subtitulo"
    >
      {menu.map((item) => {
        const aqui = activa(ruta, item.href);
        return (
          <Link
            key={item.href}
            href={item.href}
            aria-current={aqui ? 'page' : undefined}
            className={`ventanilla inline-flex min-h-toque-minimo items-center px-l font-medio focus-visible:outline-4 focus-visible:outline-maiz ${
              aqui
                ? 'bg-crema text-selva-oscuro'
                : 'shadow-[inset_0_0_0_2px_var(--color-selva)] hover:bg-selva'
            }`}
          >
            {item.texto}
          </Link>
        );
      })}
    </nav>
  );
}
