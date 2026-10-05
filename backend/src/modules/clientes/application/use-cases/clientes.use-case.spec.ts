import { parteFirmada, PREFIJO_AFILIACION } from '../../domain/value-objects/token-qr.vo';
import { LectorQr } from '../servicios/lector-qr';
import { AfiliarPorQr } from './afiliar-por-qr.use-case';
import { ClientesEnMemoria, uuid } from './clientes-en-memoria.fake';
import { ConsultarClientes, DarPinDeBienvenida } from './consultar-clientes.use-case';
import { LeerQrDeCliente } from './leer-qr.use-case';
import { RegistrarAsistido, RevisarDocumento } from './registro-asistido.use-case';

const COMERCIO = uuid(1);
const actor = { usuarioId: uuid(2), comercioId: COMERCIO };

describe('Clientes en la caja (EP-04)', () => {
  let db: ClientesEnMemoria;
  let leer: LeerQrDeCliente;
  let afiliar: AfiliarPorQr;

  beforeEach(() => {
    db = new ClientesEnMemoria();
    const lector = new LectorQr(db, db.tokens);
    leer = new LeerQrDeCliente(lector, db);
    afiliar = new AfiliarPorQr({ clientes: db, lector, tokens: db.tokens, auditoria: db.bitacora });
  });

  describe('escanear y afiliar (HU-04-03)', () => {
    it('el QR personal muestra nombre y documento enmascarado antes de confirmar', async () => {
      const luz = db.agregarPersona({ numeroDocumento: '1124005678' });
      const lectura = await leer.ejecutar(actor, db.qrPersonal(luz));
      expect(lectura).toEqual({
        resultado: 'PERSONA_POR_AFILIAR',
        persona: {
          personaId: luz.personaId,
          nombre: 'Luz Marina C.',
          documento: '****5678',
          clienteId: null,
        },
      });
    });

    it('afilia una vez y la segunda abre su ficha sin duplicar', async () => {
      const luz = db.agregarPersona();
      const token = db.qrPersonal(luz);
      const primera = await afiliar.ejecutar(actor, token);
      expect(primera.yaEstaba).toBe(false);
      expect(primera.cliente).toMatchObject({
        personaId: luz.personaId,
        canal: 'PERSONAL_QR_SCAN',
      });
      expect(db.qrAfiliacion).toHaveLength(1);
      expect(db.auditoria).toEqual([
        expect.objectContaining({ accion: 'CUSTOMER_AFFILIATED', comercioId: COMERCIO }),
      ]);
      const segunda = await afiliar.ejecutar(actor, token);
      expect(segunda).toMatchObject({
        yaEstaba: true,
        cliente: { clienteId: primera.cliente.clienteId },
      });
      expect(db.afiliaciones).toHaveLength(1);
      expect(db.auditoria).toHaveLength(1);
      await expect(leer.ejecutar(actor, token)).resolves.toMatchObject({ resultado: 'CLIENTE' });
    });

    it('un QR regenerado ya no sirve y no muestra el nombre', async () => {
      const luz = db.agregarPersona();
      const viejo = db.qrPersonal(luz, 1);
      db.qrPersonal(luz, 2);
      await expect(leer.ejecutar(actor, viejo)).resolves.toEqual({ resultado: 'QR_CAMBIADO' });
      await expect(afiliar.ejecutar(actor, viejo)).rejects.toThrow('fue cambiado');
    });

    it('lo que no es de VECI o está alterado no se afilia', async () => {
      const luz = db.agregarPersona();
      const [prefijo, cuerpo] = db.qrPersonal(luz).split('.');
      const alterado = `${prefijo}.${cuerpo}.${Buffer.from('otra').toString('base64url')}`;
      for (const texto of ['https://banco.co/pago', alterado, `VP1.${cuerpo}.`]) {
        await expect(leer.ejecutar(actor, texto)).resolves.toEqual({ resultado: 'NO_ES_DE_VECI' });
      }
      await expect(afiliar.ejecutar(actor, 'hola')).rejects.toMatchObject({
        codigo: 'QR_NO_SIRVE',
      });
      const sinRegistro = db.tokens.personal({
        qrId: uuid(999),
        version: 1,
        emitidoEn: new Date(),
      });
      await expect(leer.ejecutar(actor, sinRegistro)).resolves.toEqual({
        resultado: 'NO_ES_DE_VECI',
      });
    });

    it('el QR de cliente de este negocio abre su ficha; el de otro negocio no', async () => {
      const luz = db.agregarPersona();
      const { cliente } = await afiliar.ejecutar(actor, db.qrPersonal(luz));
      const qr = db.qrAfiliacion[0];
      const propio = db.tokens.afiliacion(COMERCIO, cliente.clienteId, { ...qr, keyId: 'k1' });
      await expect(leer.ejecutar(actor, propio)).resolves.toMatchObject({
        resultado: 'CLIENTE',
        cliente: { clienteId: cliente.clienteId },
      });
      const otro = db.tokens.afiliacion(uuid(77), cliente.clienteId, { ...qr, keyId: 'k1' });
      await expect(leer.ejecutar(actor, otro)).resolves.toEqual({ resultado: 'OTRO_NEGOCIO' });
      await expect(afiliar.ejecutar(actor, otro)).rejects.toThrow('otro negocio');
      await expect(afiliar.ejecutar(actor, propio)).resolves.toMatchObject({ yaEstaba: true });
    });

    it('un QR de cliente revocado, ajeno o con firma de otro comercio no abre nada', async () => {
      const luz = db.agregarPersona();
      const { cliente } = await afiliar.ejecutar(actor, db.qrPersonal(luz));
      const qr = { ...db.qrAfiliacion[0], keyId: 'k1' };
      const token = db.tokens.afiliacion(COMERCIO, cliente.clienteId, qr);
      db.qrAfiliacion[0].vigente = false;
      await expect(leer.ejecutar(actor, token)).resolves.toEqual({ resultado: 'QR_CAMBIADO' });
      const deOtroCliente = db.tokens.afiliacion(COMERCIO, uuid(55), qr);
      await expect(leer.ejecutar(actor, deOtroCliente)).resolves.toEqual({
        resultado: 'NO_ES_DE_VECI',
      });
      const parte = parteFirmada(PREFIJO_AFILIACION, {
        k: 'k1',
        t: COMERCIO,
        a: cliente.clienteId,
        q: qr.qrId,
        v: 1,
      });
      const firmaAjena = db.tokens.afiliacion(uuid(77), cliente.clienteId, qr).split('.')[2];
      await expect(leer.ejecutar(actor, `${parte}.${firmaAjena}`)).resolves.toEqual({
        resultado: 'NO_ES_DE_VECI',
      });
    });
  });

  describe('registro asistido (HU-04-04)', () => {
    let registrar: RegistrarAsistido;
    const base = {
      tipoDocumento: 'CC',
      numeroDocumento: '1124009999',
      nombres: ' Rosa ',
      apellidos: '',
      celular: '320 111 2233',
      celularCompartido: false,
      politicaVersionId: 'pol-1',
    };

    beforeEach(() => {
      registrar = new RegistrarAsistido({
        clientes: db,
        politicas: db,
        tokens: db.tokens,
        pinTemporal: db.pinTemporal,
        auditoria: db.bitacora,
      });
    });

    it('persona nueva: queda pendiente, con consentimiento y PIN de bienvenida', async () => {
      const salida = await registrar.ejecutar(actor, base);
      expect(salida).toMatchObject({ vinculado: false, pinBienvenida: '730284' });
      expect(salida.cliente).toMatchObject({
        nombres: 'Rosa',
        apellidos: null,
        celular: '+573201112233',
        cuenta: 'PENDIENTE',
        canal: 'ASSISTED_REGISTRATION',
      });
      expect(db.consentimientos).toEqual([
        { personaId: salida.cliente.personaId, politicaVersionId: 'pol-1' },
      ]);
      expect(db.pines).toEqual([
        expect.objectContaining({ motivo: 'INVITACION', comercioId: COMERCIO }),
      ]);
    });

    it('si el documento ya está en VECI se vincula sin duplicar ni dar PIN', async () => {
      const luz = db.agregarPersona({ numeroDocumento: base.numeroDocumento });
      const revision = await new RevisarDocumento(db).ejecutar('CC', base.numeroDocumento);
      expect(revision.persona).toMatchObject({ nombre: 'Luz Marina C.', documento: '****9999' });
      const salida = await registrar.ejecutar(actor, { ...base, nombres: null, celular: null });
      expect(salida).toMatchObject({ vinculado: true, pinBienvenida: null });
      expect(salida.cliente.personaId).toBe(luz.personaId);
      expect(db.personas).toHaveLength(1);
      await expect(new RevisarDocumento(db).ejecutar('CC', '999')).resolves.toEqual({
        persona: null,
      });
    });

    it('un celular que es la entrada de otra cuenta pide confirmar que es compartido', async () => {
      db.agregarPersona({ celular: '+573201112233' });
      await expect(registrar.ejecutar(actor, base)).rejects.toMatchObject({
        codigo: 'CELULAR_EN_USO',
      });
      const salida = await registrar.ejecutar(actor, { ...base, celularCompartido: true });
      expect(salida).toMatchObject({ pinBienvenida: null, cliente: { cuenta: 'SIN_CUENTA' } });
    });

    it('sin nombre o celular no registra; con otra versión de la política tampoco', async () => {
      await expect(registrar.ejecutar(actor, { ...base, celular: null })).rejects.toMatchObject({
        codigo: 'FALTAN_DATOS',
      });
      await expect(registrar.ejecutar(actor, { ...base, nombres: '  ' })).rejects.toMatchObject({
        codigo: 'FALTAN_DATOS',
      });
      await expect(
        registrar.ejecutar(actor, { ...base, politicaVersionId: 'vieja' }),
      ).rejects.toMatchObject({ codigo: 'POLITICA_DESACTUALIZADA' });
      expect(db.afiliaciones).toHaveLength(0);
    });

    it('PIN de bienvenida nuevo solo para quien no ha activado su app', async () => {
      const pin = new DarPinDeBienvenida(db, db.pinTemporal);
      const nueva = await registrar.ejecutar(actor, base);
      await expect(pin.ejecutar(actor, nueva.cliente.clienteId)).resolves.toEqual({
        pinBienvenida: '730284',
      });
      const activa = await afiliar.ejecutar(actor, db.qrPersonal(db.agregarPersona()));
      await expect(pin.ejecutar(actor, activa.cliente.clienteId)).rejects.toMatchObject({
        codigo: 'YA_ACTIVO_SU_APP',
      });
      db.agregarPersona({ celular: '+573209998877' });
      const compartido = await registrar.ejecutar(actor, {
        ...base,
        numeroDocumento: '1124001111',
        celular: '3209998877',
        celularCompartido: true,
      });
      await expect(pin.ejecutar(actor, compartido.cliente.clienteId)).rejects.toMatchObject({
        codigo: 'SIN_CUENTA_PROPIA',
      });
      await expect(pin.ejecutar(actor, uuid(404))).rejects.toMatchObject({
        codigo: 'CLIENTE_NO_ENCONTRADO',
      });
    });
  });

  describe('buscar (HU-04-05)', () => {
    it('por nombre sin tildes, por dígitos del documento o del celular', async () => {
      const consultar = new ConsultarClientes(db);
      const jose = db.agregarPersona({
        nombres: 'José',
        apellidos: 'Ñúñez',
        numeroDocumento: '987654321',
      });
      await afiliar.ejecutar(actor, db.qrPersonal(jose));
      await expect(consultar.buscar('jose nunez')).resolves.toHaveLength(1);
      await expect(consultar.buscar('654 321')).resolves.toHaveLength(1);
      await expect(consultar.buscar('maria')).resolves.toHaveLength(0);
      await expect(consultar.buscar('jo')).rejects.toMatchObject({ codigo: 'DATO_INVALIDO' });
      const [encontrado] = await consultar.buscar('Ñúñ');
      await expect(consultar.ficha(encontrado.clienteId)).resolves.toMatchObject({
        nombres: 'José',
      });
      await expect(consultar.ficha(uuid(404))).rejects.toMatchObject({
        codigo: 'CLIENTE_NO_ENCONTRADO',
      });
      await expect(consultar.versionDeCopia()).resolves.toBe('1');
      await expect(consultar.copiaLocal()).resolves.toMatchObject({
        clientes: [{ nombres: 'José' }],
      });
    });
  });
});
