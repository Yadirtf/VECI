/** PIN que la gente elige primero y que cualquiera prueba: se rechazan (HU-02-01). */
const COMUNES = new Set(['123123', '121212', '112233', '102030', '159753', '147258', '852456']);

function todosIguales(pin: string): boolean {
  return /^(\d)\1{5}$/.test(pin);
}

function esEscalera(pin: string): boolean {
  const pasos = [...pin].slice(1).map((d, i) => Number(d) - Number(pin[i]));
  return pasos.every((paso) => paso === 1) || pasos.every((paso) => paso === -1);
}

function repiteUnBloque(pin: string): boolean {
  return /^(\d\d)\1\1$/.test(pin) || /^(\d{3})\1$/.test(pin);
}

/** Verdadero si el PIN es repetido, escalera (123456, 987654) o de los más usados. */
export function esPinFacilDeAdivinar(pin: string): boolean {
  return todosIguales(pin) || esEscalera(pin) || repiteUnBloque(pin) || COMUNES.has(pin);
}
