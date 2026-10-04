import { AccionSobreMiembroNoPermitida, LimiteDeCajeros } from '../errors/errores-personal';
import { esPropietario, Miembro } from '../entities/miembro';

/** Cupo de cajeros del plan; limite null = ilimitado. */
export interface CupoDeCajeros {
  readonly ocupados: number;
  readonly limite: number | null;
}

/** Invitar o reactivar un cajero solo si el plan tiene cupo (HU-02-04). */
export function asegurarCupo(cupo: CupoDeCajeros): void {
  if (cupo.limite !== null && cupo.ocupados >= cupo.limite) throw new LimiteDeCajeros(cupo.limite);
}

/** La gestión de cajeros no aplica a uno mismo ni al propietario. */
export function asegurarQueSePuedeGestionar(miembro: Miembro, actorUsuarioId: string): void {
  if (miembro.usuarioId === actorUsuarioId) {
    throw new AccionSobreMiembroNoPermitida('No puedes hacer esto sobre tu propia cuenta, veci.');
  }
  if (esPropietario(miembro)) {
    throw new AccionSobreMiembroNoPermitida('El propietario no se gestiona desde aquí.');
  }
}
