import { ConsultarSalud } from './consultar-salud.use-case';

describe('ConsultarSalud', () => {
  it('está ok cuando la base responde', async () => {
    const caso = new ConsultarSalud({ responde: async () => true }, '1.2.3');
    await expect(caso.ejecutar()).resolves.toEqual({
      estado: 'ok',
      baseDatos: 'ok',
      version: '1.2.3',
    });
  });

  it('queda degradada si la base falla o lanza un error', async () => {
    const caso = new ConsultarSalud({ responde: () => Promise.reject(new Error('x')) }, 'v');
    await expect(caso.ejecutar()).resolves.toMatchObject({
      estado: 'degradado',
      baseDatos: 'sin-conexion',
    });
  });
});
