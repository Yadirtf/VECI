import { createPublicKey, verify } from 'node:crypto';
import { FirmadorQrEd25519 } from './firmador-qr-ed25519';

describe('FirmadorQrEd25519 (ADR-0005)', () => {
  const firmador = new FirmadorQrEd25519('secreto-de-prueba-para-firmar-qr-0123456789');
  const comercioA = { comercioId: 'a', keyId: 'k1' };
  const comercioB = { comercioId: 'b', keyId: 'k1' };
  const veci = { comercioId: null, keyId: 'p1' };

  it('firma y verifica con la clave del comercio', () => {
    const firma = firmador.firmar(comercioA, 'V1.abc');
    expect(Buffer.from(firma, 'base64url')).toHaveLength(64);
    expect(firmador.verificar(comercioA, 'V1.abc', firma)).toBe(true);
    expect(firmador.verificar(comercioA, 'V1.abd', firma)).toBe(false);
  });

  it('la firma de un comercio no sirve en otro ni como firma de VECI', () => {
    const firma = firmador.firmar(comercioA, 'V1.abc');
    expect(firmador.verificar(comercioB, 'V1.abc', firma)).toBe(false);
    expect(firmador.verificar(veci, 'V1.abc', firma)).toBe(false);
    expect(firmador.verificar(comercioA, 'V1.abc', 'corta')).toBe(false);
  });

  it('las claves son estables: mismo secreto, misma clave pública', () => {
    const otro = new FirmadorQrEd25519('secreto-de-prueba-para-firmar-qr-0123456789');
    expect(otro.clavePublica(comercioA)).toEqual(firmador.clavePublica(comercioA));
    expect(firmador.clavePublica(comercioA)).toHaveLength(32);
    expect(firmador.clavePublica(comercioA)).not.toEqual(firmador.clavePublica(comercioB));
  });

  it('la clave pública cruda verifica fuera de la API (como en el celular del cajero)', () => {
    const cruda = Buffer.from(firmador.clavePublica(comercioA));
    const spki = Buffer.concat([Buffer.from('302a300506032b6570032100', 'hex'), cruda]);
    const publica = createPublicKey({ key: spki, format: 'der', type: 'spki' });
    const firma = Buffer.from(firmador.firmar(comercioA, 'V1.xyz'), 'base64url');
    expect(verify(null, Buffer.from('V1.xyz'), publica, firma)).toBe(true);
  });

  it('exige un secreto largo', () => {
    expect(() => new FirmadorQrEd25519('corto')).toThrow('VECI_QR_SECRETO');
  });
});
