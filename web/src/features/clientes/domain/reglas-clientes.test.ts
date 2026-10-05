import { describe, expect, it } from 'vitest';
import type { ClienteEnLibreta, FichaCliente } from './cliente';
import {
  aRenglon,
  buscaEnServidor,
  buscarEnLibreta,
  celularLegible,
  celularValido,
  datoInicial,
  faltaEnPersonaNueva,
  fechaLegible,
  filtrar,
  juntar,
  normalizar,
  ordenarLibreta,
  resumenLibreta,
  revisarNumero,
  taparCelular,
  taparDocumento,
} from './reglas-clientes';

const cliente = (
  nombre: string,
  documentoFinal: string,
  cuenta: ClienteEnLibreta['cuenta'] = 'ACTIVA',
  celularFinal: string | null = null,
): ClienteEnLibreta => ({
  clienteId: nombre,
  nombre,
  nombreBusqueda: normalizar(nombre),
  documento: `****${documentoFinal}`,
  documentoFinal,
  celular: celularFinal ? `••• ${celularFinal}` : null,
  celularFinal,
  cuenta,
  estado: 'ACTIVE',
});

const luz = cliente('Luz Marina Chindoy', '5678', 'PENDIENTE', '8888');
const jose = cliente('José Muñoz', '1234', 'ACTIVA', '4567');
const ana = cliente('Ana Jamioy', '9012', 'SIN_CUENTA');
const libreta = [luz, jose, ana];

describe('buscar en la libreta', () => {
  it('quita tildes, mayúsculas y espacios de más', () => {
    expect(normalizar('  Luz  MARÍNA Chíndoy ')).toBe('luz marina chindoy');
  });

  it('encuentra por nombre sin tildes y por cada palabra', () => {
    expect(buscarEnLibreta(libreta, 'jose')).toEqual([jose]);
    expect(buscarEnLibreta(libreta, 'MARINA luz')).toEqual([luz]);
    expect(buscarEnLibreta(libreta, '')).toHaveLength(3);
  });

  it('encuentra por los últimos números del documento o del celular', () => {
    expect(buscarEnLibreta(libreta, '5678')).toEqual([luz]);
    expect(buscarEnLibreta(libreta, '456')).toEqual([jose]);
    expect(buscarEnLibreta(libreta, '315 777 8888')).toEqual([luz]);
    expect(buscarEnLibreta(libreta, '1124509012')).toEqual([ana]);
  });

  it('pregunta al servidor desde 3 letras o números', () => {
    expect(buscaEnServidor('lu')).toBe(false);
    expect(buscaEnServidor(' luz ')).toBe(true);
  });

  it('junta lo del servidor sin repetir y ordena por nombre', () => {
    expect(juntar([luz], [luz, ana])).toEqual([luz, ana]);
    expect(ordenarLibreta(libreta).map((c) => c.nombre)).toEqual([
      'Ana Jamioy',
      'José Muñoz',
      'Luz Marina Chindoy',
    ]);
  });
});

describe('filtros y resumen', () => {
  it('"Sin app aún" deja a quienes no tienen la app activa', () => {
    expect(filtrar(libreta, 'SIN_APP')).toEqual([luz, ana]);
    expect(filtrar(libreta, 'TODOS')).toHaveLength(3);
  });

  it('cuenta clientes y cuántos no usan la app', () => {
    expect(resumenLibreta(libreta)).toBe('3 clientes · 2 sin app aún');
    expect(resumenLibreta([jose])).toBe('1 cliente');
  });
});

describe('datos tapados y legibles', () => {
  it('tapa documento y celular, salvo que ya vengan tapados', () => {
    expect(taparDocumento('1124505678')).toBe('****5678');
    expect(taparDocumento('****5678')).toBe('****5678');
    expect(taparCelular('+573157778888')).toBe('••• 8888');
    expect(taparCelular('••• 8888')).toBe('••• 8888');
    expect(taparCelular(null)).toBeNull();
  });

  it('muestra el celular como lo escribe la gente', () => {
    expect(celularLegible('+573157778888')).toBe('315 777 8888');
    expect(celularLegible('••• 8888')).toBe('••• 8888');
    expect(celularLegible(null)).toBe('Sin celular');
  });

  it('dice la fecha en palabras, en hora de Colombia', () => {
    expect(fechaLegible(new Date('2026-10-04T15:00:00Z'))).toBe('4 de octubre de 2026');
  });

  it('una ficha completa se vuelve un renglón tapado', () => {
    const ficha: FichaCliente = {
      clienteId: 'c1',
      personaId: 'p1',
      nombre: 'Luz Marína Chindoy',
      nombres: 'Luz Marína',
      apellidos: 'Chindoy',
      tipoDocumento: 'CC',
      documento: '1124505678',
      celular: '+573157778888',
      datosCompletos: true,
      cuenta: 'PENDIENTE',
      estado: 'ACTIVE',
      canal: 'ASSISTED_REGISTRATION',
      afiliadoEn: new Date(),
    };
    expect(aRenglon(ficha)).toEqual({
      clienteId: 'c1',
      nombre: 'Luz Marína Chindoy',
      nombreBusqueda: 'luz marina chindoy',
      documento: '****5678',
      documentoFinal: '5678',
      celular: '••• 8888',
      celularFinal: '8888',
      cuenta: 'PENDIENTE',
      estado: 'ACTIVE',
    });
    expect(aRenglon({ ...ficha, celular: null }).celularFinal).toBeNull();
  });
});

describe('registro asistido', () => {
  const cc = { codigo: 'CC', nombre: 'Cédula de ciudadanía', patron: '^[0-9]{6,10}$' };

  it('lo escrito en el buscador sirve de documento o de nombre', () => {
    expect(datoInicial('1.124.505.678')).toEqual({ numeroDocumento: '1124505678', nombres: '' });
    expect(datoInicial('Luz')).toEqual({ numeroDocumento: '', nombres: 'Luz' });
    expect(datoInicial('  ')).toEqual({ numeroDocumento: '', nombres: '' });
  });

  it('revisa el número según el tipo de documento', () => {
    expect(revisarNumero('', cc)).toBe('Escribe el número del documento.');
    expect(revisarNumero('12', cc)).toBe('Revisa el número: no parece de cédula de ciudadanía.');
    expect(revisarNumero('1124505678', cc)).toBeNull();
    expect(revisarNumero('AB123', { codigo: 'PASSPORT', nombre: 'Pasaporte', patron: null })).toBe(
      null,
    );
  });

  it('pide nombre y un celular de 10 números que empiece por 3', () => {
    expect(celularValido('315 777 8888')).toBe(true);
    expect(celularValido('+57 315 777 8888')).toBe(true);
    expect(celularValido('6017778888')).toBe(false);
    expect(faltaEnPersonaNueva(' ', '3157778888')).toBe('Escribe su nombre.');
    expect(faltaEnPersonaNueva('Luz', '123')).toMatch(/Revisa el celular/);
    expect(faltaEnPersonaNueva('Luz', '3157778888')).toBeNull();
  });
});
