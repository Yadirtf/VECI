export interface CrearHorarioInput {
  servicioId: string;
  sedeId: string;
  /** Código del día en el catálogo core.weekdays, por ejemplo MONDAY. */
  dia: string;
  horaInicio: string;
  horaFin: string;
}
