import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { HorarioServicio } from '../../domain/entities/horario-servicio.entity';
import { HorarioSeCruza } from '../../domain/errors/horario-se-cruza.error';
import { ReferenciaNoEncontrada } from '../../domain/errors/referencia-no-encontrada.error';
import {
  HorarioConServicio,
  HorarioServicioRepository,
} from '../../domain/repositories/horario-servicio.repository';
import { RangoHoras } from '../../domain/value-objects/rango-horas.vo';
import { aHorarioOutput, HorarioOutput } from '../dto/horario.output';
import { ProgramarServicioInput } from '../dto/programar-servicio.input';

const NOMBRE_DIA: Record<string, string> = {
  MONDAY: 'lunes',
  TUESDAY: 'martes',
  WEDNESDAY: 'miércoles',
  THURSDAY: 'jueves',
  FRIDAY: 'viernes',
  SATURDAY: 'sábado',
  SUNDAY: 'domingo',
};

/**
 * Deja un servicio con las mismas horas en varios días a la vez (HU-03-02):
 * "almuerzo de 11:30 a 15:00 de lunes a viernes". Donde el servicio ya existía se
 * reemplaza (el anterior queda en la historia) y donde no, se crea. Su horario viejo
 * no cuenta como cruce; otro servicio sí. Si un día se cruza, no cambia ninguno.
 */
export class ProgramarServicio {
  constructor(
    private readonly horarios: HorarioServicioRepository,
    private readonly ids: GeneradorIds,
  ) {}

  async ejecutar(entrada: ProgramarServicioInput): Promise<HorarioOutput[]> {
    const dias = [...new Set(entrada.dias)].map((dia) => CodigoCatalogo.de(dia));
    if (dias.length === 0) throw new DatoInvalido('Escoge al menos un día, veci.');
    const horas = RangoHoras.de(entrada.horaInicio, entrada.horaFin);
    await this.asegurarReferencias(entrada.servicioId, entrada.sedeId);
    const deLaSede = (await this.horarios.listarVigentes()).filter(
      (h) => h.horario.sedeId === entrada.sedeId,
    );
    const cerrar: string[] = [];
    const nuevos: HorarioServicio[] = [];
    const resultado: HorarioServicio[] = [];
    for (const dia of dias) {
      const delDia = deLaSede.filter((h) => h.horario.dia.igualA(dia));
      const propios = delDia.filter((h) => h.horario.servicioId === entrada.servicioId);
      const igual = propios.length === 1 && mismoHorario(propios[0].horario, horas);
      if (igual) {
        resultado.push(propios[0].horario);
        continue;
      }
      const nuevo = HorarioServicio.crear({
        id: this.ids.siguiente(),
        servicioId: entrada.servicioId,
        sedeId: entrada.sedeId,
        dia,
        horas,
      });
      asegurarSinCruces(nuevo, delDia, entrada.servicioId);
      cerrar.push(...propios.map((h) => h.horario.id));
      nuevos.push(nuevo);
      resultado.push(nuevo);
    }
    if (nuevos.length > 0) await this.horarios.programar(cerrar, nuevos);
    return resultado.map((horario) => aHorarioOutput(horario));
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

function mismoHorario(horario: HorarioServicio, horas: RangoHoras): boolean {
  return horario.activo && horario.horas.inicio === horas.inicio && horario.horas.fin === horas.fin;
}

function asegurarSinCruces(
  nuevo: HorarioServicio,
  delDia: readonly HorarioConServicio[],
  servicioId: string,
): void {
  const otro = delDia.find(
    (h) => h.horario.servicioId !== servicioId && h.horario.seCruzaCon(nuevo),
  );
  if (!otro) return;
  const dia = NOMBRE_DIA[nuevo.dia.valor] ?? nuevo.dia.valor;
  const { inicio, fin } = otro.horario.horas;
  throw new HorarioSeCruza(
    `El ${dia} se cruza con ${otro.servicioNombre} (${inicio} a ${fin}). Mueve uno de los dos y vuelve a guardar.`,
  );
}
