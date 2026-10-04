import { describe, expect, it } from 'vitest';
import type { Miembro } from './equipo';
import {
  celularLegible,
  cuantoHace,
  opcionesPara,
  ordenarDispositivos,
  ordenarEquipo,
} from './reglas-equipo';

const miembro = (nombre: string, estado: Miembro['estado'], roles = ['CASHIER']): Miembro => ({
  membresiaId: nombre,
  usuarioId: nombre,
  nombre,
  celular: '+573100000102',
  estado,
  roles,
});

describe('reglas del equipo', () => {
  it('a un cajero activo se le puede dar PIN nuevo, suspender o retirar', () => {
    expect(opcionesPara(miembro('Jhon', 'ACTIVE'))).toEqual([
      'RESTABLECER_PIN',
      'SUSPENDER',
      'RETIRAR',
    ]);
    expect(opcionesPara(miembro('Ana', 'SUSPENDED'))).toEqual(['REACTIVAR', 'RETIRAR']);
    expect(opcionesPara(miembro('Ex', 'REMOVED'))).toEqual([]);
  });

  it('a los propietarios no se les gestiona desde aquí', () => {
    expect(opcionesPara(miembro('Marta', 'ACTIVE', ['OWNER']))).toEqual([]);
  });

  it('muestra el celular como lo escribe la gente', () => {
    expect(celularLegible('+573100000102')).toBe('310 000 0102');
    expect(celularLegible(null)).toBe('Sin celular');
  });

  it('ordena propietarios, luego cajeros, y los retirados al final', () => {
    const orden = ordenarEquipo([
      miembro('Zoe', 'REMOVED'),
      miembro('Jhon', 'ACTIVE'),
      miembro('Marta', 'ACTIVE', ['OWNER']),
    ]).map((m) => m.nombre);
    expect(orden).toEqual(['Marta', 'Jhon', 'Zoe']);
  });

  it('pone primero los dispositivos con sesión abierta', () => {
    const viejo = {
      dispositivoId: 'a',
      nombre: null,
      plataforma: 'WEB',
      ultimaVez: new Date(1),
      sesiones: [],
    };
    const conSesion = {
      ...viejo,
      dispositivoId: 'b',
      sesiones: [{ sesionId: 's', nombre: 'Jhon', ultimoUso: new Date(0) }],
    };
    expect(ordenarDispositivos([viejo, conSesion]).map((d) => d.dispositivoId)).toEqual(['b', 'a']);
  });

  it('dice hace cuánto en palabras', () => {
    const ahora = new Date('2026-10-04T12:00:00Z');
    const antes = (min: number) => new Date(ahora.getTime() - min * 60_000);
    expect(cuantoHace(antes(1), ahora)).toBe('ahora mismo');
    expect(cuantoHace(antes(15), ahora)).toBe('hace 15 minutos');
    expect(cuantoHace(antes(60), ahora)).toBe('hace 1 hora');
    expect(cuantoHace(antes(60 * 30), ahora)).toBe('ayer');
    expect(cuantoHace(antes(60 * 24 * 3), ahora)).toBe('hace 3 días');
  });
});
