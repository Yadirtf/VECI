import type { Sede } from '../domain/sede';

export interface Lugar {
  x: number;
  y: number;
}

function Dibujo({ sede }: { sede: Sede }) {
  const color = sede.activa ? 'var(--color-arcilla)' : 'var(--color-borde)';
  return (
    <>
      <path d="M -26 -2 L 0 -26 L 26 -2 Z" fill={color} />
      <rect
        x={-20}
        y={-2}
        width={40}
        height={24}
        fill="var(--color-crema)"
        stroke={color}
        strokeWidth={2}
        strokeDasharray={sede.activa ? undefined : '4 3'}
      />
      <rect x={-5} y={8} width={10} height={14} fill={color} />
      {sede.principal && (
        <path
          d="M 14 -18 L 14 -36 L 26 -31 L 14 -27"
          fill="var(--color-selva)"
          stroke="var(--color-selva-oscuro)"
          strokeWidth={1.5}
        />
      )}
    </>
  );
}

/** Casa del caserío: la principal es más grande y lleva bandera; la cerrada, pálida. */
export function Casita({
  sede,
  lugar,
  elegida,
  alElegir,
}: {
  sede: Sede;
  lugar: Lugar;
  elegida: boolean;
  alElegir(): void;
}) {
  const escala = sede.principal ? 1.6 : 1.3;
  return (
    <g
      transform={`translate(${lugar.x} ${lugar.y}) scale(${escala})`}
      role="button"
      tabIndex={0}
      aria-pressed={elegida}
      aria-label={`Sede ${sede.nombre}${sede.activa ? '' : ', cerrada'}`}
      onClick={alElegir}
      onKeyDown={(e) => (e.key === 'Enter' || e.key === ' ') && alElegir()}
      className="cursor-pointer focus-visible:outline-none"
      opacity={sede.activa ? 1 : 0.55}
    >
      {elegida && <ellipse cx={0} cy={22} rx={34} ry={8} fill="var(--color-maiz)" />}
      <Dibujo sede={sede} />
      <text y={40} textAnchor="middle" fontSize={11} fontWeight={700} fill="var(--color-tinta)">
        {sede.nombre}
      </text>
    </g>
  );
}

/** El lugar vacío para otra casa: con Pro se arma; sin Pro, invita sin estorbar. */
export function LoteLibre({
  lugar,
  puede,
  alElegir,
}: {
  lugar: Lugar;
  puede: boolean;
  alElegir(): void;
}) {
  return (
    <g
      transform={`translate(${lugar.x} ${lugar.y}) scale(1.3)`}
      role="button"
      tabIndex={0}
      aria-label={puede ? 'Armar otra sede' : 'Con el plan Pro armas otra sede'}
      onClick={alElegir}
      onKeyDown={(e) => (e.key === 'Enter' || e.key === ' ') && alElegir()}
      className="cursor-pointer focus-visible:outline-none"
    >
      <path
        d="M -26 -2 L 0 -26 L 26 -2 L 20 -2 L 20 22 L -20 22 L -20 -2 Z"
        fill="none"
        stroke="var(--color-tinta-suave)"
        strokeWidth={2}
        strokeDasharray="5 4"
      />
      <text y={14} textAnchor="middle" fontSize={22} fill="var(--color-tinta-suave)">
        +
      </text>
      <text y={38} textAnchor="middle" fontSize={10} fill="var(--color-tinta-suave)">
        {puede ? 'Otra casa' : 'Con Pro armas'}
      </text>
      {!puede && (
        <text y={50} textAnchor="middle" fontSize={10} fill="var(--color-tinta-suave)">
          otra casa
        </text>
      )}
    </g>
  );
}
