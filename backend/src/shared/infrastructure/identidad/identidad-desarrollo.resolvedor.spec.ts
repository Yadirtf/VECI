import { IdentidadDesarrolloResolvedor } from './identidad-desarrollo.resolvedor';

describe('IdentidadDesarrolloResolvedor', () => {
  const usuario = 'D4000000-0000-7000-8000-000000000002';

  it('toma el usuario de la cabecera cuando está activa', async () => {
    const resolvedor = new IdentidadDesarrolloResolvedor(true);
    await expect(resolvedor.resolver({ 'x-veci-usuario': usuario })).resolves.toEqual({
      usuarioId: usuario.toLowerCase(),
      sesionId: null,
      dispositivoId: null,
    });
  });

  it('ignora la cabecera cuando está apagada (staging y producción)', async () => {
    const resolvedor = new IdentidadDesarrolloResolvedor(false);
    await expect(resolvedor.resolver({ 'x-veci-usuario': usuario })).resolves.toBeNull();
  });

  it('ignora valores que no son UUID', async () => {
    const resolvedor = new IdentidadDesarrolloResolvedor(true);
    await expect(resolvedor.resolver({ 'x-veci-usuario': "1' OR '1'='1" })).resolves.toBeNull();
  });
});
