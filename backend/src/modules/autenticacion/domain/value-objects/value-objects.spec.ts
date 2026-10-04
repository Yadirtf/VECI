import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { Celular } from './celular.vo';
import { Contrasena } from './contrasena.vo';
import { Correo } from './correo.vo';
import { Pin } from './pin.vo';

describe('Celular', () => {
  it.each(['300 123 4567', '3001234567', '57 300 123 4567', '+57-300-123-4567'])(
    'normaliza %s a E.164',
    (texto) => expect(Celular.de(texto).valor).toBe('+573001234567'),
  );

  it('rechaza números incompletos y muestra solo los últimos 4', () => {
    expect(() => Celular.de('300123')).toThrow(DatoInvalido);
    expect(Celular.de('3001234567').enmascarado).toBe('••• 4567');
  });
});

describe('Correo', () => {
  it('se guarda en minúsculas y sin espacios', () => {
    expect(Correo.de('  Marta@LaVecina.co ').valor).toBe('marta@lavecina.co');
  });

  it('rechaza lo que no es un correo', () => {
    expect(() => Correo.de('marta')).toThrow(DatoInvalido);
  });
});

describe('Pin', () => {
  it('acepta 6 números difíciles de adivinar', () => {
    expect(Pin.nuevo('482915').valor).toBe('482915');
  });

  it('rechaza otro largo, letras y PIN obvios', () => {
    expect(() => Pin.nuevo('48291')).toThrow('6 números');
    expect(() => Pin.nuevo('48a915')).toThrow(DatoInvalido);
    expect(() => Pin.nuevo('123456')).toThrow('fácil de adivinar');
  });
});

describe('Contrasena', () => {
  it('pide letras, números y 8 caracteres', () => {
    expect(Contrasena.nueva('almuerzo2026').valor).toBe('almuerzo2026');
    expect(() => Contrasena.nueva('corta1')).toThrow(DatoInvalido);
    expect(() => Contrasena.nueva('sololetras')).toThrow(DatoInvalido);
    expect(() => Contrasena.nueva('12345678')).toThrow(DatoInvalido);
  });
});
