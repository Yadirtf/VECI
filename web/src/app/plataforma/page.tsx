'use client';

import Link from 'next/link';
import { SolicitudesDeNegocio } from '@/features/plataforma';
import { ConSesion } from '@/features/sesion';

export default function PlataformaPage() {
  return (
    <ConSesion>
      {() => (
        <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col gap-l px-m py-xl">
          <header className="flex flex-col gap-xs">
            <p className="text-subtitulo text-tinta-suave">Consola VECI</p>
            <h1 className="text-grande font-fuerte text-tinta">Solicitudes de negocio</h1>
          </header>
          <SolicitudesDeNegocio />
          <Link href="/" className="text-cuerpo text-selva-oscuro underline">
            Volver
          </Link>
        </main>
      )}
    </ConSesion>
  );
}
