'use client';

import Link from 'next/link';
import { RegistrarNegocio } from '@/features/comercios';
import { ConSesion } from '@/features/sesion';

export default function RegistrarPage() {
  return (
    <ConSesion>
      {(nombre) => (
        <main className="flex min-h-screen flex-col gap-l px-m py-xl">
          <p className="mx-auto w-full max-w-[36rem] text-subtitulo text-tinta-suave">
            Hola, {nombre.split(' ')[0]}. Cuéntanos de tu negocio, una cosa a la vez.
          </p>
          <RegistrarNegocio />
          <Link href="/" className="mx-auto text-cuerpo text-selva-oscuro underline">
            Ahora no
          </Link>
        </main>
      )}
    </ConSesion>
  );
}
