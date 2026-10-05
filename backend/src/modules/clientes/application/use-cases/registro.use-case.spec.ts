import { CifradorSecretos } from '../../../../shared/application/puertos/cifrador-secretos.port';
import { EntrarConCuentaNueva } from '../../../autenticacion';
import { EstadoCuenta } from '../../domain/entities/cliente';
import { leerTokenQr } from '../../domain/value-objects/token-qr.vo';
import {
  ComercioDelCliente,
  MiQrRepository,
  QrPersonalGuardado,
} from '../puertos/mi-qr.repository';
import { RegistroPropio, RegistroRepository } from '../puertos/registro.repository';
import { ClientesEnMemoria, uuid } from './clientes-en-memoria.fake';
import { ConsultarPolitica } from './consultar-politica.use-case';
import { MiQr } from './mi-qr.use-case';
import { Registrarse } from './registrarse.use-case';

class RegistroEnMemoria implements RegistroRepository {
  readonly celulares = new Map<string, 'ACTIVA' | 'PENDIENTE'>();
  readonly documentos = new Map<string, EstadoCuenta>();
  readonly registros: RegistroPropio[] = [];

  async tiposDeDocumento() {
    return [{ codigo: 'CC', nombre: 'Cédula de ciudadanía', patron: '^[0-9]{6,10}$' }];
  }

  async cuentaPorCelular(celular: string) {
    return this.celulares.get(celular) ?? null;
  }

  async cuentaPorDocumento(tipo: string, numero: string) {
    return this.documentos.get(`${tipo}:${numero}`) ?? null;
  }

  async registrar(registro: RegistroPropio) {
    this.registros.push(registro);
    return { usuarioId: 'u-nuevo', personaId: 'p-nueva' };
  }
}

class MiQrEnMemoria implements MiQrRepository {
  readonly qrs: (QrPersonalGuardado & { vigente: boolean })[] = [];
  comerciosDelCliente: ComercioDelCliente[] = [];

  async personaDe() {
    return 'p1';
  }

  async vigente() {
    return this.qrs.find((q) => q.vigente) ?? null;
  }

  async emitirPrimero() {
    return this.emitir();
  }

  async regenerar() {
    this.qrs.forEach((q) => (q.vigente = false));
    return this.emitir();
  }

  async comercios() {
    return this.comerciosDelCliente;
  }

  async emitirQrDeAfiliacion(_en: unknown, _clienteId: string, clave: { keyId: string }) {
    return { qrId: uuid(6), version: 1, keyId: clave.keyId };
  }

  private emitir(): QrPersonalGuardado {
    const qr = {
      qrId: uuid(this.qrs.length + 1),
      version: this.qrs.length + 1,
      emitidoEn: new Date(),
    };
    this.qrs.push({ ...qr, vigente: true });
    return qr;
  }
}

describe('Auto-registro del cliente (HU-04-01)', () => {
  let registro: RegistroEnMemoria;
  let registrarse: Registrarse;
  const entradas: unknown[] = [];
  const entrar = {
    ejecutar: async (usuarioId: string, dispositivo: unknown) => {
      entradas.push({ usuarioId, dispositivo });
      return { usuario: { id: usuarioId, nombre: 'Luz' } };
    },
  } as unknown as EntrarConCuentaNueva;
  const cifrador: CifradorSecretos = {
    cifrar: async (s) => `hash:${s}`,
    coincide: async (h, s) => h === `hash:${s}`,
  };
  const datos = {
    nombres: ' Luz Marina ',
    apellidos: null,
    tipoDocumento: 'CC',
    numeroDocumento: '1124005678',
    celular: '315 777 8888',
    pin: '190573',
    politicaVersionId: 'pol-1',
    dispositivo: { id: 'cel-1', plataforma: 'ANDROID' as const },
    ip: '10.0.0.1',
  };

  beforeEach(() => {
    registro = new RegistroEnMemoria();
    const politicas = new ClientesEnMemoria();
    registrarse = new Registrarse({ registro, politicas, cifrador, entrar });
    entradas.length = 0;
  });

  it('crea la cuenta con el PIN cifrado y entra de una vez', async () => {
    await expect(registrarse.ejecutar(datos)).resolves.toMatchObject({
      usuario: { id: 'u-nuevo' },
    });
    expect(registro.registros).toEqual([
      expect.objectContaining({
        nombres: 'Luz Marina',
        celular: '+573157778888',
        hashPin: 'hash:190573',
        politicaVersionId: 'pol-1',
      }),
    ]);
    expect(entradas).toEqual([{ usuarioId: 'u-nuevo', dispositivo: datos.dispositivo }]);
    await expect(registrarse.tiposDeDocumento()).resolves.toHaveLength(1);
  });

  it('valida celular, PIN y versión de la política antes de crear nada', async () => {
    await expect(registrarse.ejecutar({ ...datos, celular: '12' })).rejects.toThrow('celular');
    await expect(registrarse.ejecutar({ ...datos, pin: '123456' })).rejects.toThrow('fácil');
    await expect(registrarse.ejecutar({ ...datos, politicaVersionId: 'x' })).rejects.toMatchObject({
      codigo: 'POLITICA_DESACTUALIZADA',
    });
    expect(registro.registros).toHaveLength(0);
  });

  it.each([
    ['celular', 'ACTIVA', 'YA_TIENE_CUENTA'],
    ['celular', 'PENDIENTE', 'YA_TE_ANOTARON'],
    ['documento', 'ACTIVA', 'YA_TIENE_CUENTA'],
    ['documento', 'PENDIENTE', 'YA_TE_ANOTARON'],
    ['documento', 'SIN_CUENTA', 'DOCUMENTO_SIN_CUENTA'],
  ] as const)('no duplica: %s con cuenta %s → %s', async (dato, cuenta, codigo) => {
    if (dato === 'celular') registro.celulares.set('+573157778888', cuenta as 'ACTIVA');
    else registro.documentos.set('CC:1124005678', cuenta);
    await expect(registrarse.ejecutar(datos)).rejects.toMatchObject({ codigo });
    expect(registro.registros).toHaveLength(0);
  });

  it('la política vigente se consulta para leerla antes de aceptar', async () => {
    await expect(new ConsultarPolitica(new ClientesEnMemoria()).ejecutar()).resolves.toMatchObject({
      id: 'pol-1',
      version: '1.0',
    });
  });
});

describe('Mi QR (HU-04-02)', () => {
  let repo: MiQrEnMemoria;
  let db: ClientesEnMemoria;
  let miQr: MiQr;

  beforeEach(() => {
    repo = new MiQrEnMemoria();
    db = new ClientesEnMemoria();
    miQr = new MiQr(repo, db.tokens, db.bitacora);
  });

  it('se emite la primera vez y después siempre es el mismo token, solo con una firma', async () => {
    const primero = await miQr.consultar('u1');
    expect(primero.version).toBe(1);
    expect(await miQr.consultar('u1')).toEqual(primero);
    const leido = leerTokenQr(primero.token);
    expect(leido).toMatchObject({ tipo: 'PERSONAL', carga: { k: 'p1', v: 1 } });
    expect(Object.keys(leido.tipo === 'PERSONAL' ? leido.carga : {})).toEqual(['k', 'q', 'v']);
  });

  it('regenerar revoca el anterior, sube la versión y queda en auditoría', async () => {
    const primero = await miQr.consultar('u1');
    const nuevo = await miQr.regenerar('u1');
    expect(nuevo.version).toBe(2);
    expect(nuevo.token).not.toBe(primero.token);
    expect(db.auditoria).toEqual([
      expect.objectContaining({ accion: 'QR_REVOKED', actorUsuarioId: 'u1', comercioId: null }),
    ]);
  });

  it('en cada negocio el cliente tiene el QR que ese negocio firmó, y si le falta se emite', async () => {
    const base = { nombre: 'La Vecina', tipoNegocio: 'RESTAURANT', afiliadoEn: new Date() };
    repo.comerciosDelCliente = [
      {
        ...base,
        comercioId: uuid(1),
        clienteId: uuid(2),
        qr: { qrId: uuid(3), version: 1, keyId: 'k1' },
      },
      { ...base, comercioId: uuid(4), clienteId: uuid(5), qr: null },
    ];
    const [conQr, sinQr] = await miQr.comercios('u1');
    expect(leerTokenQr(conQr.qr?.token ?? '')).toMatchObject({
      tipo: 'AFILIACION',
      carga: { t: uuid(1), a: uuid(2), q: uuid(3), v: 1, k: 'k1' },
    });
    expect(leerTokenQr(sinQr.qr?.token ?? '')).toMatchObject({
      tipo: 'AFILIACION',
      carga: { t: uuid(4), a: uuid(5), q: uuid(6), v: 1, k: 'k1' },
    });
    expect(conQr).not.toHaveProperty('clienteId');
  });
});
