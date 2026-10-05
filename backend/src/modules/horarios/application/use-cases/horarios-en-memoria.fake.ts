import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { HorarioServicio } from '../../domain/entities/horario-servicio.entity';
import {
  HorarioConServicio,
  HorarioServicioRepository,
  Servicio,
} from '../../domain/repositories/horario-servicio.repository';

/** Repositorio en memoria para probar los casos de uso sin base de datos. */
export class HorariosEnMemoria implements HorarioServicioRepository {
  readonly guardados: HorarioServicio[] = [];
  readonly cerrados: string[] = [];
  private cambios = 0;

  constructor(
    private readonly catalogo: Record<string, string>,
    private readonly sedes: string[],
  ) {}

  async listarVigentes(): Promise<HorarioConServicio[]> {
    return this.guardados.map((horario) => ({
      horario,
      servicioNombre: this.catalogo[horario.servicioId],
    }));
  }

  async version(): Promise<string> {
    return String(this.cambios);
  }

  async buscar(id: string): Promise<HorarioServicio | null> {
    return this.guardados.find((h) => h.id === id) ?? null;
  }

  async listarDeSedeYDia(sedeId: string, dia: CodigoCatalogo): Promise<HorarioServicio[]> {
    return this.guardados.filter((h) => h.activo && h.sedeId === sedeId && h.dia.igualA(dia));
  }

  async existeServicio(servicioId: string): Promise<boolean> {
    return servicioId in this.catalogo;
  }

  async existeSede(sedeId: string): Promise<boolean> {
    return this.sedes.includes(sedeId);
  }

  async guardar(...horarios: HorarioServicio[]): Promise<void> {
    this.guardados.push(...horarios);
    this.cambios++;
  }

  async reemplazar(anteriorId: string, nuevo: HorarioServicio): Promise<void> {
    this.cerrados.push(anteriorId);
    const i = this.guardados.findIndex((h) => h.id === anteriorId);
    this.guardados.splice(i, 1, nuevo);
    this.cambios++;
  }

  async cambiarEstado(id: string, activo: boolean): Promise<void> {
    const i = this.guardados.findIndex((h) => h.id === id);
    this.guardados[i] = this.guardados[i].con({ id, activo });
    this.cambios++;
  }

  async servicios(): Promise<Servicio[]> {
    return Object.entries(this.catalogo).map(([id, nombre]) => ({ id, nombre }));
  }

  async crearServicio(servicio: Servicio): Promise<void> {
    this.catalogo[servicio.id] = servicio.nombre;
    this.cambios++;
  }
}
