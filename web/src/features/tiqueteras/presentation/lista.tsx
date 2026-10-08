import { useId, type SelectHTMLAttributes } from 'react';

export interface ListaProps extends SelectHTMLAttributes<HTMLSelectElement> {
  etiqueta: string;
  opciones: readonly { valor: string; texto: string }[];
  /** Primer renglón vacío: obliga a elegir. */
  vacio?: string;
}

/** Una lista para elegir, con la misma etiqueta siempre visible de los campos. */
export function Lista({ etiqueta, opciones, vacio, ...props }: ListaProps) {
  const id = useId();
  return (
    <label htmlFor={id} className="flex flex-col gap-xs text-cuerpo text-tinta">
      <span className="font-medio">{etiqueta}</span>
      <select
        id={id}
        className="min-h-toque-boton rounded-m border-2 border-borde bg-superficie px-m"
        {...props}
      >
        {vacio !== undefined && <option value="">{vacio}</option>}
        {opciones.map((o) => (
          <option key={o.valor} value={o.valor}>
            {o.texto}
          </option>
        ))}
      </select>
    </label>
  );
}
