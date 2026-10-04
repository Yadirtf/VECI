import { GeneradorUuidV7 } from './uuid-v7.generador';

describe('GeneradorUuidV7', () => {
  const generador = new GeneradorUuidV7();

  it('genera UUID versión 7 con variante RFC', () => {
    expect(generador.siguiente()).toMatch(
      /^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/,
    );
  });

  it('los ids quedan ordenados por tiempo', async () => {
    const primero = generador.siguiente();
    await new Promise((resolver) => setTimeout(resolver, 2));
    expect(generador.siguiente() > primero).toBe(true);
  });
});
