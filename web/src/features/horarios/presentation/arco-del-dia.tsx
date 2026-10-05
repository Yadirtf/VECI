'use client';

import { useRef, type KeyboardEvent, type RefObject } from 'react';
import { horaLegible } from '../domain/agrupar-por-dia';
import {
  AMANECER,
  ANOCHECER,
  aHora,
  aMinutos,
  minutoEn,
  PASO_MINUTOS,
  puntoEn,
  tramo,
  type Arco,
} from '../domain/arco';
import type { Extremo } from '../domain/dia-de-servicio';
import type { Horario } from '../domain/horario';
import { useArrastre } from './use-arrastre';

const ARCO: Arco = { cx: 200, cy: 212, r: 160 };
const MARCAS = [6, 9, 12, 15, 18, 21];
const LOMAS =
  'M -440 210 Q -360 194 -280 204 T -120 200 T 40 204 T 200 206 T 360 200 T 520 204 T 680 200 T 840 206 L 840 400 L -440 400 Z';

export interface Segmento {
  horario: Horario;
  inicio: number;
  fin: number;
  color: string;
}

interface Props {
  segmentos: Segmento[];
  elegidoId: string | null;
  ahora: number | null;
  alElegir(h: Horario): void;
  alMover(extremo: Extremo, minutos: number): void;
  centro: { titulo: string; detalle: string };
}

function Fondo() {
  return (
    <>
      <path d={LOMAS} fill="var(--color-selva-claro)" />
      <path
        d={tramo(ARCO, 5 * 60, 22 * 60)}
        fill="none"
        stroke="var(--color-borde)"
        strokeWidth={2}
        strokeDasharray="1 7"
        strokeLinecap="round"
      />
      {MARCAS.map((h) => {
        const p = puntoEn(ARCO, h * 60, ARCO.r + 28);
        return (
          <text
            key={h}
            x={p.x}
            y={p.y}
            textAnchor="middle"
            dominantBaseline="middle"
            fontSize={14}
            fill="var(--color-tinta-suave)"
          >
            {h === 12 ? '12 m.' : horaLegible(aHora(h * 60)).replace(':00', '')}
          </text>
        );
      })}
    </>
  );
}

function Manija(p: {
  extremo: Extremo;
  minutos: number;
  alMover: Props['alMover'];
  svg: RefObject<SVGSVGElement | null>;
}) {
  const arrastre = useArrastre(p.svg, (punto) => p.alMover(p.extremo, minutoEn(ARCO, punto)));
  const { x, y } = puntoEn(ARCO, p.minutos);
  const teclas = (e: KeyboardEvent) => {
    const paso = {
      ArrowRight: PASO_MINUTOS,
      ArrowUp: PASO_MINUTOS,
      ArrowLeft: -PASO_MINUTOS,
      ArrowDown: -PASO_MINUTOS,
    }[e.key];
    if (!paso) return;
    e.preventDefault();
    p.alMover(p.extremo, p.minutos + paso);
  };
  return (
    <g
      role="slider"
      tabIndex={0}
      aria-label={p.extremo === 'inicio' ? 'Empieza' : 'Termina'}
      aria-valuemin={0}
      aria-valuemax={1439}
      aria-valuenow={p.minutos}
      aria-valuetext={horaLegible(aHora(p.minutos))}
      onKeyDown={teclas}
      {...arrastre}
      className="cursor-grab touch-none outline-none [&:focus-visible>circle:first-child]:stroke-maiz"
    >
      <circle cx={x} cy={y} r={22} fill="transparent" stroke="transparent" strokeWidth={3} />
      <circle
        cx={x}
        cy={y}
        r={11}
        fill="var(--color-superficie)"
        stroke="var(--color-tinta)"
        strokeWidth={3}
      />
    </g>
  );
}

function Tramo({
  s,
  elegido,
  alElegir,
}: {
  s: Segmento;
  elegido: boolean;
  alElegir(h: Horario): void;
}) {
  const etiqueta = `${s.horario.servicioNombre}, ${horaLegible(aHora(s.inicio))} a ${horaLegible(aHora(s.fin))}${s.horario.activo ? '' : ', en pausa'}`;
  return (
    <path
      d={tramo(ARCO, s.inicio, s.fin)}
      fill="none"
      stroke={s.color}
      strokeWidth={elegido ? 34 : 26}
      strokeLinecap="round"
      strokeDasharray={s.horario.activo ? undefined : '4 6'}
      opacity={s.horario.activo ? 1 : 0.4}
      role="button"
      tabIndex={0}
      aria-label={etiqueta}
      aria-pressed={elegido}
      onClick={() => alElegir(s.horario)}
      onKeyDown={(e) => (e.key === 'Enter' || e.key === ' ') && alElegir(s.horario)}
      className="cursor-pointer outline-none focus-visible:[stroke-width:40px]"
    >
      <title>{etiqueta}</title>
    </path>
  );
}

/**
 * El día como el camino del sol (HU-03-02): cada servicio es un tramo grueso del arco
 * y el elegido se estira desde sus extremos. Se detiene solo contra sus vecinos.
 */
export function ArcoDelDia(p: Props) {
  const svg = useRef<SVGSVGElement>(null);
  const elegido = p.segmentos.find((s) => s.horario.id === p.elegidoId);
  const deDia = p.ahora !== null && p.ahora >= AMANECER && p.ahora <= ANOCHECER;
  const sol = deDia ? puntoEn(ARCO, p.ahora ?? 0, ARCO.r - 34) : null;
  return (
    <svg
      ref={svg}
      viewBox="-40 0 480 240"
      overflow="visible"
      className="w-full max-w-2xl select-none"
      role="group"
      aria-label="Camino del sol del día"
    >
      <Fondo />
      {p.segmentos.map((s) => (
        <Tramo key={s.horario.id} s={s} elegido={s === elegido} alElegir={p.alElegir} />
      ))}
      {sol && (
        <circle
          cx={sol.x}
          cy={sol.y}
          r={7}
          fill="var(--color-maiz)"
          stroke="var(--color-arcilla)"
          strokeWidth={2}
        >
          <title>Ahora</title>
        </circle>
      )}
      {elegido &&
        (['inicio', 'fin'] as const).map((e) => (
          <Manija key={e} extremo={e} minutos={elegido[e]} alMover={p.alMover} svg={svg} />
        ))}
      <text
        x={200}
        y={168}
        textAnchor="middle"
        fontSize={26}
        fontWeight={800}
        fill="var(--color-selva-oscuro)"
      >
        {p.centro.titulo}
      </text>
      <text x={200} y={192} textAnchor="middle" fontSize={16} fill="var(--color-tinta-suave)">
        {p.centro.detalle}
      </text>
    </svg>
  );
}

export const minutosDe = (h: Horario) => ({
  inicio: aMinutos(h.horaInicio),
  fin: aMinutos(h.horaFin),
});
