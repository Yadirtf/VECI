import { GeneradorSecretosCrypto } from './generador-secretos-crypto';

describe('GeneradorSecretosCrypto', () => {
  const generador = new GeneradorSecretosCrypto();

  it('genera tokens distintos de 256 bits', () => {
    const [a, b] = [generador.token(), generador.token()];
    expect(a).not.toBe(b);
    expect(Buffer.from(a, 'base64url')).toHaveLength(32);
  });

  it('genera seis dígitos', () => {
    expect(generador.digitos()).toMatch(/^\d{6}$/);
  });

  it('la huella es SHA-256 en hexadecimal y estable', () => {
    expect(generador.huella('abc')).toBe(
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });
});
