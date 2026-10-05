import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { CupoDeSedes, Sede } from '../entities/sede';
import { CambioDeSedeNoPermitido, LimiteDeSedes, SedesSoloEnPro } from '../errors/errores-sedes';

/** Una sede más solo si el plan tiene la función de varias sedes y cupo (HU-03-03). */
export function asegurarCupoDeSedes(cupo: CupoDeSedes): void {
  if (cupo.ocupadas >= 1 && !cupo.variasSedes) throw new SedesSoloEnPro();
  if (cupo.limite !== null && cupo.ocupadas >= cupo.limite) throw new LimiteDeSedes(cupo.limite);
}

/** La sede principal no se cierra: es donde vive el negocio. */
export function asegurarQueSePuedeDesactivar(sede: Sede): void {
  if (sede.principal) {
    throw new CambioDeSedeNoPermitido('La sede principal no se desactiva, veci.');
  }
}

export function nombreDeSede(texto: string): string {
  const limpio = texto.trim().replace(/\s+/g, ' ');
  if (limpio.length < 2 || limpio.length > 120) {
    throw new DatoInvalido('El nombre de la sede va de 2 a 120 letras.');
  }
  return limpio;
}
