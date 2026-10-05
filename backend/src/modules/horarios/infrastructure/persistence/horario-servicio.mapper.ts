import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { HorarioServicio } from '../../domain/entities/horario-servicio.entity';
import { RangoHoras } from '../../domain/value-objects/rango-horas.vo';

/** Fila de tenancy.service_schedules con el código del día y las horas como texto. */
export interface FilaHorario {
  id: string;
  service_id: string;
  branch_id: string;
  dia: string;
  inicio: string;
  fin: string;
  servicio: string;
  activo: boolean;
}

export function aHorarioServicio(fila: FilaHorario): HorarioServicio {
  return HorarioServicio.crear({
    id: fila.id,
    servicioId: fila.service_id,
    sedeId: fila.branch_id,
    dia: CodigoCatalogo.de(fila.dia),
    horas: RangoHoras.de(fila.inicio, fila.fin),
    activo: fila.activo,
  });
}
