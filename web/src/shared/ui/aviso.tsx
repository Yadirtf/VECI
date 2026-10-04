import type { ReactNode } from 'react';

type Tono = 'exito' | 'aviso' | 'error';

const ESTILOS: Record<Tono, string> = {
  exito: 'bg-exito-fondo text-exito border-exito',
  aviso: 'bg-aviso-fondo text-aviso border-aviso',
  error: 'bg-error-fondo text-error border-error',
};

const ROLES: Record<Tono, 'status' | 'alert'> = {
  exito: 'status',
  aviso: 'status',
  error: 'alert',
};

/** Mensaje en tono VECI: dice qué pasó y qué hacer, sin culpar a nadie. */
export function Aviso({ tono, children }: { tono: Tono; children: ReactNode }) {
  return (
    <p
      role={ROLES[tono]}
      className={`rounded-m border-l-8 p-m text-cuerpo font-medio ${ESTILOS[tono]}`}
    >
      {children}
    </p>
  );
}
