// Contraste WCAG 2.x entre dos colores hexadecimales (#RRGGBB).
function luminancia(hex) {
  const canales = [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16) / 255);
  const [r, g, b] = canales.map((c) => (c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4));
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

export function contraste(hexA, hexB) {
  const [claro, oscuro] = [luminancia(hexA), luminancia(hexB)].sort((a, b) => b - a);
  return (claro + 0.05) / (oscuro + 0.05);
}

/** Devuelve los pares que no alcanzan su mínimo; vacío si todos cumplen. */
export function paresSinContraste(colores, pares) {
  return pares
    .map(([texto, fondo, minimo]) => ({
      texto,
      fondo,
      minimo,
      valor: contraste(colores[texto], colores[fondo]),
    }))
    .filter((par) => par.valor < par.minimo);
}
