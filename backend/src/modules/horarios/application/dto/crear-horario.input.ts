export interface CrearHorarioInput {
  servicioId: string;
  sedeId: string;
  /** Códigos del catálogo core.weekdays (MONDAY...). Varios días copian el mismo horario. */
  dias: string[];
  horaInicio: string;
  horaFin: string;
}

export interface EditarHorarioInput {
  horaInicio: string;
  horaFin: string;
}
