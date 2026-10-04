import { Argon2Cifrador } from './argon2-cifrador';

describe('Argon2Cifrador', () => {
  const cifrador = new Argon2Cifrador();

  it('guarda un hash Argon2id que no contiene el PIN', async () => {
    const hash = await cifrador.cifrar('482915');
    expect(hash).toMatch(/^\$argon2id\$/);
    expect(hash).not.toContain('482915');
    await expect(cifrador.coincide(hash, '482915')).resolves.toBe(true);
    await expect(cifrador.coincide(hash, '482916')).resolves.toBe(false);
  });

  it('un hash dañado no coincide ni rompe', async () => {
    await expect(cifrador.coincide('no-es-un-hash', '482915')).resolves.toBe(false);
  });
});
