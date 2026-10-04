import type { HTMLAttributes } from 'react';

/** Superficie blanca con borde suave para agrupar contenido. */
export function Tarjeta({ className = '', ...props }: HTMLAttributes<HTMLElement>) {
  return (
    <section
      className={`rounded-l border border-borde bg-superficie p-l shadow-sm ${className}`}
      {...props}
    />
  );
}
