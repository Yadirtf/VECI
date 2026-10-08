/** Horario de servicio tal como lo muestra el panel. */
export interface Horario {
  id: string;
  servicioId: string;
  servicioNombre: string;
  sedeId: string;
  dia: string;
  horaInicio: string;
  horaFin: string;
  /** false = en pausa: la caja no lo cuenta, pero no se pierde. */
  activo: boolean;
}

export interface Servicio {
  id: string;
  nombre: string;
}

export interface SedeCorta {
  id: string;
  nombre: string;
}

/** Un servicio con las mismas horas en uno o varios días. */
export interface NuevoHorario {
  servicioId: string;
  sedeId: string;
  dias: string[];
  horaInicio: string;
  horaFin: string;
}

/** Fuente de los horarios del negocio activo; la infraestructura decide de dónde salen. */
export interface RepositorioHorarios {
  listar(): Promise<Horario[]>;
  servicios(): Promise<Servicio[]>;
  sedes(): Promise<SedeCorta[]>;
  /**
   * Deja el servicio con esas horas en cada día elegido: lo crea donde no estaba y
   * le cambia las horas donde ya estaba (el anterior queda en la historia).
   */
  programar(nuevo: NuevoHorario): Promise<Horario[]>;
  cambiarEstado(id: string, activo: boolean): Promise<void>;
  crearServicio(nombre: string): Promise<Servicio>;
}
