export interface Sede {
  id: string;
  nombre: string;
  principal: boolean;
  activa: boolean;
  municipio: string | null;
  direccion: string | null;
}

export interface CajeroEnSedes {
  membresiaId: string;
  nombre: string;
  /** Vacío = trabaja en todas las sedes. */
  sedeIds: string[];
}

export interface CupoDeSedes {
  ocupadas: number;
  /** null = sin límite. */
  limite: number | null;
  /** El plan permite varias sedes (Pro). */
  variasSedes: boolean;
}

export interface MapaDeSedes {
  sedes: Sede[];
  cajeros: CajeroEnSedes[];
  cupo: CupoDeSedes;
}

export interface RepositorioSedes {
  mapa(): Promise<MapaDeSedes>;
  crear(nombre: string, direccion: string | null): Promise<void>;
  cambiarActiva(sedeId: string, activa: boolean): Promise<void>;
  asignar(membresiaId: string, sedeIds: string[]): Promise<void>;
}
