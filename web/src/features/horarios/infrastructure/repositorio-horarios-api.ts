import type { ClienteVeci, Horario as HorarioApi } from '@/shared/api/cliente';
import { CABECERA_COMERCIO } from '@/shared/api/cabeceras';
import { leerProblema } from '@/shared/api/problema';
import type {
  Horario,
  NuevoHorario,
  RepositorioHorarios,
  SedeCorta,
  Servicio,
} from '../domain/horario';

const falla = (error: unknown) => new Error(leerProblema(error).mensaje);

const aHorario = (h: HorarioApi): Horario => ({
  id: h.id,
  servicioId: h.servicioId,
  servicioNombre: h.servicioNombre ?? 'Servicio',
  sedeId: h.sedeId,
  dia: h.dia,
  horaInicio: h.horaInicio,
  horaFin: h.horaFin,
  activo: h.activo,
});

/** Horarios, servicios y sedes del API con el cliente generado desde OpenAPI (HU-03-02). */
export class RepositorioHorariosApi implements RepositorioHorarios {
  constructor(
    private readonly cliente: ClienteVeci,
    private readonly comercioId: string,
  ) {}

  private get params() {
    return { header: { [CABECERA_COMERCIO]: this.comercioId } };
  }

  async listar(): Promise<Horario[]> {
    const { data, error } = await this.cliente.GET('/horarios', { params: this.params });
    if (error || !data) throw new Error('No se pudieron cargar los horarios');
    return data.map(aHorario);
  }

  async servicios(): Promise<Servicio[]> {
    const { data, error } = await this.cliente.GET('/servicios', { params: this.params });
    if (!data) throw falla(error);
    return data;
  }

  async sedes(): Promise<SedeCorta[]> {
    const { data, error } = await this.cliente.GET('/sedes', { params: this.params });
    if (!data) throw falla(error);
    return data.sedes.filter((s) => s.activa).map((s) => ({ id: s.sedeId, nombre: s.nombre }));
  }

  async crear(nuevo: NuevoHorario): Promise<void> {
    const { error } = await this.cliente.POST('/horarios', { params: this.params, body: nuevo });
    if (error) throw falla(error);
  }

  async editar(id: string, horaInicio: string, horaFin: string): Promise<string> {
    const { data, error } = await this.cliente.PATCH('/horarios/{id}', {
      params: { ...this.params, path: { id } },
      body: { horaInicio, horaFin },
    });
    if (!data) throw falla(error);
    return data.id;
  }

  async cambiarEstado(id: string, activo: boolean): Promise<void> {
    const { error } = await this.cliente.PATCH('/horarios/{id}/estado', {
      params: { ...this.params, path: { id } },
      body: { activo },
    });
    if (error) throw falla(error);
  }

  async crearServicio(nombre: string): Promise<Servicio> {
    const { data, error } = await this.cliente.POST('/servicios', {
      params: this.params,
      body: { nombre },
    });
    if (!data) throw falla(error);
    return data;
  }
}
