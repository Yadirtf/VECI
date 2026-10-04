import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { RangoHoras } from './rango-horas.vo';

describe('RangoHoras', () => {
  it('acepta horas en formato HH:MM con inicio antes del fin', () => {
    const rango = RangoHoras.de('11:30', '15:00');
    expect([rango.inicio, rango.fin]).toEqual(['11:30', '15:00']);
  });

  it.each([
    ['15:00', '11:30'],
    ['12:00', '12:00'],
  ])('rechaza inicio %s y fin %s', (inicio, fin) => {
    expect(() => RangoHoras.de(inicio, fin)).toThrow(DatoInvalido);
  });

  it.each(['7:00', '24:00', '12:60', 'mediodía'])('rechaza la hora "%s"', (hora) => {
    expect(() => RangoHoras.de(hora, '23:00')).toThrow('no es una hora válida');
  });

  it('detecta cruces y deja pegar un horario al final del otro', () => {
    const almuerzo = RangoHoras.de('11:30', '15:00');
    expect(almuerzo.seCruzaCon(RangoHoras.de('14:00', '16:00'))).toBe(true);
    expect(almuerzo.seCruzaCon(RangoHoras.de('12:00', '13:00'))).toBe(true);
    expect(almuerzo.seCruzaCon(RangoHoras.de('15:00', '18:00'))).toBe(false);
    expect(almuerzo.seCruzaCon(RangoHoras.de('06:30', '11:30'))).toBe(false);
  });
});
