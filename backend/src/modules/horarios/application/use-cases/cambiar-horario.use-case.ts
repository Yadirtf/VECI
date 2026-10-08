import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { HorarioServicio } from '../../domain/entities/horario-servicio.entity';
import { HorarioNoEncontrado } from '../../domain/errors/horario-no-encontrado.error';
import { HorarioServicioRepository } from '../../domain/repositories/horario-servicio.repository';
import { asegurarQueNoSeCruza } from '../../domain/rules/horarios-no-se-cruzan.rule';
import { RangoHoras } from '../../domain/value-objects/rango-horas.vo';
import { EditarHorarioInput } from '../dto/crear-horario.input';
import { aHorarioOutput, HorarioOutput } from '../dto/horario.output';

/**
 * Edita las horas o pone en pausa un horario (HU-03-02). Cambiar horas guarda un
 * horario nuevo desde hoy y cierra el anterior; la pausa no borra nada y se
 * deshace con reanudar, siempre que no se cruce con otro que se creó entretanto.
 */
export class CambiarHorario {
  constructor(
    private readonly horarios: HorarioServicioRepository,
    private readonly ids: GeneradorIds,
  ) {}

  async editar(id: string, entrada: EditarHorarioInput): Promise<HorarioOutput> {
    const actual = await this.existente(id);
    const nuevo = actual.con({
      id: this.ids.siguiente(),
      horas: RangoHoras.de(entrada.horaInicio, entrada.horaFin),
    });
    await this.asegurarSinCruces(nuevo, actual.id);
    await this.horarios.programar([actual.id], [nuevo]);
    return aHorarioOutput(nuevo);
  }

  async cambiarEstado(id: string, activo: boolean): Promise<HorarioOutput> {
    const actual = await this.existente(id);
    if (actual.activo === activo) return aHorarioOutput(actual);
    const cambiado = actual.con({ id: actual.id, activo });
    if (activo) await this.asegurarSinCruces(cambiado, actual.id);
    await this.horarios.cambiarEstado(id, activo);
    return aHorarioOutput(cambiado);
  }

  private async existente(id: string): Promise<HorarioServicio> {
    const horario = await this.horarios.buscar(id);
    if (!horario) throw new HorarioNoEncontrado();
    return horario;
  }

  private async asegurarSinCruces(horario: HorarioServicio, ignorarId: string): Promise<void> {
    const delDia = await this.horarios.listarDeSedeYDia(horario.sedeId, horario.dia);
    asegurarQueNoSeCruza(
      horario,
      delDia.filter((otro) => otro.id !== ignorarId),
    );
  }
}
