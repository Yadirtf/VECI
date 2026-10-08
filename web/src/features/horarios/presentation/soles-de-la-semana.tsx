import { DIAS } from '../domain/agrupar-por-dia';
import type { Horario } from '../domain/horario';

/** Sol con un rayo por servicio activo; sin servicios es luna (ese día se descansa). */
function Sol({ rayos, pausados }: { rayos: number; pausados: boolean }) {
  if (rayos === 0 && !pausados) {
    return (
      <svg viewBox="0 0 40 40" className="h-10 w-10" aria-hidden>
        <path d="M 26 8 A 13 13 0 1 0 26 32 A 10 10 0 1 1 26 8 Z" fill="var(--color-borde)" />
      </svg>
    );
  }
  const n = Math.max(rayos, 1) * 4;
  return (
    <svg viewBox="0 0 40 40" className="h-10 w-10" aria-hidden opacity={rayos === 0 ? 0.4 : 1}>
      {Array.from({ length: n }, (_, i) => (
        <line
          key={i}
          x1={20}
          y1={4}
          x2={20}
          y2={9}
          stroke="var(--color-maiz)"
          strokeWidth={2.5}
          strokeLinecap="round"
          transform={`rotate(${(360 / n) * i} 20 20)`}
        />
      ))}
      <circle cx={20} cy={20} r={9} fill="var(--color-maiz)" />
    </svg>
  );
}

/**
 * La semana como siete soles en fila ondulada: de un vistazo se ve qué días se
 * atiende (más rayos, más servicios) y cuáles se descansa (luna).
 */
export function SolesDeLaSemana(p: {
  horarios: Horario[];
  dia: string;
  alElegir(dia: string): void;
}) {
  return (
    <div
      role="radiogroup"
      aria-label="Día de la semana"
      className="grid grid-cols-7 gap-xs pb-m pt-m"
    >
      {DIAS.map(([codigo, nombre], i) => {
        const delDia = p.horarios.filter((h) => h.dia === codigo);
        const activos = delDia.filter((h) => h.activo).length;
        const elegido = codigo === p.dia;
        return (
          <button
            key={codigo}
            type="button"
            role="radio"
            aria-checked={elegido}
            onClick={() => p.alElegir(codigo)}
            style={{ transform: `translateY(${Math.sin(i * 0.9) * 8}px)` }}
            className={`flex min-h-toque-minimo min-w-0 flex-col items-center gap-xs rounded-l px-0 py-xs sm:px-s transition-colors focus-visible:outline-4 focus-visible:outline-maiz ${elegido ? 'bg-arcilla-claro' : 'hover:bg-selva-claro'}`}
          >
            <Sol rayos={activos} pausados={delDia.length > activos} />
            <span
              className={`text-pequeno ${elegido ? 'font-fuerte text-arcilla' : 'text-tinta-suave'}`}
            >
              {nombre.slice(0, 3)}
            </span>
          </button>
        );
      })}
    </div>
  );
}
