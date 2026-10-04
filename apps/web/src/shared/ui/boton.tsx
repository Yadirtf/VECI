import type { ButtonHTMLAttributes } from 'react';

type Variante = 'primario' | 'secundario' | 'peligro';

const VARIANTES: Record<Variante, string> = {
  primario: 'bg-selva text-superficie hover:bg-selva-oscuro',
  secundario: 'bg-superficie text-selva-oscuro border-2 border-selva hover:bg-selva-claro',
  peligro: 'bg-error text-superficie hover:opacity-90',
};

export interface BotonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variante?: Variante;
  grande?: boolean;
}

/** Botón VECI: grande, de alto contraste y fácil de tocar (RNF-USA-02). */
export function Boton({
  variante = 'primario',
  grande = false,
  className = '',
  ...props
}: BotonProps) {
  const alto = grande ? 'min-h-toque-boton-grande text-titulo' : 'min-h-toque-boton text-subtitulo';
  return (
    <button
      type="button"
      className={`${VARIANTES[variante]} ${alto} rounded-m px-l font-medio transition-colors focus-visible:outline-4 focus-visible:outline-offset-2 focus-visible:outline-maiz disabled:opacity-50 ${className}`}
      {...props}
    />
  );
}
