import { DIAS } from '../domain/agrupar-por-dia';
import { ATAJOS } from '../domain/programacion';

const chip = (activo: boolean) =>
  `min-h-toque-minimo rounded-total border-2 px-m text-cuerpo font-medio ${activo ? 'border-selva bg-selva text-superficie' : 'border-borde bg-superficie text-selva-oscuro hover:border-selva'}`;

const mismos = (a: readonly string[], b: readonly string[]) =>
  a.length === b.length && a.every((d) => b.includes(d));

/** Días para elegir uno o varios a la vez, con atajos como "Lunes a viernes". */
export function DiasElegibles(p: { elegidos: string[]; alCambiar(dias: string[]): void }) {
  const alternar = (codigo: string) =>
    p.alCambiar(
      p.elegidos.includes(codigo)
        ? p.elegidos.filter((d) => d !== codigo)
        : [...p.elegidos, codigo],
    );
  return (
    <fieldset className="flex flex-col gap-s">
      <legend className="mb-s text-cuerpo font-medio text-selva-oscuro">¿Qué días?</legend>
      <div className="flex flex-wrap gap-s">
        {DIAS.map(([codigo, nombre]) => {
          const activo = p.elegidos.includes(codigo);
          return (
            <button
              key={codigo}
              type="button"
              aria-pressed={activo}
              onClick={() => alternar(codigo)}
              className={chip(activo)}
            >
              {nombre}
            </button>
          );
        })}
      </div>
      <div className="flex flex-wrap gap-xs" aria-label="Atajos de días">
        {ATAJOS.map((a) => (
          <button
            key={a.nombre}
            type="button"
            aria-pressed={mismos(a.dias, p.elegidos)}
            onClick={() => p.alCambiar(a.dias)}
            className="min-h-toque-minimo rounded-total px-s text-pequeno font-medio text-selva underline-offset-4 hover:underline aria-pressed:text-selva-oscuro aria-pressed:underline"
          >
            {a.nombre}
          </button>
        ))}
      </div>
    </fieldset>
  );
}
