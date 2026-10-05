import { HorarioServicio } from '../../domain/entities/horario-servicio.entity';

export interface HorarioOutput {
  id: string;
  servicioId: string;
  servicioNombre?: string;
  sedeId: string;
  dia: string;
  horaInicio: string;
  horaFin: string;
  activo: boolean;
}

export function aHorarioOutput(horario: HorarioServicio, servicioNombre?: string): HorarioOutput {
  return {
    id: horario.id,
    servicioId: horario.servicioId,
    servicioNombre,
    sedeId: horario.sedeId,
    dia: horario.dia.valor,
    horaInicio: horario.horas.inicio,
    horaFin: horario.horas.fin,
    activo: horario.activo,
  };
}
