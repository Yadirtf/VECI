import { aMinutos } from './arco';
import { limitesDe, moverExtremo, primerHueco } from './dia-de-servicio';
import type { Horario } from './horario';

const h = (
  id: string,
  horaInicio: string,
  horaFin: string,
  extra: Partial<Horario> = {},
): Horario => ({
  id,
  servicioId: id,
  servicioNombre: id,
  sedeId: 'principal',
  dia: 'MONDAY',
  horaInicio,
  horaFin,
  activo: true,
  ...extra,
});

const desayuno = h('desayuno', '06:30', '09:30');
const almuerzo = h('almuerzo', '11:30', '15:00');
const cena = h('cena', '18:00', '21:00');
const dia = [desayuno, almuerzo, cena];

describe('limitesDe', () => {
  it('un servicio se estira hasta donde empiezan o terminan sus vecinos', () => {
    expect(limitesDe(dia, almuerzo)).toEqual({
      minInicio: aMinutos('09:30'),
      maxFin: aMinutos('18:00'),
    });
  });

  it('no cuenta los pausados, otros días ni otras sedes', () => {
    const otros = [
      h('pausado', '10:00', '11:00', { activo: false }),
      h('martes', '15:30', '16:00', { dia: 'TUESDAY' }),
      h('otra', '16:00', '17:00', { sedeId: 'parque' }),
    ];
    expect(limitesDe([...dia, ...otros], almuerzo)).toEqual({
      minInicio: aMinutos('09:30'),
      maxFin: aMinutos('18:00'),
    });
  });
});

describe('moverExtremo', () => {
  const rango = { inicio: aMinutos('11:30'), fin: aMinutos('15:00') };
  const limites = limitesDe(dia, almuerzo);

  it('se detiene contra el vecino en vez de cruzarse', () => {
    expect(moverExtremo(rango, 'inicio', aMinutos('08:00'), limites).inicio).toBe(
      aMinutos('09:30'),
    );
    expect(moverExtremo(rango, 'fin', aMinutos('19:00'), limites).fin).toBe(aMinutos('18:00'));
  });

  it('deja al menos un cuarto de hora de servicio', () => {
    expect(moverExtremo(rango, 'inicio', aMinutos('16:00'), limites).inicio).toBe(
      aMinutos('14:45'),
    );
  });

  it('redondea al cuarto de hora', () => {
    expect(moverExtremo(rango, 'fin', aMinutos('14:08'), limites).fin).toBe(aMinutos('14:15'));
  });
});

describe('primerHueco', () => {
  it('propone el primer espacio libre del día', () => {
    expect(primerHueco(dia)).toEqual({ inicio: aMinutos('09:30'), fin: aMinutos('11:30') });
  });

  it('en un día sin servicios propone desde las 6 a. m.', () => {
    expect(primerHueco([])).toEqual({ inicio: 360, fin: 480 });
  });

  it('dice que no hay espacio si el día está lleno', () => {
    expect(primerHueco([h('todo', '05:00', '22:00')])).toBeNull();
  });
});
