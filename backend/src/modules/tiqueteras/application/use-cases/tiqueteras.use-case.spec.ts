import { ConsultarMisTiqueteras, ConsultarSaldoDelCliente } from './consultar-saldos.use-case';
import { CorregirSaldos } from './corregir.use-case';
import { ConsultarCatalogoDeVenta, GestionarTipos } from './tipos.use-case';
import { TiqueterasEnMemoria, uuid } from './tiqueteras-en-memoria.fake';
import { VencerTiqueteras } from './vencer.use-case';
import { VenderTiquetera } from './vender.use-case';
import { VentaInput } from '../dto/tiqueteras.dto';

const COMERCIO = uuid(1);
const CLIENTE = uuid(2);
const actor = { usuarioId: uuid(3), comercioId: COMERCIO, dispositivoId: uuid(4) };
// prettier-ignore
const DATOS = { nombre: '20 almuerzos', unidad: 'LUNCH', unidades: 20, precio: 220000, vigenciaDias: 30 };

describe('Tiqueteras y ventas (EP-05)', () => {
  let db: TiqueterasEnMemoria;
  let ahora: Date;
  let n: number;
  let tipos: GestionarTipos;
  let vender: VenderTiquetera;
  let corregir: CorregirSaldos;
  const reloj = { ahora: () => ahora };
  const ids = { siguiente: () => uuid(100 + ++n) };

  beforeEach(() => {
    db = new TiqueterasEnMemoria();
    db.clientes.set(CLIENTE, 'ACTIVE');
    ahora = new Date('2026-10-08T17:00:00Z');
    n = 0;
    tipos = new GestionarTipos(db, ids);
    vender = new VenderTiquetera({ tipos: db, ventas: db, saldos: db, ids, reloj });
    corregir = new CorregirSaldos({ ventas: db, saldos: db, ids, reloj });
  });

  const venta = (tipoId: string, cambios: Partial<VentaInput> = {}): VentaInput => ({
    ventaId: uuid(900 + ++n),
    clienteId: CLIENTE,
    tipoId,
    precio: 220000,
    pago: { medio: 'BANK_TRANSFER', canal: 'NEQUI', referencia: 'M1' },
    ocurridaEn: null,
    sinConexion: false,
    ...cambios,
  });

  describe('la pizarra (HU-05-01)', () => {
    it('crea un tipo con su precio por unidad y no repite nombres', async () => {
      const tipo = await tipos.crear(actor, DATOS);
      expect(tipo).toMatchObject({
        nombre: '20 almuerzos',
        precioPorUnidad: 11000,
        estado: 'ACTIVE',
      });
      await expect(tipos.crear(actor, DATOS)).rejects.toMatchObject({ codigo: 'NOMBRE_REPETIDO' });
      await expect(
        tipos.crear(actor, { ...DATOS, nombre: 'Otro', unidad: 'TACO' }),
      ).rejects.toThrow('unidad');
    });

    it('desactivar un tipo lo saca del catálogo de la caja sin tocar lo vendido', async () => {
      const tipo = await tipos.crear(actor, DATOS);
      await vender.ejecutar(actor, venta(tipo.tipoId));
      const guardado = await tipos.cambiarEstado(tipo.tipoId, false);
      expect(guardado.estado).toBe('INACTIVE');
      const catalogo = await new ConsultarCatalogoDeVenta(db, db).catalogo();
      expect(catalogo.tipos).toEqual([]);
      expect(catalogo.medios.map((m) => m.codigo)).toEqual(['CASH', 'BANK_TRANSFER']);
      expect([...db.tiqueteras.values()][0]).toMatchObject({ estado: 'ACTIVE', saldo: 20 });
      await expect(tipos.cambiarEstado(tipo.tipoId, true)).resolves.toMatchObject({
        estado: 'ACTIVE',
      });
    });

    it('con ventas, cambia precio y vigencia pero no la cantidad', async () => {
      const tipo = await tipos.crear(actor, DATOS);
      const editado = await tipos.editar(tipo.tipoId, {
        ...DATOS,
        precio: 230000,
        vigenciaDias: 45,
      });
      expect(editado).toMatchObject({ precio: 230000, vigenciaDias: 45 });
      await vender.ejecutar(actor, venta(tipo.tipoId, { precio: 230000 }));
      await expect(tipos.editar(tipo.tipoId, { ...DATOS, unidades: 25 })).rejects.toMatchObject({
        codigo: 'CANTIDAD_YA_VENDIDA',
      });
      await expect(tipos.editar(uuid(77), DATOS)).rejects.toMatchObject({
        codigo: 'TIPO_NO_ENCONTRADO',
      });
      expect(await tipos.listar()).toHaveLength(1);
      expect(await tipos.unidades()).toHaveLength(2);
    });
  });

  describe('vender (HU-05-02)', () => {
    it('carga el saldo de inmediato y vence en la fecha del negocio', async () => {
      const tipo = await tipos.crear(actor, DATOS);
      const hecha = await vender.ejecutar(actor, venta(tipo.tipoId));
      expect(hecha).toMatchObject({
        repetida: false,
        origen: 'ONLINE',
        tiquetera: { saldo: 20, ultimoDia: '2026-11-06', turno: 1, vigente: true },
        saldos: [{ disponibles: 20, unidad: { plural: 'almuerzos' } }],
      });
      expect(db.bitacora).toEqual(['SALE_CREATED']);
    });

    it('la misma venta enviada dos veces queda una sola vez; con otros datos se rechaza', async () => {
      const tipo = await tipos.crear(actor, DATOS);
      const pedido = venta(tipo.tipoId);
      await vender.ejecutar(actor, pedido);
      await expect(vender.ejecutar(actor, pedido)).resolves.toMatchObject({ repetida: true });
      expect(db.tiqueteras.size).toBe(1);
      await expect(
        vender.ejecutar(actor, {
          ...pedido,
          pago: { medio: 'CASH', canal: null, referencia: null },
        }),
      ).rejects.toMatchObject({ codigo: 'VENTA_DISTINTA' });
    });

    it('si otra petición gana la carrera con el mismo id, responde la registrada', async () => {
      const tipo = await tipos.crear(actor, DATOS);
      const primera = await vender.ejecutar(actor, venta(tipo.tipoId));
      const pedido = venta(tipo.tipoId);
      db.carrera = { ...db.ventas.get(primera.ventaId)!, ventaId: pedido.ventaId };
      await expect(vender.ejecutar(actor, pedido)).resolves.toMatchObject({ repetida: true });
      db.carrera = { ...db.ventas.get(primera.ventaId)!, ventaId: uuid(999) };
      const ajena = vender.ejecutar(actor, venta(tipo.tipoId));
      await expect(ajena).rejects.toMatchObject({ codigo: 'VENTA_DISTINTA' });
    });

    it('en línea manda la pizarra: tipo activo y precio vigente', async () => {
      const tipo = await tipos.crear(actor, DATOS);
      await expect(vender.ejecutar(actor, venta(tipo.tipoId, { precio: 200000 }))).rejects.toThrow(
        'cambió a $220.000',
      );
      await tipos.cambiarEstado(tipo.tipoId, false);
      await expect(vender.ejecutar(actor, venta(tipo.tipoId))).rejects.toMatchObject({
        codigo: 'TIPO_NO_SE_VENDE',
      });
      await expect(vender.ejecutar(actor, venta(uuid(55)))).rejects.toMatchObject({
        codigo: 'TIPO_NO_ENCONTRADO',
      });
    });

    it('sin conexión la venta ya ocurrió: guarda su hora, su precio y su vencimiento', async () => {
      const tipo = await tipos.crear(actor, DATOS);
      await tipos.cambiarEstado(tipo.tipoId, false);
      db.clientes.set(CLIENTE, 'BLOCKED');
      const ocurridaEn = new Date('2026-10-06T23:00:00Z');
      const hecha = await vender.ejecutar(
        actor,
        venta(tipo.tipoId, { sinConexion: true, ocurridaEn, precio: 210000 }),
      );
      expect(hecha).toMatchObject({
        origen: 'OFFLINE_SYNC',
        tiquetera: { ultimoDia: '2026-11-04' },
      });
      expect(hecha.tiquetera.compradaEn).toEqual(ocurridaEn);
      expect(hecha.tiquetera.precio).toBe(210000);
    });

    it('rechaza horas imposibles, precios raros, clientes ajenos o bloqueados y pagos sin canal', async () => {
      const tipo = await tipos.crear(actor, DATOS);
      const offline = { sinConexion: true };
      const futuro = new Date('2026-10-08T17:10:00Z');
      const viejo = new Date('2026-08-01T17:00:00Z');
      await expect(
        vender.ejecutar(actor, venta(tipo.tipoId, { ...offline, ocurridaEn: futuro })),
      ).rejects.toThrow('futuro');
      await expect(
        vender.ejecutar(actor, venta(tipo.tipoId, { ...offline, ocurridaEn: viejo })),
      ).rejects.toThrow('más de un mes');
      await expect(
        vender.ejecutar(actor, venta(tipo.tipoId, { ...offline, precio: 10.5 })),
      ).rejects.toThrow('precio');
      await expect(
        vender.ejecutar(actor, venta(tipo.tipoId, { clienteId: uuid(66) })),
      ).rejects.toMatchObject({ codigo: 'CLIENTE_NO_ENCONTRADO' });
      await expect(
        vender.ejecutar(
          actor,
          venta(tipo.tipoId, { pago: { medio: 'BANK_TRANSFER', canal: null, referencia: null } }),
        ),
      ).rejects.toMatchObject({ codigo: 'PAGO_INVALIDO' });
      db.clientes.set(CLIENTE, 'BLOCKED');
      await expect(vender.ejecutar(actor, venta(tipo.tipoId))).rejects.toMatchObject({
        codigo: 'CLIENTE_NO_PUEDE_COMPRAR',
      });
    });
  });

  describe('varias tiqueteras activas (HU-05-03)', () => {
    it('el saldo suma las vigentes y la que vence antes tiene el primer turno', async () => {
      const corta = await tipos.crear(actor, {
        ...DATOS,
        nombre: '5 almuerzos',
        unidades: 5,
        precio: 60000,
        vigenciaDias: 7,
      });
      const larga = await tipos.crear(actor, DATOS);
      await vender.ejecutar(actor, venta(larga.tipoId));
      const hecha = await vender.ejecutar(actor, venta(corta.tipoId, { precio: 60000 }));
      expect(hecha.saldos).toEqual([
        expect.objectContaining({ disponibles: 25, tiqueteras: 2, ultimoDia: '2026-10-14' }),
      ]);
      expect(hecha.tiqueteras.map((t) => [t.nombre, t.turno])).toEqual([
        ['5 almuerzos', 1],
        ['20 almuerzos', 2],
      ]);
      const ficha = await new ConsultarSaldoDelCliente(db, reloj).ejecutar(CLIENTE);
      expect(ficha.saldos[0].disponibles).toBe(25);
      await expect(
        new ConsultarSaldoDelCliente(db, reloj).ejecutar(uuid(66)),
      ).rejects.toMatchObject({
        codigo: 'CLIENTE_NO_ENCONTRADO',
      });
      const mias = await new ConsultarMisTiqueteras(db, reloj).ejecutar(actor.usuarioId);
      expect(mias[0]).toMatchObject({
        comercio: 'Restaurante La Vecina',
        saldos: [{ disponibles: 25 }],
      });
    });
  });

  describe('vencimiento automático (HU-05-04)', () => {
    it('vence lo que pasó su fecha, sigue si un comercio falla y no vence dos veces', async () => {
      const tipo = await tipos.crear(actor, { ...DATOS, vigenciaDias: 1 });
      const hecha = await vender.ejecutar(actor, venta(tipo.tipoId));
      db.porComercio.set(COMERCIO, [hecha.tiquetera.tiqueteraId]);
      db.porComercio.set('roto', [hecha.tiquetera.tiqueteraId]);
      const errores: unknown[] = [];
      const vencer = new VencerTiqueteras(db, reloj, {
        etiquetarComercio: () => undefined,
        capturarError: (e) => errores.push(e),
      });
      const nada = { comercios: 0, tiqueteras: 0, fallidos: 0 };
      await expect(vencer.ejecutar()).resolves.toEqual(nada);
      ahora = new Date('2026-10-09T05:00:00Z');
      const una = { comercios: 2, tiqueteras: 1, fallidos: 1 };
      await expect(vencer.ejecutar()).resolves.toEqual(una);
      expect(errores).toHaveLength(1);
      expect(db.tiqueteras.get(hecha.tiquetera.tiqueteraId)).toMatchObject({ estado: 'EXPIRED' });
      await expect(vencer.ejecutar()).resolves.toMatchObject({ tiqueteras: 0 });
    });
  });

  describe('anular y ajustar (HU-05-05)', () => {
    it('anular deja la venta y la tiquetera anuladas, con motivo y en la bitácora', async () => {
      const tipo = await tipos.crear(actor, DATOS);
      const hecha = await vender.ejecutar(actor, venta(tipo.tipoId));
      expect(await corregir.ventasRecientes()).toHaveLength(1);
      await expect(
        corregir.anular(actor, hecha.ventaId, { motivo: '', nota: null }),
      ).rejects.toMatchObject({
        codigo: 'MOTIVO_OBLIGATORIO',
      });
      const cuenta = await corregir.anular(actor, hecha.ventaId, {
        motivo: 'DATA_ENTRY_ERROR',
        nota: null,
      });
      expect(cuenta.saldos).toEqual([]);
      expect(cuenta.tiqueteras[0]).toMatchObject({ estado: 'VOIDED', vigente: false, turno: null });
      expect(cuenta.movimientos[0]).toMatchObject({ tipo: 'SALE_VOID', unidades: -20 });
      expect(db.bitacora).toEqual(['SALE_CREATED', 'SALE_VOIDED']);
      await expect(
        corregir.anular(actor, hecha.ventaId, { motivo: 'OTHER', nota: 'x' }),
      ).rejects.toMatchObject({
        codigo: 'VENTA_YA_ANULADA',
      });
      await expect(
        corregir.anular(actor, uuid(70), { motivo: 'OTHER', nota: 'x' }),
      ).rejects.toMatchObject({
        codigo: 'VENTA_NO_ENCONTRADA',
      });
    });

    it('ajustar suma o quita unidades con motivo, sin dejarla en negativo', async () => {
      const tipo = await tipos.crear(actor, DATOS);
      const { tiquetera } = await vender.ejecutar(actor, venta(tipo.tipoId));
      const motivo = { motivo: 'OTHER', nota: 'Se le sirvió sin escanear' };
      const menos = await corregir.ajustar(actor, tiquetera.tiqueteraId, -20, motivo);
      expect(menos.tiqueteras[0]).toMatchObject({ saldo: 0, estado: 'DEPLETED' });
      const mas = await corregir.ajustar(actor, tiquetera.tiqueteraId, 2, motivo);
      expect(mas.saldos[0].disponibles).toBe(2);
      await expect(
        corregir.ajustar(actor, tiquetera.tiqueteraId, -3, motivo),
      ).rejects.toMatchObject({
        codigo: 'SALDO_INSUFICIENTE',
      });
      await expect(corregir.ajustar(actor, uuid(71), 1, motivo)).rejects.toMatchObject({
        codigo: 'TIQUETERA_NO_ENCONTRADA',
      });
      expect(db.bitacora.filter((b) => b === 'BALANCE_ADJUSTED')).toHaveLength(2);
      expect(await corregir.motivos()).toHaveLength(2);
    });
  });
});
