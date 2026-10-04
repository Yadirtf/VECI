/** Horario de servicio tal como lo muestra el panel. */
export interface Horario {
  id: string;
  servicioNombre: string;
  sedeId: string;
  dia: string;
  horaInicio: string;
  horaFin: string;
}

/** Fuente de los horarios del negocio activo; la infraestructura decide de dónde salen. */
export interface RepositorioHorarios {
  listar(): Promise<Horario[]>;
}
