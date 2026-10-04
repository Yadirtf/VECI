const formatoPesos = new Intl.NumberFormat('es-CO', {
  style: 'currency',
  currency: 'COP',
  maximumFractionDigits: 0,
});

/** Formatea un valor en pesos colombianos sin decimales: 330000 → "$ 330.000". */
export function formatearPesos(valor: number): string {
  return formatoPesos.format(valor).replace(/\s/g, ' ');
}
