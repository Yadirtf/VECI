/** "Almuerzo de 11:30 a 15:00 de lunes a viernes": así queda ese servicio esos días. */
export interface ProgramarServicioInput {
  servicioId: string;
  sedeId: string;
  /** Códigos del catálogo core.weekdays (MONDAY...). */
  dias: string[];
  horaInicio: string;
  horaFin: string;
}
