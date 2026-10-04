import { agruparPorDia, horaLegible } from './agrupar-por-dia';
import type { Horario } from './horario';

const horario = (dia: string, horaInicio: string, servicioNombre = 'Almuerzo'): Horario => ({
  id: `${dia}-${horaInicio}`,
  servicioNombre,
  sedeId: 'principal',
  dia,
  horaInicio,
  horaFin: '23:00',
});

describe('agruparPorDia', () => {
  it('ordena por día de la semana y por hora, y omite días vacíos', () => {
    const grupos = agruparPorDia([
      horario('TUESDAY', '11:30'),
      horario('MONDAY', '11:30'),
      horario('MONDAY', '06:30', 'Desayuno'),
    ]);
    expect(grupos.map((g) => g.nombre)).toEqual(['Lunes', 'Martes']);
    expect(grupos[0].horarios.map((h) => h.servicioNombre)).toEqual(['Desayuno', 'Almuerzo']);
  });
});

describe('horaLegible', () => {
  it.each([
    ['06:30', '6:30 a. m.'],
    ['12:00', '12:00 p. m.'],
    ['15:05', '3:05 p. m.'],
    ['00:15', '12:15 a. m.'],
  ])('%s → %s', (hora, esperado) => {
    expect(horaLegible(hora)).toBe(esperado);
  });
});
