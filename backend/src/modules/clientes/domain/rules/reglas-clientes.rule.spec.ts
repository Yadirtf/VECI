import { leerTokenQr, parteFirmada } from '../value-objects/token-qr.vo';
import { leerConsulta } from './consulta-de-clientes.rule';
import {
  enmascararCelular,
  enmascararDocumento,
  nombreCompleto,
  nombreCorto,
  plegar,
} from './enmascarar.rule';

const ID = '01890a5d-ac96-774b-bcce-b302099a8057';

describe('Enmascarar (HU-04-03)', () => {
  it('el documento siempre con el mismo largo y el celular con sus 4 últimos', () => {
    expect(enmascararDocumento('1124005678')).toBe('****5678');
    expect(enmascararDocumento('123456')).toBe('****3456');
    expect(enmascararCelular('+573157778888')).toBe('••• 8888');
  });

  it('nombre corto para confirmar y nombre completo para la ficha', () => {
    expect(nombreCorto('Luz Marina', 'chindoy')).toBe('Luz Marina C.');
    expect(nombreCorto('Rosa', null)).toBe('Rosa');
    expect(nombreCorto('Rosa', '  ')).toBe('Rosa');
    expect(nombreCompleto('Rosa', null)).toBe('Rosa');
    expect(nombreCompleto('Luz', 'Chindoy')).toBe('Luz Chindoy');
  });

  it('plegar quita tildes, mayúsculas y espacios de más', () => {
    expect(plegar('  José   ÑÚÑEZ ')).toBe('jose nunez');
  });
});

describe('Consulta de clientes (HU-04-05)', () => {
  it('números con espacios o guiones buscan documento o celular', () => {
    expect(leerConsulta('310-000 01')).toEqual({ tipo: 'NUMERO', digitos: '31000001' });
    expect(leerConsulta('+57 315')).toEqual({ tipo: 'NUMERO', digitos: '57315' });
  });

  it('lo demás busca por palabras del nombre, sin tildes', () => {
    expect(leerConsulta('Luz  Marína')).toEqual({ tipo: 'NOMBRE', palabras: ['luz', 'marina'] });
    expect(leerConsulta('ana 2')).toEqual({ tipo: 'NOMBRE', palabras: ['ana', '2'] });
  });

  it('desde 3 caracteres', () => {
    expect(() => leerConsulta('12')).toThrow('al menos 3');
    expect(() => leerConsulta('a b')).toThrow('al menos 3');
    expect(() => leerConsulta('')).toThrow('al menos 3');
  });
});

describe('Token del QR (ADR-0011, ADR-0017)', () => {
  const personal = parteFirmada('VP1', { k: 'p1', q: ID, v: 2 });
  const afiliacion = parteFirmada('V1', { k: 'k1', t: ID, a: ID, q: ID, v: 1 });

  it('separa la parte firmada y la firma', () => {
    expect(leerTokenQr(`${personal}.firma`)).toEqual({
      tipo: 'PERSONAL',
      carga: { k: 'p1', q: ID, v: 2 },
      firmado: personal,
      firma: 'firma',
    });
    expect(leerTokenQr(` ${afiliacion}.f \n`)).toMatchObject({
      tipo: 'AFILIACION',
      carga: { t: ID, a: ID },
    });
  });

  it.each([
    'hola',
    'https://veci.co/a.b.c',
    `${personal}.`,
    `${personal}.a.b`,
    `VP2.${personal.split('.')[1]}.f`,
    `${parteFirmada('VP1', { k: 'p1', q: 'no-uuid', v: 1 })}.f`,
    `${parteFirmada('VP1', { k: 'P 1', q: ID, v: 1 })}.f`,
    `${parteFirmada('VP1', { k: 'p1', q: ID, v: 0 })}.f`,
    `${parteFirmada('V1', { k: 'k1', q: ID, v: 1 } as never)}.f`,
    `${parteFirmada('V1', { k: 'k1', t: 'x', a: ID, q: ID, v: 1 })}.f`,
    'VP1.bm8gZXMganNvbg.f',
    'VP1.bnVsbA.f',
  ])('lo demás es ajeno: %s', (texto) => {
    expect(leerTokenQr(texto)).toEqual({ tipo: 'AJENO' });
  });
});
