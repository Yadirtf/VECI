'use client';

import { puedeAgregarSede } from '../domain/reglas-sedes';
import type { MapaDeSedes } from '../domain/sede';
import { Casita, LoteLibre, type Lugar } from './casita';

/** Las casas se reparten alrededor del patio (el negocio), no en una lista. */
function lugares(n: number): Lugar[] {
  return Array.from({ length: n }, (_, i) => {
    const angulo = Math.PI - (2 * Math.PI * i) / n + (n > 2 && i % 2 ? 0.15 : 0);
    return { x: 200 + 145 * Math.cos(angulo), y: 112 + 66 * Math.sin(angulo) };
  });
}

/**
 * Las sedes como un caserío alrededor del patio: la principal con bandera, las
 * cerradas pálidas y un lote libre para armar otra con el plan Pro (HU-03-03).
 */
export function Caserio(p: {
  mapa: MapaDeSedes;
  elegida: string | null;
  alElegir(id: string): void;
}) {
  const casas = [...p.mapa.sedes, null];
  const puestos = lugares(casas.length);
  return (
    <svg
      viewBox={casas.length <= 2 ? '-10 50 420 140' : '-10 0 420 230'}
      className="w-full max-w-2xl"
      role="group"
      aria-label="Tus sedes"
    >
      <ellipse cx={200} cy={118} rx={92} ry={38} fill="var(--color-selva-claro)" />
      <ellipse
        cx={200}
        cy={118}
        rx={92}
        ry={38}
        fill="none"
        stroke="var(--color-selva)"
        strokeWidth={1.5}
        strokeDasharray="2 6"
      />
      <text x={200} y={123} textAnchor="middle" fontSize={12} fill="var(--color-selva-oscuro)">
        {p.mapa.cupo.ocupadas} {p.mapa.cupo.ocupadas === 1 ? 'sede' : 'sedes'}
        {p.mapa.cupo.limite !== null ? ` de ${p.mapa.cupo.limite}` : ''}
      </text>
      {casas.map((sede, i) =>
        sede ? (
          <Casita
            key={sede.id}
            sede={sede}
            lugar={puestos[i]}
            elegida={sede.id === p.elegida}
            alElegir={() => p.alElegir(sede.id)}
          />
        ) : (
          <LoteLibre
            key="lote"
            lugar={puestos[i]}
            puede={puedeAgregarSede(p.mapa.cupo)}
            alElegir={() => p.alElegir('NUEVA')}
          />
        ),
      )}
    </svg>
  );
}
