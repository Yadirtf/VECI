import { useId, type InputHTMLAttributes } from 'react';

export interface CampoProps extends InputHTMLAttributes<HTMLInputElement> {
  etiqueta: string;
  ayuda?: string;
}

/** Campo de texto con etiqueta visible y letra grande. */
export function Campo({ etiqueta, ayuda, className = '', ...props }: CampoProps) {
  const id = useId();
  return (
    <label htmlFor={id} className="flex flex-col gap-xs text-cuerpo text-tinta">
      <span className="font-medio">{etiqueta}</span>
      <input
        id={id}
        className={`min-h-toque-boton rounded-m border-2 border-borde bg-superficie px-m text-cuerpo focus:border-selva focus:outline-none ${className}`}
        {...props}
      />
      {ayuda && <span className="text-pequeno text-tinta-suave">{ayuda}</span>}
    </label>
  );
}
