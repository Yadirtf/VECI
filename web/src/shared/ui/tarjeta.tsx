import type { HTMLAttributes } from 'react';

export interface TarjetaProps extends HTMLAttributes<HTMLElement> {
  /** Fila de huecos arriba, como el talonario: úsela cuando VECI le habla a la persona. */
  perforado?: boolean;
}

/** Un papelito arrancado del talonario: dientes abajo y sombra dura, sin desenfoques. */
export function Tarjeta({ perforado = false, className = '', ...props }: TarjetaProps) {
  return (
    <section className={`papelito ${perforado ? 'perforado' : ''} p-l ${className}`} {...props} />
  );
}
