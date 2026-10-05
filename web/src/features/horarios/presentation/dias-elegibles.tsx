import { DIAS } from '../domain/agrupar-por-dia';

/** Chips de días para elegir varios a la vez ("Igual en…"). */
export function DiasElegibles(p: {
  elegidos: string[];
  sin?: string;
  alCambiar(dias: string[]): void;
}) {
  const alternar = (codigo: string) =>
    p.alCambiar(
      p.elegidos.includes(codigo)
        ? p.elegidos.filter((d) => d !== codigo)
        : [...p.elegidos, codigo],
    );
  return (
    <div className="flex flex-wrap gap-s">
      {DIAS.filter(([codigo]) => codigo !== p.sin).map(([codigo, nombre]) => {
        const activo = p.elegidos.includes(codigo);
        return (
          <button
            key={codigo}
            type="button"
            aria-pressed={activo}
            onClick={() => alternar(codigo)}
            className={`min-h-toque-minimo rounded-total border-2 px-m text-cuerpo font-medio ${activo ? 'border-selva bg-selva text-superficie' : 'border-borde bg-superficie text-selva-oscuro hover:border-selva'}`}
          >
            {nombre}
          </button>
        );
      })}
    </div>
  );
}
