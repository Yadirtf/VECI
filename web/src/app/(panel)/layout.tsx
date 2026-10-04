import Link from 'next/link';
import type { ReactNode } from 'react';

export default function PanelLayout({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen">
      <header className="bg-selva-oscuro text-superficie">
        <nav className="mx-auto flex max-w-5xl items-center gap-l px-m py-m text-subtitulo">
          <Link href="/" className="text-titulo font-fuerte">
            VECI
          </Link>
          <Link href="/horarios" className="font-medio hover:underline">
            Horarios
          </Link>
          <Link href="/disenio" className="font-medio hover:underline">
            Sistema de diseño
          </Link>
        </nav>
      </header>
      <main className="mx-auto flex max-w-5xl flex-col gap-l px-m py-xl">{children}</main>
    </div>
  );
}
