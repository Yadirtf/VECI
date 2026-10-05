import { CajeroEnSedes, CupoDeSedes, Sede } from '../../domain/entities/sede';

export interface DatosSede {
  nombre: string;
  municipioId: number | null;
  direccion: string | null;
}

export interface CambiosSede {
  nombre?: string;
  municipioId?: number | null;
  direccion?: string | null;
  activa?: boolean;
}

/** Sedes del comercio activo y dónde trabaja cada cajero. RLS limita todo al comercio. */
export interface SedesRepository {
  listar(): Promise<Sede[]>;
  buscar(sedeId: string): Promise<Sede | null>;
  cajeros(): Promise<CajeroEnSedes[]>;
  cupo(): Promise<CupoDeSedes>;
  crear(sedeId: string, datos: DatosSede): Promise<void>;
  actualizar(sedeId: string, cambios: CambiosSede): Promise<void>;
  esCajero(membresiaId: string): Promise<boolean>;
  /** Deja exactamente esas sedes vigentes para la membresía; las demás se cierran. */
  asignar(membresiaId: string, sedeIds: readonly string[], porUsuarioId: string): Promise<void>;
}

export const SEDES_REPOSITORY = Symbol('SedesRepository');
