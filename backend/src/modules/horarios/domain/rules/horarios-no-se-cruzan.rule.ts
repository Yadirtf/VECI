import { HorarioServicio } from '../entities/horario-servicio.entity';
import { HorarioSeCruza } from '../errors/horario-se-cruza.error';

/**
 * Un servicio por horario: en una sede, un día no puede tener dos horarios que se
 * cruzan. La base de datos lo garantiza también con una restricción de exclusión.
 */
export function asegurarQueNoSeCruza(
  nuevo: HorarioServicio,
  existentes: readonly HorarioServicio[],
): void {
  if (existentes.some((existente) => existente.seCruzaCon(nuevo))) {
    throw new HorarioSeCruza();
  }
}
