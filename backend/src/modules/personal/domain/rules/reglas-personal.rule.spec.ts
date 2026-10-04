import { Miembro } from '../entities/miembro';
import { asegurarCupo, asegurarQueSePuedeGestionar } from './reglas-personal.rule';

describe('reglas del equipo', () => {
  const cajero: Miembro = {
    membresiaId: 'm1',
    usuarioId: 'u1',
    nombre: 'Jhon',
    celular: '+573100000102',
    estado: 'ACTIVE',
    roles: ['CASHIER'],
  };

  it('respeta el cupo de cajeros del plan', () => {
    expect(() => asegurarCupo({ ocupados: 1, limite: 2 })).not.toThrow();
    expect(() => asegurarCupo({ ocupados: 2, limite: 2 })).toThrow('Tu plan permite 2 cajeros');
    expect(() => asegurarCupo({ ocupados: 1, limite: 1 })).toThrow('1 cajero.');
    expect(() => asegurarCupo({ ocupados: 50, limite: null })).not.toThrow();
  });

  it('no deja gestionarse a uno mismo ni al propietario', () => {
    expect(() => asegurarQueSePuedeGestionar(cajero, 'dueno')).not.toThrow();
    expect(() => asegurarQueSePuedeGestionar(cajero, 'u1')).toThrow('propia cuenta');
    expect(() => asegurarQueSePuedeGestionar({ ...cajero, roles: ['OWNER'] }, 'otro')).toThrow(
      'propietario',
    );
  });
});
