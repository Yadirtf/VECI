import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { HorarioServicio } from '../entities/horario-servicio.entity';
import { HorarioSeCruza } from '../errors/horario-se-cruza.error';
import { RangoHoras } from '../value-objects/rango-horas.vo';
import { asegurarQueNoSeCruza } from './horarios-no-se-cruzan.rule';

function horario(sedeId: string, dia: string, inicio: string, fin: string): HorarioServicio {
  return HorarioServicio.crear({
    id: `${sedeId}-${dia}-${inicio}`,
    servicioId: 'almuerzo',
    sedeId,
    dia: CodigoCatalogo.de(dia),
    horas: RangoHoras.de(inicio, fin),
  });
}

describe('asegurarQueNoSeCruza', () => {
  const existentes = [horario('principal', 'MONDAY', '11:30', '15:00')];

  it('rechaza un horario que se cruza el mismo día en la misma sede', () => {
    expect(() =>
      asegurarQueNoSeCruza(horario('principal', 'MONDAY', '14:00', '16:00'), existentes),
    ).toThrow(HorarioSeCruza);
  });

  it('acepta el mismo rango otro día o en otra sede', () => {
    expect(() =>
      asegurarQueNoSeCruza(horario('principal', 'TUESDAY', '11:30', '15:00'), existentes),
    ).not.toThrow();
    expect(() =>
      asegurarQueNoSeCruza(horario('norte', 'MONDAY', '11:30', '15:00'), existentes),
    ).not.toThrow();
  });
});
