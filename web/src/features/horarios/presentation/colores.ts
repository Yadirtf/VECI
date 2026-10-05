/** Cada servicio con su color de la tierra; se repiten si hay más de tres. */
const COLORES = ['var(--color-maiz)', 'var(--color-selva)', 'var(--color-arcilla)'];

export const colorDeServicio = (indice: number) => COLORES[Math.max(indice, 0) % COLORES.length];
