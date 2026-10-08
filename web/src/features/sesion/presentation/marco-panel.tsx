'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useCallback, useEffect, useRef, useState, type ReactNode } from 'react';
import { Icono } from '@/shared/ui';
import {
  activa,
  FOCO,
  Marca,
  MenuLateral,
  type ItemMenu,
  type MenuLateralProps,
} from './menu-lateral';

export type { ItemMenu } from './menu-lateral';

export interface MarcoPanelProps extends Omit<MenuLateralProps, 'ruta' | 'alCerrar'> {
  children: ReactNode;
}

/**
 * Marco del panel. En PC el menú es una barra lateral fija; en celular y tablet queda
 * detrás de un botón en la barra de arriba y se abre como un cajón desde la izquierda.
 */
export function MarcoPanel({ children, ...p }: MarcoPanelProps) {
  const ruta = usePathname() ?? '/';
  const [abierto, setAbierto] = useState(false);
  const boton = useRef<HTMLButtonElement>(null);

  // Al cambiar de página el cajón se cierra solo.
  const [rutaPrevia, setRutaPrevia] = useState(ruta);
  if (rutaPrevia !== ruta) {
    setRutaPrevia(ruta);
    setAbierto(false);
  }

  const cerrar = useCallback(() => {
    setAbierto(false);
    boton.current?.focus();
  }, []);

  return (
    <div className="min-h-screen lg:grid lg:grid-cols-[18rem_minmax(0,1fr)]">
      <a
        href="#contenido"
        className={`sr-only z-50 rounded-s bg-maiz px-m py-s font-medio text-tinta focus:not-sr-only focus:fixed focus:top-s focus:left-s ${FOCO}`}
      >
        Saltar al contenido
      </a>
      <BarraSuperior
        negocio={p.negocio}
        menu={p.menu}
        ruta={ruta}
        abierto={abierto}
        boton={boton}
        alAbrir={() => setAbierto(true)}
      />
      <aside className="sticky top-0 hidden h-screen lg:block">
        <MenuLateral {...p} ruta={ruta} />
      </aside>
      {abierto && <Cajon {...p} ruta={ruta} alCerrar={cerrar} />}
      <main
        id="contenido"
        tabIndex={-1}
        className="mx-auto flex w-full max-w-6xl min-w-0 flex-col gap-l px-m py-l outline-none sm:px-l sm:py-xl lg:px-xl"
      >
        {children}
      </main>
    </div>
  );
}

/** Celular y tablet: botón del menú, la marca y dónde estás (negocio y página). */
function BarraSuperior({
  boton,
  ...p
}: {
  negocio: string;
  menu: readonly ItemMenu[];
  ruta: string;
  abierto: boolean;
  boton: React.RefObject<HTMLButtonElement | null>;
  alAbrir(): void;
}) {
  const actual = p.menu.find((item) => activa(p.ruta, item.href));
  return (
    <header className="sticky top-0 z-30 flex min-h-16 items-center gap-s bg-selva-oscuro px-s text-crema shadow-[0_3px_0_var(--color-selva)] sm:px-m lg:hidden">
      <button
        ref={boton}
        type="button"
        aria-label="Abrir el menú"
        aria-expanded={p.abierto}
        aria-controls="menu-movil"
        onClick={p.alAbrir}
        className={`inline-flex size-toque-minimo shrink-0 items-center justify-center rounded-m hover:bg-selva ${FOCO}`}
      >
        <Icono nombre="menu" tamano={28} />
      </button>
      <Link href="/" className={`shrink-0 rounded-s ${FOCO}`}>
        <Marca />
      </Link>
      <div className="ml-auto flex min-w-0 flex-col items-end text-right leading-tight">
        <span className="w-full truncate text-pequeno font-medio">{p.negocio}</span>
        {actual && (
          <span className="w-full truncate text-pequeno text-crema/80">{actual.texto}</span>
        )}
      </div>
    </header>
  );
}

/** Cajón del celular: tapa la página y se cierra con Esc, tocando el fondo o con la X. */
function Cajon(p: MenuLateralProps & { alCerrar(): void }) {
  const panel = useRef<HTMLDivElement>(null);
  useCajon(panel, p.alCerrar);
  return (
    <div className="fixed inset-0 z-40 lg:hidden">
      <div aria-hidden="true" className="absolute inset-0 bg-tinta/60" onClick={p.alCerrar} />
      <div
        ref={panel}
        id="menu-movil"
        role="dialog"
        aria-modal="true"
        aria-label="Menú del panel"
        className="cajon-entra absolute inset-y-0 left-0 w-[min(20rem,88vw)] shadow-[4px_0_0_var(--color-sombra-papel)]"
      >
        <MenuLateral {...p} />
      </div>
    </div>
  );
}

/** Mientras el cajón está abierto: la página no se desplaza y el foco no sale de él. */
function useCajon(panel: React.RefObject<HTMLDivElement | null>, alCerrar: () => void) {
  useEffect(() => {
    const anterior = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    panel.current?.querySelector<HTMLElement>('a[href], button')?.focus();
    const alTeclear = (e: KeyboardEvent) => {
      if (e.key === 'Escape') return alCerrar();
      if (e.key !== 'Tab' || !panel.current) return;
      const enfocables = panel.current.querySelectorAll<HTMLElement>('a[href], button');
      const primero = enfocables[0];
      const ultimo = enfocables[enfocables.length - 1];
      if (e.shiftKey && document.activeElement === primero) {
        e.preventDefault();
        ultimo?.focus();
      } else if (!e.shiftKey && document.activeElement === ultimo) {
        e.preventDefault();
        primero?.focus();
      }
    };
    document.addEventListener('keydown', alTeclear);
    return () => {
      document.body.style.overflow = anterior;
      document.removeEventListener('keydown', alTeclear);
    };
  }, [panel, alCerrar]);
}
