/** Pesos de la DIAN para el dígito de verificación, de derecha a izquierda. */
const PESOS = [3, 7, 13, 17, 19, 23, 29, 37, 41, 43, 47, 53, 59, 67, 71];

export const soloDigitos = (texto: string): string => texto.replace(/\D/g, '');

/** Dígito de verificación de un NIT (módulo 11). VECI lo calcula: nadie tiene que teclearlo. */
export function digitoVerificacion(base: string): number {
  const suma = [...base]
    .reverse()
    .reduce((total, digito, i) => total + Number(digito) * PESOS[i], 0);
  const residuo = suma % 11;
  return residuo > 1 ? 11 - residuo : residuo;
}

/** "800197268" → "800.197.268" mientras se escribe. */
export function conPuntos(digitos: string): string {
  return digitos.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

/** NIT guardado (base + dígito) como se lee: 800.197.268-4. */
export function nitLegible(numero: string): string {
  return `${conPuntos(numero.slice(0, -1))}-${numero.slice(-1)}`;
}
