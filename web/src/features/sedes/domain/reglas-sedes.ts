import type { CajeroEnSedes, CupoDeSedes, Sede } from './sede';

/** Si el plan deja armar otra casa. La regla de verdad la aplica el servidor (HU-03-03). */
export function puedeAgregarSede(cupo: CupoDeSedes): boolean {
  return cupo.variasSedes && (cupo.limite === null || cupo.ocupadas < cupo.limite);
}

export function trabajaEn(cajero: CajeroEnSedes, sedeId: string): boolean {
  return cajero.sedeIds.length === 0 || cajero.sedeIds.includes(sedeId);
}

/**
 * Pone o quita a un cajero de una sede. Sin filas significa "en todas": si al final
 * queda en todas las activas, se guarda vacío para que también cubra las sedes nuevas.
 */
export function alternarSede(cajero: CajeroEnSedes, sedeId: string, sedes: Sede[]): string[] {
  const activas = sedes.filter((s) => s.activa).map((s) => s.id);
  const actuales = cajero.sedeIds.length === 0 ? activas : cajero.sedeIds;
  const nuevas = actuales.includes(sedeId)
    ? actuales.filter((id) => id !== sedeId)
    : [...actuales, sedeId];
  return activas.every((id) => nuevas.includes(id)) ? [] : nuevas;
}
