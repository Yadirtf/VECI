import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { HorarioServicio } from '../../domain/entities/horario-servicio.entity';
import {
  HorarioConServicio,
  HorarioServicioRepository,
} from '../../domain/repositories/horario-servicio.repository';

/** Repositorio en memoria para probar los casos de uso sin base de datos. */
export class HorariosEnMemoria implements HorarioServicioRepository {
  readonly guardados: HorarioServicio[] = [];

  constructor(
    private readonly servicios: Record<string, string>,
    private readonly sedes: string[],
  ) {}

  async listarVigentes(): Promise<HorarioConServicio[]> {
    return this.guardados.map((horario) => ({
      horario,
      servicioNombre: this.servicios[horario.servicioId],
    }));
  }

  async listarDeSedeYDia(sedeId: string, dia: CodigoCatalogo): Promise<HorarioServicio[]> {
    return this.guardados.filter((h) => h.sedeId === sedeId && h.dia.igualA(dia));
  }

  async existeServicio(servicioId: string): Promise<boolean> {
    return servicioId in this.servicios;
  }

  async existeSede(sedeId: string): Promise<boolean> {
    return this.sedes.includes(sedeId);
  }

  async guardar(horario: HorarioServicio): Promise<void> {
    this.guardados.push(horario);
  }
}
