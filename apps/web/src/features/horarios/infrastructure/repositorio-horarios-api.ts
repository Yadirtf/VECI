import type { ClienteVeci, Horario as HorarioApi } from '@veci/api-client';
import { CABECERA_COMERCIO } from '@veci/shared';
import type { Horario, RepositorioHorarios } from '../domain/horario';

/** Lee los horarios del API con el cliente generado desde OpenAPI (HU-01-06). */
export class RepositorioHorariosApi implements RepositorioHorarios {
  constructor(
    private readonly cliente: ClienteVeci,
    private readonly comercioId: string,
  ) {}

  async listar(): Promise<Horario[]> {
    const { data, error } = await this.cliente.GET('/horarios', {
      params: { header: { [CABECERA_COMERCIO]: this.comercioId } },
    });
    if (error || !data) throw new Error('No se pudieron cargar los horarios');
    return data.map((h: HorarioApi) => ({
      id: h.id,
      servicioNombre: h.servicioNombre ?? 'Servicio',
      sedeId: h.sedeId,
      dia: h.dia,
      horaInicio: h.horaInicio,
      horaFin: h.horaFin,
    }));
  }
}
