import { SesionNoValida } from '../../../../shared/domain/errores/sesion-no-valida.error';
import { AutenticacionEnMemoria } from './autenticacion-en-memoria.fake';
import { CerrarSesion } from './cerrar-sesion.use-case';
import { EmitirPinTemporal } from './emitir-pin-temporal.use-case';
import { RenovarSesion } from './renovar-sesion.use-case';

describe('Sesiones por dispositivo (HU-02-01, HU-02-06)', () => {
  let db: AutenticacionEnMemoria;
  let renovar: RenovarSesion;
  let tokenRenovacion: string;
  const cuenta = {
    usuarioId: 'u2',
    personaId: 'p2',
    nombre: 'Jhon',
    puedeEntrar: true,
    pendienteDeActivar: false,
  };

  beforeEach(async () => {
    db = new AutenticacionEnMemoria();
    db.agregarCuenta(cuenta, '+573100000102', '246813');
    const { base, emisor } = db.piezas();
    renovar = new RenovarSesion({ ...base, emisor, reloj: db.reloj });
    ({ tokenRenovacion } = await emisor.abrir(cuenta, { id: 'cel-1', plataforma: 'ANDROID' }));
  });

  it('renueva cambiando el token y extiende la sesión', async () => {
    db.ahora = new Date('2026-10-20T12:00:00Z');
    const nueva = await renovar.ejecutar(tokenRenovacion);
    expect(nueva.tokenRenovacion).not.toBe(tokenRenovacion);
    expect([...db.sesiones.values()][0].expiraEn).toEqual(new Date('2026-11-19T12:00:00Z'));
  });

  it('si alguien reusa un token viejo, cierra la sesión entera', async () => {
    const nueva = await renovar.ejecutar(tokenRenovacion);
    await expect(renovar.ejecutar(tokenRenovacion)).rejects.toMatchObject({
      codigo: 'SESION_CERRADA',
    });
    expect([...db.sesiones.values()][0].motivo).toBe('TOKEN_REUSE_DETECTED');
    await expect(renovar.ejecutar(nueva.tokenRenovacion)).rejects.toThrow(SesionNoValida);
  });

  it('una sesión sin uso por 30 días se vence', async () => {
    db.ahora = new Date('2026-11-05T12:00:00Z');
    await expect(renovar.ejecutar(tokenRenovacion)).rejects.toMatchObject({
      codigo: 'SESION_VENCIDA',
    });
  });

  it('tokens mal formados o de usuarios suspendidos no renuevan', async () => {
    await expect(renovar.ejecutar('basura')).rejects.toMatchObject({ codigo: 'SESION_CERRADA' });
    db.cuentas.set('u2', { ...cuenta, puedeEntrar: false });
    await expect(renovar.ejecutar(tokenRenovacion)).rejects.toMatchObject({
      codigo: 'SESION_CERRADA',
    });
  });

  it('salir cierra solo la sesión de este dispositivo', async () => {
    const [sesion] = db.sesiones.values();
    await new CerrarSesion(db.repoSesiones).ejecutar({
      usuarioId: 'u2',
      sesionId: sesion.id,
      dispositivoId: 'cel-1',
    });
    expect([...db.sesiones.values()][0]).toMatchObject({ cerrada: true, motivo: 'LOGOUT' });
    await new CerrarSesion(db.repoSesiones).ejecutar({
      usuarioId: 'u2',
      sesionId: null,
      dispositivoId: null,
    });
  });

  const soloAqui = { otrosNegociosComoPersonal: 0, esEquipoVeci: false };
  const alcance = { de: jest.fn(async () => soloAqui) };

  it('un PIN restablecido cierra las sesiones, obliga a cambiarlo y queda en auditoría', async () => {
    const { base } = db.piezas();
    const emitir = new EmitirPinTemporal({ ...base, auditoria: db.bitacora, alcance });
    db.secretos.digitos = jest.fn().mockReturnValueOnce('123456').mockReturnValue('730284');
    const pin = await emitir.ejecutar({
      usuarioId: 'u2',
      motivo: 'RESET_BY_OWNER',
      porUsuarioId: 'u1',
      comercioId: 'c1',
    });
    expect(pin).toBe('730284');
    expect(db.vigente('u2', 'PIN')).toMatchObject({ debeCambiar: true, hash: 'hash:730284' });
    expect(db.credenciales[0]).toMatchObject({ revocada: true, motivo: 'RESET_BY_OWNER' });
    expect([...db.sesiones.values()][0]).toMatchObject({
      cerrada: true,
      motivo: 'CREDENTIAL_RESET',
    });
    expect(db.auditoria).toEqual([
      expect.objectContaining({ accion: 'PIN_RESET', comercioId: 'c1' }),
    ]);
  });

  it('una invitación entrega PIN temporal sin cerrar sesiones ni auditar restablecimiento', async () => {
    const { base } = db.piezas();
    const emitir = new EmitirPinTemporal({ ...base, auditoria: db.bitacora, alcance });
    await emitir.ejecutar({
      usuarioId: 'u2',
      motivo: 'INVITACION',
      porUsuarioId: 'u1',
      comercioId: 'c1',
    });
    expect([...db.sesiones.values()][0].cerrada).toBe(false);
    expect(db.auditoria).toEqual([]);
  });

  it('no entrega PIN temporal de una cuenta que también trabaja en otro negocio', async () => {
    const { base } = db.piezas();
    alcance.de.mockResolvedValueOnce({ ...soloAqui, otrosNegociosComoPersonal: 1 });
    const emitir = new EmitirPinTemporal({ ...base, auditoria: db.bitacora, alcance });
    await expect(
      emitir.ejecutar({
        usuarioId: 'u2',
        motivo: 'RESET_BY_OWNER',
        porUsuarioId: 'u1',
        comercioId: 'c1',
      }),
    ).rejects.toMatchObject({ codigo: 'PIN_TEMPORAL_NO_PERMITIDO' });
    expect(alcance.de).toHaveBeenLastCalledWith('u2', 'c1');
    expect(db.vigente('u2', 'PIN')?.debeCambiar).toBeFalsy();
    expect([...db.sesiones.values()][0].cerrada).toBe(false);
  });
});
