import { CodigoCatalogo } from './codigo-catalogo.vo';
import { DatoInvalido } from './errores/dato-invalido.error';

describe('CodigoCatalogo', () => {
  it('acepta códigos en mayúscula sostenida', () => {
    expect(CodigoCatalogo.de('MONDAY').igualA(CodigoCatalogo.de('MONDAY'))).toBe(true);
  });

  it.each(['monday', '1DAY', 'LUNES MARTES', ''])('rechaza "%s"', (valor) => {
    expect(() => CodigoCatalogo.de(valor)).toThrow(DatoInvalido);
  });

  it('rechaza códigos de más de 40 caracteres', () => {
    expect(() => CodigoCatalogo.de('A'.repeat(41))).toThrow(DatoInvalido);
  });
});
