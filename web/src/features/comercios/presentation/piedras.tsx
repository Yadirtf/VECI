export interface Piedra {
  etiqueta: string;
  lista: boolean;
  actual?: boolean;
}

/** Forma de piedra de río, un poco distinta en cada posición para que no se vea en serie. */
function contornoPiedra(cx: number, cy: number, r: number, i: number): string {
  const sesgo = [0.9, 1.1, 0.95, 1.05, 1, 0.92][i % 6];
  const rx = r * 1.25 * sesgo;
  const ry = r * (2 - sesgo) * 0.85;
  return `M ${cx - rx} ${cy}
    C ${cx - rx} ${cy - ry * 1.1}, ${cx + rx * 0.7} ${cy - ry * 1.2}, ${cx + rx} ${cy - ry * 0.1}
    C ${cx + rx * 1.1} ${cy + ry * 0.9}, ${cx - rx * 0.6} ${cy + ry * 1.2}, ${cx - rx} ${cy} Z`;
}

/**
 * El avance como piedras para cruzar la quebrada: cada paso hecho es una piedra
 * pisada (maíz), la actual es selva y las que faltan son solo contorno.
 */
export function CaminoDePiedras({ piedras, titulo }: { piedras: Piedra[]; titulo: string }) {
  const ancho = 320;
  const paso = ancho / piedras.length;
  const centros = piedras.map((_, i) => ({ x: paso * (i + 0.5), y: 26 + (i % 2 ? -8 : 8) }));
  const agua = `M 0 34 Q ${ancho / 4} 14, ${ancho / 2} 34 T ${ancho} 34`;
  return (
    <svg viewBox={`0 0 ${ancho} 60`} role="img" aria-label={titulo} className="w-full max-w-md">
      <path
        d={agua}
        fill="none"
        stroke="var(--color-selva-claro)"
        strokeWidth={14}
        strokeLinecap="round"
      />
      {piedras.map((p, i) => (
        <path
          key={p.etiqueta}
          d={contornoPiedra(centros[i].x, centros[i].y, p.actual ? 13 : 10, i)}
          fill={
            p.actual ? 'var(--color-selva)' : p.lista ? 'var(--color-maiz)' : 'var(--color-crema)'
          }
          stroke={p.lista || p.actual ? 'none' : 'var(--color-borde)'}
          strokeWidth={2}
        >
          <title>{`${p.etiqueta}${p.lista ? ' · listo' : ''}`}</title>
        </path>
      ))}
    </svg>
  );
}
