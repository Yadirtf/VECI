import { useId, type InputHTMLAttributes } from 'react';

export interface CampoProps extends InputHTMLAttributes<HTMLInputElement> {
  etiqueta: string;
  ayuda?: string;
}

/** Campo como renglón de cuaderno: papel claro, línea gruesa abajo y etiqueta siempre visible. */
export function Campo({ etiqueta, ayuda, className = '', ...props }: CampoProps) {
  const id = useId();
  return (
    <label htmlFor={id} className="flex flex-col gap-xs text-cuerpo text-tinta">
      <span className="font-medio">{etiqueta}</span>
      <input
        id={id}
        className={`min-h-toque-boton rounded-t-[var(--radius-piedra-chica)] border-0 border-b-[3px] border-tinta bg-superficie px-m text-cuerpo focus:border-b-4 focus:border-selva focus:outline-4 focus:outline-offset-2 focus:outline-maiz ${className}`}
        {...props}
      />
      {ayuda && <span className="text-pequeno text-tinta-suave">{ayuda}</span>}
    </label>
  );
}
