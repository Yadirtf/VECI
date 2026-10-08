import { aMinutos } from './arco';
import type { Horario } from './horario';
import { horasSugeridas, planDeProgramacion } from './programacion';

const h = (servicioId: string, dia: string, horaInicio: string, horaFin: string): Horario => ({
  id: `${servicioId}-${dia}`,
  servicioId,
  servicioNombre: servicioId[0].toUpperCase() + servicioId.slice(1),
  sedeId: 'principal',
  dia,
  horaInicio,
  horaFin,
  activo: true,
});

const rango = (inicio: string, fin: string) => ({ inicio: aMinutos(inicio), fin: aMinutos(fin) });

describe('planDeProgramacion', () => {
  const semana = [
    h('almuerzo', 'MONDAY', '11:30', '15:00'),
    h('almuerzo', 'TUESDAY', '08:00', '10:00'),
    h('desayuno', 'WEDNESDAY', '07:00', '12:00'),
  ];

  it('dice en qué días se crea, se cambia o ya está igual, en orden de semana', () => {
    const plan = planDeProgramacion(
      semana,
      'almuerzo',
      ['THURSDAY', 'MONDAY', 'TUESDAY'],
      rango('11:30', '15:00'),
    );
    expect(plan.map((d) => [d.dia, d.accion])).toEqual([
      ['MONDAY', 'igual'],
      ['TUESDAY', 'cambiar'],
      ['THURSDAY', 'crear'],
    ]);
  });

  it('su propio horario viejo no cuenta como cruce, otro servicio sí', () => {
    const plan = planDeProgramacion(
      semana,
      'almuerzo',
      ['TUESDAY', 'WEDNESDAY'],
      rango('09:00', '15:00'),
    );
    expect(plan.map((d) => d.cruce?.servicioNombre ?? null)).toEqual([null, 'Desayuno']);
  });

  it('un servicio en pausa no se cruza', () => {
    const pausado = { ...h('desayuno', 'MONDAY', '07:00', '12:00'), activo: false };
    const [lunes] = planDeProgramacion([pausado], 'almuerzo', ['MONDAY'], rango('11:30', '15:00'));
    expect(lunes.cruce).toBeNull();
  });
});

describe('horasSugeridas', () => {
  it('usa las horas que el servicio ya tiene, primero las del día que se ve', () => {
    const horarios = [
      h('almuerzo', 'MONDAY', '12:00', '15:00'),
      h('almuerzo', 'TUESDAY', '11:00', '14:00'),
    ];
    const servicio = { id: 'almuerzo', nombre: 'Almuerzo' };
    expect(horasSugeridas(horarios, 'TUESDAY', servicio)).toEqual(rango('11:00', '14:00'));
    expect(horasSugeridas(horarios, 'FRIDAY', servicio)).toEqual(rango('12:00', '15:00'));
  });

  it('propone las horas de costumbre para desayuno, almuerzo y cena', () => {
    expect(horasSugeridas([], 'MONDAY', { id: null, nombre: 'Desayuno' })).toEqual(
      rango('06:00', '09:00'),
    );
    expect(horasSugeridas([], 'MONDAY', { id: 'c', nombre: 'Cena' })).toEqual(
      rango('18:00', '21:00'),
    );
  });

  it('para otro servicio busca el primer hueco libre del día', () => {
    const horarios = [h('desayuno', 'MONDAY', '06:00', '09:00')];
    expect(horasSugeridas(horarios, 'MONDAY', { id: null, nombre: 'Onces' })).toEqual(
      rango('09:00', '11:00'),
    );
  });
});
