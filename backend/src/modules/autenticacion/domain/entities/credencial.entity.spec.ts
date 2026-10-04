import { Credencial } from './credencial.entity';

describe('Credencial', () => {
  const ahora = new Date('2026-10-05T12:00:00Z');
  const crear = (intentosFallidos = 0, bloqueadaHasta: Date | null = null) =>
    Credencial.desde({
      id: 'c1',
      usuarioId: 'u1',
      tipo: 'PIN',
      hash: 'h',
      debeCambiar: false,
      intentosFallidos,
      bloqueadaHasta,
      reglas: { maxIntentos: 5, minutosBloqueo: 15 },
    });

  it('se bloquea 15 minutos al quinto intento fallido', () => {
    const credencial = crear(3);
    expect(credencial.registrarFallo(ahora)).toBe(false);
    expect(credencial.intentosFallidos).toBe(4);
    expect(credencial.registrarFallo(ahora)).toBe(true);
    expect(credencial.estaBloqueada(ahora)).toBe(true);
    expect(credencial.bloqueadaHasta).toEqual(new Date('2026-10-05T12:15:00Z'));
    expect(credencial.minutosRestantes(new Date('2026-10-05T12:05:30Z'))).toBe(10);
  });

  it('el bloqueo se levanta solo al pasar el tiempo', () => {
    const credencial = crear(0, new Date('2026-10-05T12:15:00Z'));
    expect(credencial.estaBloqueada(new Date('2026-10-05T12:15:00Z'))).toBe(false);
  });

  it('un ingreso correcto reinicia la cuenta', () => {
    const credencial = crear(4);
    credencial.registrarExito();
    expect(credencial.intentosFallidos).toBe(0);
    expect(credencial.bloqueadaHasta).toBeNull();
  });
});
