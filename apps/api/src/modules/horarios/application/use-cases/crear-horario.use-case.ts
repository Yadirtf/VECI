import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { HorarioServicio } from '../../domain/entities/horario-servicio.entity';
import { ReferenciaNoEncontrada } from '../../domain/errors/referencia-no-encontrada.error';
import { HorarioServicioRepository } from '../../domain/repositories/horario-servicio.repository';
import { asegurarQueNoSeCruza } from '../../domain/rules/horarios-no-se-cruzan.rule';
import { RangoHoras } from '../../domain/value-objects/rango-horas.vo';
import { CrearHorarioInput } from '../dto/crear-horario.input';
import { aHorarioOutput, HorarioOutput } from '../dto/horario.output';

/** Agrega un horario de servicio a una sede del negocio activo. */
export class CrearHorario {
  constructor(
    private readonly horarios: HorarioServicioRepository,
    private readonly ids: GeneradorIds,
  ) {}

  async ejecutar(entrada: CrearHorarioInput): Promise<HorarioOutput> {
    const horario = HorarioServicio.crear({
      id: this.ids.siguiente(),
      servicioId: entrada.servicioId,
      sedeId: entrada.sedeId,
      dia: CodigoCatalogo.de(entrada.dia),
      horas: RangoHoras.de(entrada.horaInicio, entrada.horaFin),
    });
    await this.asegurarReferencias(horario);
    asegurarQueNoSeCruza(
      horario,
      await this.horarios.listarDeSedeYDia(horario.sedeId, horario.dia),
    );
    await this.horarios.guardar(horario);
    return aHorarioOutput(horario);
  }

  private async asegurarReferencias(horario: HorarioServicio): Promise<void> {
    if (!(await this.horarios.existeServicio(horario.servicioId))) {
      throw new ReferenciaNoEncontrada('servicio');
    }
    if (!(await this.horarios.existeSede(horario.sedeId))) {
      throw new ReferenciaNoEncontrada('sede');
    }
  }
}
