import type { ButtonHTMLAttributes } from 'react';

type Variante = 'primario' | 'secundario' | 'peligro';

// Cada variante es una piedra con canto; la de peligro lleva esquinas cortadas
// (no se puede deshacer), así la forma avisa además del color.
const VARIANTES: Record<Variante, string> = {
  primario:
    'piedra [--tecla-fondo:var(--color-selva)] [--tecla-texto:var(--color-superficie)] [--tecla-canto:var(--color-selva-oscuro)]',
  secundario:
    'piedra [--tecla-fondo:var(--color-superficie)] [--tecla-texto:var(--color-selva-oscuro)] [--tecla-canto:var(--color-tinta)] [--tecla-borde:3px]',
  peligro:
    '[--tecla-recorte:var(--poligono-chaflan)] [--tecla-fondo:var(--color-error)] [--tecla-texto:var(--color-superficie)] [--tecla-canto:var(--color-error-oscuro)]',
};

export interface BotonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variante?: Variante;
  grande?: boolean;
}

/** Clases del botón VECI, para dar la misma forma a un enlace (`<Link className={clasesBoton()}>`). */
export function clasesBoton(variante: Variante = 'primario', grande = false): string {
  const alto = grande ? 'min-h-toque-boton-grande text-titulo' : 'min-h-toque-boton text-subtitulo';
  return `tecla ${VARIANTES[variante]} ${alto} inline-flex items-center justify-center px-l font-fuerte focus-visible:outline-4 focus-visible:outline-offset-4 focus-visible:outline-maiz`;
}

/** Botón VECI: una piedra con canto que baja al tocarla, grande y de alto contraste (RNF-USA-02). */
export function Boton({
  variante = 'primario',
  grande = false,
  className = '',
  ...props
}: BotonProps) {
  return (
    <button type="button" className={`${clasesBoton(variante, grande)} ${className}`} {...props} />
  );
}
