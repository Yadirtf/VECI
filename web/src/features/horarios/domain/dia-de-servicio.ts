import { ajustar, aMinutos, MINIMO } from './arco';
import type { Horario } from './horario';

export interface Limites {
  /** Lo más temprano que puede empezar: donde termina el servicio anterior. */
  minInicio: number;
  /** Lo más tarde que puede terminar: donde empieza el siguiente. */
  maxFin: number;
}

const FIN_DEL_DIA = 23 * 60 + 45;

/** Horarios activos de la misma sede y día, sin el que se está moviendo. */
function vecinos(horarios: readonly Horario[], h: Horario): Horario[] {
  return horarios.filter(
    (o) => o.id !== h.id && o.activo && o.sedeId === h.sedeId && o.dia === h.dia,
  );
}

/**
 * Hasta dónde se puede estirar un servicio sin pisar a sus vecinos. Así la regla
 * "no se cruzan" (HU-03-02) se siente en el dedo y no como un error después.
 */
export function limitesDe(horarios: readonly Horario[], h: Horario): Limites {
  const inicio = aMinutos(h.horaInicio);
  const otros = vecinos(horarios, h);
  const antes = otros.map((o) => aMinutos(o.horaFin)).filter((fin) => fin <= inicio);
  const despues = otros
    .map((o) => aMinutos(o.horaInicio))
    .filter((ini) => ini >= aMinutos(h.horaFin));
  return {
    minInicio: antes.length ? Math.max(...antes) : 0,
    maxFin: despues.length ? Math.min(...despues) : FIN_DEL_DIA,
  };
}

export type Extremo = 'inicio' | 'fin';

/** Mueve un extremo respetando el cuarto de hora, el mínimo y los vecinos. */
export function moverExtremo(
  rango: { inicio: number; fin: number },
  extremo: Extremo,
  minutos: number,
  limites: Limites,
): { inicio: number; fin: number } {
  const valor = ajustar(minutos);
  if (extremo === 'inicio') {
    return { ...rango, inicio: Math.min(Math.max(valor, limites.minInicio), rango.fin - MINIMO) };
  }
  return { ...rango, fin: Math.max(Math.min(valor, limites.maxFin), rango.inicio + MINIMO) };
}

/** Primer hueco libre de la duración pedida desde las 6 a. m.; null si el día está lleno. */
export function primerHueco(
  horarios: readonly Horario[],
  duracion = 120,
): { inicio: number; fin: number } | null {
  const ocupados = horarios
    .filter((h) => h.activo)
    .map((h) => ({ inicio: aMinutos(h.horaInicio), fin: aMinutos(h.horaFin) }))
    .sort((a, b) => a.inicio - b.inicio);
  let cursor = 6 * 60;
  for (const o of ocupados) {
    if (o.inicio - cursor >= duracion) break;
    cursor = Math.max(cursor, o.fin);
  }
  return cursor + duracion <= 22 * 60 ? { inicio: cursor, fin: cursor + duracion } : null;
}
