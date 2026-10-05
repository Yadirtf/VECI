import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { HorarioServicio } from '../entities/horario-servicio.entity';

/** Horario con el nombre de su servicio, para mostrarlo en pantalla. */
export interface HorarioConServicio {
  horario: HorarioServicio;
  servicioNombre: string;
}

export interface Servicio {
  id: string;
  nombre: string;
}

/**
 * Horarios vigentes del negocio activo. La implementación aplica el aislamiento.
 * Nada se borra: cambiar las horas cierra la vigencia del horario anterior en la
 * fecha local del negocio y abre uno nuevo, así los consumos viejos conservan el
 * horario con que se registraron.
 */
export interface HorarioServicioRepository {
  /** Activos y en pausa, vigentes hoy. */
  listarVigentes(): Promise<HorarioConServicio[]>;
  /** Marca de cambios: sube con cada horario o servicio nuevo o cambiado (sync_version). */
  version(): Promise<string>;
  buscar(id: string): Promise<HorarioServicio | null>;
  /** Solo los activos, para revisar cruces. */
  listarDeSedeYDia(sedeId: string, dia: CodigoCatalogo): Promise<HorarioServicio[]>;
  existeServicio(servicioId: string): Promise<boolean>;
  existeSede(sedeId: string): Promise<boolean>;
  /** Guarda varios en una transacción: o quedan todos o ninguno. */
  guardar(...horarios: HorarioServicio[]): Promise<void>;
  /** Cierra la vigencia del anterior y guarda el nuevo, en una transacción. */
  reemplazar(anteriorId: string, nuevo: HorarioServicio): Promise<void>;
  cambiarEstado(id: string, activo: boolean): Promise<void>;
  servicios(): Promise<Servicio[]>;
  crearServicio(servicio: Servicio): Promise<void>;
}

export const HORARIO_SERVICIO_REPOSITORY = Symbol('HorarioServicioRepository');
