import { CajeroEnSedes, CupoDeSedes, Sede } from '../../domain/entities/sede';
import { CambiosSede, DatosSede, SedesRepository } from '../puertos/sedes.repository';
import { GestionarSedes } from './sedes.use-case';

class SedesEnMemoria implements SedesRepository {
  sedes: Sede[] = [this.sede('principal', 'Principal', true)];
  cupoActual: CupoDeSedes = { ocupadas: 1, limite: 1, variasSedes: false };
  asignaciones: [string, readonly string[]][] = [];

  sede(sedeId: string, nombre: string, principal = false): Sede {
    return {
      sedeId,
      nombre,
      principal,
      estado: 'ACTIVE',
      activa: true,
      municipioId: null,
      municipio: null,
      direccion: null,
    };
  }

  async listar() {
    return this.sedes;
  }
  async buscar(id: string) {
    return this.sedes.find((s) => s.sedeId === id) ?? null;
  }
  async cajeros(): Promise<CajeroEnSedes[]> {
    return [{ membresiaId: 'jhon', nombre: 'Jhon', sedeIds: [] }];
  }
  async cupo() {
    return this.cupoActual;
  }
  async crear(sedeId: string, d: DatosSede) {
    this.sedes.push(this.sede(sedeId, d.nombre));
  }
  async actualizar(sedeId: string, c: CambiosSede) {
    this.sedes = this.sedes.map((s) =>
      s.sedeId === sedeId
        ? { ...s, activa: c.activa ?? s.activa, nombre: c.nombre ?? s.nombre }
        : s,
    );
  }
  async esCajero(id: string) {
    return id === 'jhon';
  }
  async asignar(id: string, sedeIds: readonly string[]) {
    this.asignaciones.push([id, sedeIds]);
  }
}

describe('Sedes (HU-03-03)', () => {
  let repo: SedesEnMemoria;
  let sedes: GestionarSedes;

  beforeEach(() => {
    repo = new SedesEnMemoria();
    sedes = new GestionarSedes(repo, { siguiente: () => 'norte' });
  });

  it('sin el plan Pro no abre otra sede', async () => {
    await expect(
      sedes.crear({ nombre: 'Norte', municipioId: null, direccion: null }),
    ).rejects.toThrow('plan Pro');
  });

  it('con el plan Pro abre otra sede hasta el límite', async () => {
    repo.cupoActual = { ocupadas: 1, limite: null, variasSedes: true };
    const nueva = await sedes.crear({ nombre: '  Norte ', municipioId: null, direccion: null });
    expect(nueva.nombre).toBe('Norte');
    repo.cupoActual = { ocupadas: 3, limite: 3, variasSedes: true };
    await expect(
      sedes.crear({ nombre: 'Sur', municipioId: null, direccion: null }),
    ).rejects.toThrow('permite 3 sedes');
  });

  it('la sede principal no se desactiva', async () => {
    await expect(sedes.editar('principal', { activa: false })).rejects.toThrow('principal');
  });

  it('asigna cajeros solo a sedes activas', async () => {
    await sedes.asignar('jhon', ['principal', 'principal'], 'marta');
    expect(repo.asignaciones).toEqual([['jhon', ['principal']]]);
    await expect(sedes.asignar('jhon', ['otra'], 'marta')).rejects.toThrow('esa sede');
    await expect(sedes.asignar('marta', [], 'marta')).rejects.toThrow('Solo los cajeros');
  });

  it('el mapa junta sedes, cajeros y cupo', async () => {
    const mapa = await sedes.mapa();
    expect(mapa.sedes).toHaveLength(1);
    expect(mapa.cajeros[0].sedeIds).toEqual([]);
    expect(mapa.cupo.variasSedes).toBe(false);
  });
});
