import { CuentaBloqueada } from '../../domain/errors/cuenta-bloqueada.error';
import { CredencialesIncorrectas } from '../../domain/errors/credenciales-incorrectas.error';
import { CuentaNoHabilitada } from '../../domain/errors/cuenta-no-habilitada.error';
import { IngresoInput } from '../dto/ingreso.input';
import { AutenticacionEnMemoria } from './autenticacion-en-memoria.fake';
import { DefinirPinNuevo } from './definir-pin-nuevo.use-case';
import { IniciarSesion } from './iniciar-sesion.use-case';

describe('IniciarSesion (HU-02-01)', () => {
  let db: AutenticacionEnMemoria;
  let iniciar: IniciarSesion;
  const dispositivo = { id: 'cel-1', plataforma: 'ANDROID' as const };
  const conPin = (pin: string, celular = '310 000 0102'): IngresoInput => ({
    via: 'PIN',
    identificador: celular,
    secreto: pin,
    dispositivo,
    ip: null,
  });
  const jhon = {
    usuarioId: 'u2',
    personaId: 'p2',
    nombre: 'Jhon',
    puedeEntrar: true,
    pendienteDeActivar: false,
  };

  beforeEach(() => {
    db = new AutenticacionEnMemoria();
    db.agregarCuenta(jhon, '+573100000102', '246813');
    const { base, emisor, comprobador } = db.piezas();
    iniciar = new IniciarSesion({
      ...base,
      intentos: db.intentosIngreso,
      comprobador,
      firmador: db.firmador,
      emisor,
    });
  });

  it('con celular y PIN correctos abre sesión en el dispositivo', async () => {
    const resultado = await iniciar.ejecutar(conPin('246813'));
    expect(resultado.tipo).toBe('SESION');
    if (resultado.tipo !== 'SESION') return;
    expect(resultado.sesion.usuario).toEqual({ id: 'u2', nombre: 'Jhon' });
    expect(resultado.sesion.segundosAcceso).toBe(900);
    const [sesion] = db.sesiones.values();
    expect(sesion).toMatchObject({ usuarioId: 'u2', dispositivoId: 'cel-1', cerrada: false });
    expect(sesion.expiraEn).toEqual(new Date('2026-11-04T12:00:00Z'));
    expect(db.intentos.at(-1)?.motivoFallo).toBeNull();
  });

  it('el mismo mensaje si el celular no existe o el PIN no coincide', async () => {
    const otro = iniciar.ejecutar(conPin('246813', '3209999999'));
    await expect(otro).rejects.toThrow(CredencialesIncorrectas);
    await expect(iniciar.ejecutar(conPin('111222'))).rejects.toThrow(
      'El celular o el PIN no coinciden',
    );
    expect(db.intentos.map((i) => i.motivoFallo)).toEqual(['UNKNOWN_IDENTIFIER', 'WRONG_SECRET']);
    expect(db.intentos[0].huellaIdentificador).toBe('h(+573209999999)');
  });

  it('al quinto PIN errado bloquea 15 minutos y lo deja en auditoría', async () => {
    for (let i = 0; i < 4; i++) {
      await expect(iniciar.ejecutar(conPin('111222'))).rejects.toThrow(CredencialesIncorrectas);
    }
    await expect(iniciar.ejecutar(conPin('111222'))).rejects.toThrow(CuentaBloqueada);
    await expect(iniciar.ejecutar(conPin('246813'))).rejects.toThrow('15 minutos');
    expect(db.auditoria).toEqual([
      expect.objectContaining({ accion: 'LOGIN_LOCKED', comercioId: null }),
    ]);
    db.ahora = new Date('2026-10-05T12:15:00Z');
    await expect(iniciar.ejecutar(conPin('246813'))).resolves.toMatchObject({ tipo: 'SESION' });
  });

  it('una cuenta suspendida por VECI no entra aunque el PIN sea correcto', async () => {
    db.cuentas.set('u2', { ...jhon, puedeEntrar: false });
    await expect(iniciar.ejecutar(conPin('246813'))).rejects.toThrow(CuentaNoHabilitada);
    expect(db.intentos.at(-1)?.motivoFallo).toBe('USER_NOT_ALLOWED');
  });

  it('con PIN temporal pide crear el propio y recién ahí abre sesión (HU-02-05)', async () => {
    const ana = {
      usuarioId: 'u9',
      personaId: 'p9',
      nombre: 'Ana',
      puedeEntrar: false,
      pendienteDeActivar: true,
    };
    db.agregarCuenta(ana, '+573124567890', '730284', true);
    const resultado = await iniciar.ejecutar(conPin('730284', '312 456 7890'));
    expect(resultado).toMatchObject({ tipo: 'CAMBIO_DE_PIN', nombre: 'Ana' });
    expect(db.sesiones.size).toBe(0);
    if (resultado.tipo !== 'CAMBIO_DE_PIN') return;

    const { base, emisor } = db.piezas();
    const definir = new DefinirPinNuevo({ ...base, firmador: db.firmador, emisor });
    const entrada = { tokenCambio: resultado.tokenCambio, pinNuevo: '190573', dispositivo };
    await expect(definir.ejecutar({ ...entrada, pinNuevo: '123456' })).rejects.toThrow('fácil');
    await expect(definir.ejecutar({ ...entrada, pinNuevo: '730284' })).rejects.toThrow('distinto');
    await expect(definir.ejecutar(entrada)).resolves.toMatchObject({ usuario: { id: 'u9' } });
    expect(db.cuentas.get('u9')).toMatchObject({ puedeEntrar: true, pendienteDeActivar: false });
    await expect(definir.ejecutar(entrada)).rejects.toMatchObject({
      codigo: 'CAMBIO_DE_PIN_NO_VALIDO',
    });
  });

  it('el paso de crear PIN no sirve desde otro dispositivo ni vencido', async () => {
    const ana = {
      usuarioId: 'u9',
      personaId: 'p9',
      nombre: 'Ana',
      puedeEntrar: false,
      pendienteDeActivar: true,
    };
    db.agregarCuenta(ana, '+573124567890', '730284', true);
    const resultado = await iniciar.ejecutar(conPin('730284', '3124567890'));
    if (resultado.tipo !== 'CAMBIO_DE_PIN') throw new Error('se esperaba cambio de PIN');
    const { base, emisor } = db.piezas();
    const definir = new DefinirPinNuevo({ ...base, firmador: db.firmador, emisor });
    const entrada = { tokenCambio: resultado.tokenCambio, pinNuevo: '190573' };
    await expect(
      definir.ejecutar({ ...entrada, dispositivo: { id: 'otro', plataforma: 'WEB' } }),
    ).rejects.toMatchObject({ codigo: 'CAMBIO_DE_PIN_NO_VALIDO' });
    db.ahora = new Date('2026-10-05T12:11:00Z');
    await expect(definir.ejecutar({ ...entrada, dispositivo })).rejects.toMatchObject({
      codigo: 'CAMBIO_DE_PIN_NO_VALIDO',
    });
  });

  it('el panel acepta correo y contraseña con las mismas reglas (HU-02-02)', async () => {
    db.identificadores.set('EMAIL:marta@lavecina.co', 'u2');
    db.crearCredencial('u2', 'PASSWORD', 'hash:almuerzo2026', false);
    const correo = {
      ...conPin('almuerzo2026'),
      via: 'CONTRASENA' as const,
      identificador: 'Marta@LaVecina.co',
    };
    await expect(iniciar.ejecutar(correo)).resolves.toMatchObject({ tipo: 'SESION' });
    await expect(iniciar.ejecutar({ ...correo, secreto: 'otra' })).rejects.toThrow(
      'El correo o la contraseña no coinciden',
    );
  });
});
