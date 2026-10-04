import { AlmacenContextoAsincrono } from './almacen-contexto-asincrono';

describe('AlmacenContextoAsincrono', () => {
  const almacen = new AlmacenContextoAsincrono();
  const esperar = () => new Promise((resolver) => setTimeout(resolver, 5));

  it('aísla el comercio de peticiones concurrentes', async () => {
    const leer = (comercioId: string) =>
      almacen.ejecutar(async () => {
        almacen.fijarComercio({ comercioId, usuarioId: 'u' });
        await esperar();
        return almacen.comercioActual()?.comercioId;
      });

    await expect(Promise.all([leer('a'), leer('b')])).resolves.toEqual(['a', 'b']);
  });

  it('fuera de una petición no hay comercio', () => {
    expect(almacen.comercioActual()).toBeNull();
  });

  it('no permite fijar un comercio fuera de una petición', () => {
    expect(() => almacen.fijarComercio({ comercioId: 'a', usuarioId: 'u' })).toThrow('middleware');
  });
});
