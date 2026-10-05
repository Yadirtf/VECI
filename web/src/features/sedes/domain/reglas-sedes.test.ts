import { alternarSede, puedeAgregarSede, trabajaEn } from './reglas-sedes';
import type { CajeroEnSedes, Sede } from './sede';

const sede = (id: string, activa = true): Sede => ({
  id,
  nombre: id,
  principal: id === 'principal',
  activa,
  municipio: null,
  direccion: null,
});
const sedes = [sede('principal'), sede('parque'), sede('vieja', false)];
const cajero = (sedeIds: string[]): CajeroEnSedes => ({ membresiaId: 'm', nombre: 'Ana', sedeIds });

describe('puedeAgregarSede', () => {
  it('solo con un plan de varias sedes y cupo libre', () => {
    expect(puedeAgregarSede({ ocupadas: 1, limite: 1, variasSedes: false })).toBe(false);
    expect(puedeAgregarSede({ ocupadas: 2, limite: 3, variasSedes: true })).toBe(true);
    expect(puedeAgregarSede({ ocupadas: 3, limite: 3, variasSedes: true })).toBe(false);
    expect(puedeAgregarSede({ ocupadas: 9, limite: null, variasSedes: true })).toBe(true);
  });
});

describe('alternarSede', () => {
  it('sin sedes asignadas trabaja en todas', () => {
    expect(trabajaEn(cajero([]), 'parque')).toBe(true);
  });

  it('quitar una sede a quien estaba en todas deja las demás activas', () => {
    expect(alternarSede(cajero([]), 'parque', sedes)).toEqual(['principal']);
  });

  it('si vuelve a quedar en todas las activas se guarda vacío', () => {
    expect(alternarSede(cajero(['principal']), 'parque', sedes)).toEqual([]);
  });
});
