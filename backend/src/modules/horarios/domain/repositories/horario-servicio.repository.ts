import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { HorarioServicio } from '../entities/horario-servicio.entity';

/** Horario con el nombre de su servicio, para mostrarlo en pantalla. */
export interface HorarioConServicio {
  horario: HorarioServicio;
  servicioNombre: string;
}

/** Horarios vigentes del negocio activo. La implementación aplica el aislamiento. */
export interface HorarioServicioRepository {
  listarVigentes(): Promise<HorarioConServicio[]>;
  listarDeSedeYDia(sedeId: string, dia: CodigoCatalogo): Promise<HorarioServicio[]>;
  existeServicio(servicioId: string): Promise<boolean>;
  existeSede(sedeId: string): Promise<boolean>;
  guardar(horario: HorarioServicio): Promise<void>;
}

export const HORARIO_SERVICIO_REPOSITORY = Symbol('HorarioServicioRepository');
