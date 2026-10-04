import { EstadoSesion } from '../../application/contexto/verificador-sesion.port';
import { SesionNoValida } from '../../domain/errores/sesion-no-valida.error';
import { FirmadorHs256 } from '../tokens/firmador-hs256';
import { IdentidadDesarrolloResolvedor } from './identidad-desarrollo.resolvedor';
import { IdentidadTokenResolvedor } from './identidad-token.resolvedor';

describe('IdentidadTokenResolvedor', () => {
  let ahora = new Date('2026-10-05T12:00:00Z');
  let estado: EstadoSesion = 'activa';
  const firmador = new FirmadorHs256('secreto-de-pruebas-con-32-caracteres!', {
    ahora: () => ahora,
  });
  const resolvedor = new IdentidadTokenResolvedor(firmador, { estado: async () => estado }, null);
  const usuario = '0192f000-0000-7000-8000-000000000001';
  const conToken = (token: string) => ({ authorization: `Bearer ${token}` });
  const acceso = () => firmador.firmar({ typ: 'acceso', sub: usuario, sid: 's1', dev: 'd1' }, 900);

  beforeEach(() => {
    ahora = new Date('2026-10-05T12:00:00Z');
    estado = 'activa';
  });

  it('devuelve usuario, sesión y dispositivo del token', async () => {
    await expect(resolvedor.resolver(conToken(acceso()))).resolves.toEqual({
      usuarioId: usuario,
      sesionId: 's1',
      dispositivoId: 'd1',
    });
  });

  it('sin token no hay identidad', async () => {
    await expect(resolvedor.resolver({})).resolves.toBeNull();
  });

  it('un token de otro tipo o mal firmado no da identidad', async () => {
    const cambio = firmador.firmar({ typ: 'cambio-pin', sub: usuario, sid: 's1' }, 600);
    await expect(resolvedor.resolver(conToken(cambio))).resolves.toBeNull();
    await expect(resolvedor.resolver(conToken('a.b.c'))).resolves.toBeNull();
  });

  it('avisa si el token venció o la sesión se cerró', async () => {
    const token = acceso();
    estado = 'cerrada';
    await expect(resolvedor.resolver(conToken(token))).rejects.toThrow(SesionNoValida);
    estado = 'vencida';
    await expect(resolvedor.resolver(conToken(token))).rejects.toMatchObject({
      codigo: 'SESION_VENCIDA',
    });
    ahora = new Date('2026-10-05T13:00:00Z');
    await expect(resolvedor.resolver(conToken(token))).rejects.toMatchObject({
      codigo: 'TOKEN_VENCIDO',
    });
  });

  it('sin token usa la identidad de desarrollo si está activa', async () => {
    const conRespaldo = new IdentidadTokenResolvedor(
      firmador,
      { estado: async () => 'activa' },
      new IdentidadDesarrolloResolvedor(true),
    );
    await expect(conRespaldo.resolver({ 'x-veci-usuario': usuario })).resolves.toEqual({
      usuarioId: usuario,
      sesionId: null,
      dispositivoId: null,
    });
  });
});
