import { HorarioServicioRepository } from '../../domain/repositories/horario-servicio.repository';
import { aHorarioOutput, HorarioOutput } from '../dto/horario.output';

/** Horarios de servicio vigentes del negocio activo. */
export class ListarHorarios {
  constructor(private readonly horarios: HorarioServicioRepository) {}

  async ejecutar(): Promise<HorarioOutput[]> {
    const vigentes = await this.horarios.listarVigentes();
    return vigentes.map(({ horario, servicioNombre }) => aHorarioOutput(horario, servicioNombre));
  }
}
