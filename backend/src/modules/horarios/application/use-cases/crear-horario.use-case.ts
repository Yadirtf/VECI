import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { HorarioServicio } from '../../domain/entities/horario-servicio.entity';
import { ReferenciaNoEncontrada } from '../../domain/errors/referencia-no-encontrada.error';
import { HorarioServicioRepository } from '../../domain/repositories/horario-servicio.repository';
import { asegurarQueNoSeCruza } from '../../domain/rules/horarios-no-se-cruzan.rule';
import { RangoHoras } from '../../domain/value-objects/rango-horas.vo';
import { CrearHorarioInput } from '../dto/crear-horario.input';
import { aHorarioOutput, HorarioOutput } from '../dto/horario.output';

/**
 * Agrega un horario de servicio a una sede, en uno o varios días a la vez
 * ("igual de lunes a viernes"). Si un día se cruza, no se guarda ninguno.
 */
export class CrearHorario {
  constructor(
    private readonly horarios: HorarioServicioRepository,
    private readonly ids: GeneradorIds,
  ) {}

  async ejecutar(entrada: CrearHorarioInput): Promise<HorarioOutput[]> {
    const dias = [...new Set(entrada.dias)];
    if (dias.length === 0) throw new DatoInvalido('Escoge al menos un día, veci.');
    const horas = RangoHoras.de(entrada.horaInicio, entrada.horaFin);
    const nuevos = dias.map((dia) =>
      HorarioServicio.crear({
        id: this.ids.siguiente(),
        servicioId: entrada.servicioId,
        sedeId: entrada.sedeId,
        dia: CodigoCatalogo.de(dia),
        horas,
      }),
    );
    await this.asegurarReferencias(entrada.servicioId, entrada.sedeId);
    for (const horario of nuevos) {
      asegurarQueNoSeCruza(
        horario,
        await this.horarios.listarDeSedeYDia(horario.sedeId, horario.dia),
      );
    }
    await this.horarios.guardar(...nuevos);
    return nuevos.map((horario) => aHorarioOutput(horario));
  }

  private async asegurarReferencias(servicioId: string, sedeId: string): Promise<void> {
    if (!(await this.horarios.existeServicio(servicioId))) {
      throw new ReferenciaNoEncontrada('servicio');
    }
    if (!(await this.horarios.existeSede(sedeId))) {
      throw new ReferenciaNoEncontrada('sede');
    }
  }
}
