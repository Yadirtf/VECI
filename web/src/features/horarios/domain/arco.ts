/**
 * Geometría del "camino del sol": el día de servicio es un arco de 5 a. m. (oriente,
 * a la izquierda) a 10 p. m. (occidente, a la derecha). Funciones puras para poder
 * probarlas sin pantalla.
 */
export const AMANECER = 5 * 60;
export const ANOCHECER = 22 * 60;
export const PASO_MINUTOS = 15;
/** El servicio más corto que se puede dibujar o guardar. */
export const MINIMO = PASO_MINUTOS;

export interface Punto {
  x: number;
  y: number;
}

export interface Arco {
  cx: number;
  cy: number;
  r: number;
}

/** "06:30" → 390 */
export function aMinutos(hora: string): number {
  const [h, m] = hora.split(':').map(Number);
  return h * 60 + m;
}

/** 390 → "06:30" (el API la pide así). */
export function aHora(minutos: number): string {
  const h = Math.floor(minutos / 60);
  return `${String(h).padStart(2, '0')}:${String(minutos % 60).padStart(2, '0')}`;
}

export const limitar = (valor: number, minimo: number, maximo: number) =>
  Math.min(Math.max(valor, minimo), maximo);

/** Redondea al cuarto de hora más cercano: con el dedo nadie apunta a las 11:37. */
export const ajustar = (minutos: number) => Math.round(minutos / PASO_MINUTOS) * PASO_MINUTOS;

/** Ángulo (radianes) del sol a esa hora: π al amanecer, 0 al anochecer. */
export function angulo(minutos: number): number {
  const fraccion = (limitar(minutos, AMANECER, ANOCHECER) - AMANECER) / (ANOCHECER - AMANECER);
  return Math.PI * (1 - fraccion);
}

export function puntoEn(arco: Arco, minutos: number, radio = arco.r): Punto {
  const a = angulo(minutos);
  return { x: arco.cx + radio * Math.cos(a), y: arco.cy - radio * Math.sin(a) };
}

/** Hora que corresponde a un punto tocado; debajo del horizonte cuenta el extremo más cercano. */
export function minutoEn(arco: Arco, p: Punto): number {
  const a = Math.atan2(arco.cy - p.y, p.x - arco.cx);
  const sobreHorizonte = a >= 0 ? a : p.x < arco.cx ? Math.PI : 0;
  return ajustar(AMANECER + (1 - sobreHorizonte / Math.PI) * (ANOCHECER - AMANECER));
}

/** Trazo SVG del tramo del arco entre dos horas. */
export function tramo(arco: Arco, desde: number, hasta: number, radio = arco.r): string {
  const a = puntoEn(arco, desde, radio);
  const b = puntoEn(arco, hasta, radio);
  return `M ${a.x.toFixed(2)} ${a.y.toFixed(2)} A ${radio} ${radio} 0 0 1 ${b.x.toFixed(2)} ${b.y.toFixed(2)}`;
}
