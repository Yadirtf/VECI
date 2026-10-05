import type { ReactNode } from 'react';

type Tono = 'exito' | 'aviso' | 'error';

// El sello cambia de forma con el tono (círculo, triángulo, octágono): el color
// nunca es la única señal.
const ESTILOS: Record<Tono, { papel: string; sello: string; forma: string; icono: string }> = {
  exito: {
    papel: '[--papel:var(--color-exito-fondo)] text-exito',
    sello: 'bg-exito text-exito-fondo',
    forma: 'rounded-total',
    icono: '✓',
  },
  aviso: {
    papel: '[--papel:var(--color-aviso-fondo)] text-aviso',
    sello: 'bg-aviso text-aviso-fondo pt-3',
    forma: '[clip-path:polygon(50%_4%,100%_96%,0_96%)]',
    icono: '!',
  },
  error: {
    papel: '[--papel:var(--color-error-fondo)] text-error',
    sello: 'bg-error text-error-fondo',
    forma: '[clip-path:polygon(30%_0,70%_0,100%_30%,100%_70%,70%_100%,30%_100%,0_70%,0_30%)]',
    icono: '✕',
  },
};

const ROLES: Record<Tono, 'status' | 'alert'> = {
  exito: 'status',
  aviso: 'status',
  error: 'alert',
};

/** Mensaje en tono VECI, en un papelito perforado: dice qué pasó y qué hacer, sin culpar a nadie. */
export function Aviso({ tono, children }: { tono: Tono; children: ReactNode }) {
  const e = ESTILOS[tono];
  return (
    <p
      role={ROLES[tono]}
      className={`papelito perforado flex items-center gap-m px-m pb-m text-cuerpo font-medio ${e.papel}`}
    >
      <span
        aria-hidden="true"
        className={`grid size-10 shrink-0 place-items-center text-subtitulo font-fuerte ${e.sello} ${e.forma}`}
      >
        {e.icono}
      </span>
      <span>{children}</span>
    </p>
  );
}
