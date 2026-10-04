import { AutenticacionEnMemoria } from './autenticacion-en-memoria.fake';
import { ActivarComercio } from './activar-comercio.use-case';
import { CambiarPin } from './cambiar-pin.use-case';
import { DefinirCorreoYContrasena } from './definir-correo-y-contrasena.use-case';

describe('Mi cuenta', () => {
  let db: AutenticacionEnMemoria;
  const identidad = { usuarioId: 'u2', sesionId: 's1', dispositivoId: 'cel-1' };
  const cuenta = {
    usuarioId: 'u2',
    personaId: 'p2',
    nombre: 'Jhon',
    puedeEntrar: true,
    pendienteDeActivar: false,
  };

  beforeEach(() => {
    db = new AutenticacionEnMemoria();
    db.agregarCuenta(cuenta, '+573100000102', '246813');
  });

  it('cambia el PIN si el actual coincide', async () => {
    const { base, comprobador } = db.piezas();
    const cambiar = new CambiarPin({ ...base, comprobador });
    await expect(
      cambiar.ejecutar({ identidad, pinActual: '000001', pinNuevo: '190573' }),
    ).rejects.toThrow('El PIN actual no coincide');
    await cambiar.ejecutar({ identidad, pinActual: '246813', pinNuevo: '190573' });
    expect(db.vigente('u2', 'PIN')?.hash).toBe('hash:190573');
  });

  it('agrega correo y contraseña confirmando con el PIN (HU-02-02)', async () => {
    const { base, comprobador } = db.piezas();
    const definir = new DefinirCorreoYContrasena({ ...base, comprobador });
    const entrada = {
      identidad,
      correo: 'Jhon@Correo.co',
      contrasena: 'almuerzo2026',
      pinActual: '246813',
    };
    await expect(definir.ejecutar({ ...entrada, contrasena: 'corta' })).rejects.toThrow(
      '8 caracteres',
    );
    await expect(definir.ejecutar(entrada)).resolves.toEqual({ correo: 'jhon@correo.co' });
    expect(db.identificadores.get('EMAIL:jhon@correo.co')).toBe('u2');
    expect(db.vigente('u2', 'PASSWORD')?.hash).toBe('hash:almuerzo2026');
  });

  it('elige comercio: acepta la invitación y devuelve los permisos (HU-02-03)', async () => {
    db.roles.push(
      {
        comercioId: 'u2-restaurante',
        nombre: 'La Vecina',
        tipoNegocio: 'RESTAURANT',
        rol: 'CASHIER',
        esInvitacion: true,
      },
      {
        comercioId: 'u2-panaderia',
        nombre: 'El Trigal',
        tipoNegocio: 'BAKERY',
        rol: 'CUSTOMER',
        esInvitacion: false,
      },
    );
    const { espacios } = db.piezas();
    const activar = new ActivarComercio({
      espacios: db.repoEspacios,
      consultar: espacios,
      membresias: {
        esMiembroActivo: async () => true,
        permisosEn: async () => new Set(['prepaid.sell', 'consumptions.register']),
      },
      auditoria: db.bitacora,
    });
    const cajera = await activar.ejecutar(identidad, 'U2-RESTAURANTE');
    expect(cajera).toEqual({
      comercio: expect.objectContaining({
        comercioId: 'u2-restaurante',
        invitacionPendiente: false,
      }),
      permisos: ['consumptions.register', 'prepaid.sell'],
    });
    expect(db.aceptadas).toEqual(['u2@u2-restaurante']);
    expect(db.auditoria[0]).toMatchObject({
      accion: 'MEMBERSHIP_CHANGED',
      comercioId: 'u2-restaurante',
    });
    await expect(activar.ejecutar(identidad, 'u2-panaderia')).resolves.toMatchObject({
      permisos: [],
    });
    await expect(activar.ejecutar(identidad, 'otro')).rejects.toMatchObject({
      codigo: 'SIN_ACCESO_AL_COMERCIO',
    });
  });
});
