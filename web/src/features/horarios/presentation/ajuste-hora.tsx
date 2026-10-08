import { horaLegible } from '../domain/agrupar-por-dia';
import { aHora, PASO_MINUTOS } from '../domain/arco';

/** Una hora que se afina de a cuarto de hora con botones grandes, buenos para el dedo. */
export function AjusteHora(p: { etiqueta: string; minutos: number; alCambiar(m: number): void }) {
  const boton =
    'h-toque-boton w-toque-boton shrink-0 rounded-total border-2 border-selva text-titulo font-fuerte text-selva-oscuro hover:bg-selva-claro';
  return (
    <div className="flex items-center gap-s">
      <button
        type="button"
        className={boton}
        aria-label={`${p.etiqueta} 15 minutos antes`}
        onClick={() => p.alCambiar(p.minutos - PASO_MINUTOS)}
      >
        −
      </button>
      <p className="min-w-32 text-center">
        <span className="block text-pequeno text-tinta-suave">{p.etiqueta}</span>
        <span className="text-titulo font-fuerte">{horaLegible(aHora(p.minutos))}</span>
      </p>
      <button
        type="button"
        className={boton}
        aria-label={`${p.etiqueta} 15 minutos después`}
        onClick={() => p.alCambiar(p.minutos + PASO_MINUTOS)}
      >
        +
      </button>
    </div>
  );
}

/** Empieza y termina, uno al lado del otro (o uno debajo del otro en el celular). */
export function HorasDelServicio(p: {
  rango: { inicio: number; fin: number };
  alMover(extremo: 'inicio' | 'fin', minutos: number): void;
}) {
  return (
    <div className="flex flex-wrap items-center gap-l">
      <AjusteHora
        etiqueta="Empieza"
        minutos={p.rango.inicio}
        alCambiar={(m) => p.alMover('inicio', m)}
      />
      <AjusteHora etiqueta="Termina" minutos={p.rango.fin} alCambiar={(m) => p.alMover('fin', m)} />
    </div>
  );
}
