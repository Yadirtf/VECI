import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import {
  HorarioServicioRepository,
  Servicio,
} from '../../domain/repositories/horario-servicio.repository';

/** Servicios que ofrece el negocio: desayuno, almuerzo, cena o recreo. */
export class GestionarServicios {
  constructor(
    private readonly horarios: HorarioServicioRepository,
    private readonly ids: GeneradorIds,
  ) {}

  listar(): Promise<Servicio[]> {
    return this.horarios.servicios();
  }

  async crear(nombre: string): Promise<Servicio> {
    const limpio = nombre.trim().replace(/\s+/g, ' ');
    if (limpio.length < 2 || limpio.length > 60) {
      throw new DatoInvalido('El nombre del servicio va de 2 a 60 letras.');
    }
    const servicio = { id: this.ids.siguiente(), nombre: limpio };
    await this.horarios.crearServicio(servicio);
    return servicio;
  }
}
