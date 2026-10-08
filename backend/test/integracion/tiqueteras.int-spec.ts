import { randomUUID } from 'node:crypto';
import { ProgramadorDeVencimiento } from '../../src/modules/tiqueteras';
import { NegociosConTiqueteras, PIZARRA } from '../soporte/tiqueteras';

// EP-05: la pizarra, vender (también sin conexión), saldo, correcciones y vencimiento.
describe('Tiqueteras y ventas (EP-05)', () => {
  const n = new NegociosConTiqueteras();

  beforeAll(() => n.preparar());
  afterAll(() => n.cerrar());

  it('la propietaria arma la pizarra; la cajera no la cambia (HU-05-01)', async () => {
    const unidades = await n.http().get('/tiqueteras/unidades').set(n.propietaria).expect(200);
    expect(unidades.body).toContainEqual({
      codigo: 'LUNCH',
      singular: 'almuerzo',
      plural: 'almuerzos',
    });
    const tipo = await n.crearTipo();
    expect(tipo).toMatchObject({ precioPorUnidad: 11000, estado: 'ACTIVE', vendidas: 0 });
    const repetido = await n
      .http()
      .post('/tiqueteras/tipos')
      .set(n.propietaria)
      .send({ ...PIZARRA, nombre: (tipo as unknown as { nombre: string }).nombre })
      .expect(409);
    expect(repetido.body.codigo).toBe('NOMBRE_REPETIDO');
    await n.http().post('/tiqueteras/tipos').set(n.cajera).send(PIZARRA).expect(403);
    const malo = await n
      .http()
      .post('/tiqueteras/tipos')
      .set(n.propietaria)
      .send({ ...PIZARRA, nombre: 'Barata', precio: 10 })
      .expect(422);
    expect(malo.body.codigo).toBe('DATO_INVALIDO');
    const lista = await n.http().get('/tiqueteras/tipos').set(n.propietaria).expect(200);
    expect(lista.body.map((t: { tipoId: string }) => t.tipoId)).toContain(tipo.tipoId);
    const otro = await n.http().get('/tiqueteras/tipos').set(n.otroNegocio).expect(200);
    expect(otro.body.map((t: { tipoId: string }) => t.tipoId)).not.toContain(tipo.tipoId);
  });

  it('la caja baja el catálogo con ETag; desactivar un tipo lo saca (HU-05-02)', async () => {
    const tipo = await n.crearTipo({ unidad: 'BREAKFAST', precio: 90000, unidades: 10 });
    const primero = await n.http().get('/ventas/catalogo').set(n.cajera).expect(200);
    expect(primero.body.tipos.map((t: { tipoId: string }) => t.tipoId)).toContain(tipo.tipoId);
    expect(primero.body.medios).toContainEqual(
      expect.objectContaining({ codigo: 'BANK_TRANSFER', necesitaCanal: true }),
    );
    const etag = primero.headers.etag;
    await n.http().get('/ventas/catalogo').set(n.cajera).set('if-none-match', etag).expect(304);
    await n
      .http()
      .patch(`/tiqueteras/tipos/${tipo.tipoId}/estado`)
      .set(n.propietaria)
      .send({ activo: false })
      .expect(200);
    const despues = await n.http().get('/ventas/catalogo').set(n.cajera).set('if-none-match', etag);
    expect(despues.status).toBe(200);
    expect(despues.body.tipos.map((t: { tipoId: string }) => t.tipoId)).not.toContain(tipo.tipoId);
    const venta = await n.vender({
      clienteId: n.a.afiliacionId,
      tipoId: tipo.tipoId,
      precio: 90000,
    });
    expect(venta.status).toBe(422);
    expect(venta.body.codigo).toBe('TIPO_NO_SE_VENDE');
  });

  it('vende, carga el saldo al instante y reenviarla no la duplica (HU-05-02)', async () => {
    const tipo = await n.crearTipo();
    const { clienteId, sesion } = await n.clienteAfiliado();
    const ventaId = randomUUID();
    const pago = { medio: 'BANK_TRANSFER', canal: 'NEQUI', referencia: 'M8812' };
    const venta = await n.vender({ ventaId, clienteId, tipoId: tipo.tipoId, pago }).expect(200);
    expect(venta.body).toMatchObject({
      ventaId,
      repetida: false,
      origen: 'ONLINE',
      tiquetera: { saldo: 20, estado: 'ACTIVE', vigente: true, turno: 1, precio: 220000 },
      saldos: [{ unidad: { codigo: 'LUNCH' }, disponibles: 20, tiqueteras: 1 }],
    });
    const otraVez = await n.vender({ ventaId, clienteId, tipoId: tipo.tipoId, pago }).expect(200);
    expect(otraVez.body).toMatchObject({ repetida: true, saldos: [{ disponibles: 20 }] });
    const distinta = await n.vender({ ventaId, clienteId, tipoId: tipo.tipoId }).expect(409);
    expect(distinta.body.codigo).toBe('VENTA_DISTINTA');
    const precio = await n.vender({ clienteId, tipoId: tipo.tipoId, precio: 200000 }).expect(409);
    expect(precio.body.codigo).toBe('PRECIO_CAMBIO');
    const sinCanal = await n
      .vender({ clienteId, tipoId: tipo.tipoId, pago: { medio: 'BANK_TRANSFER' } })
      .expect(422);
    expect(sinCanal.body.codigo).toBe('PAGO_INVALIDO');
    const mias = await n.http().get('/mis-tiqueteras').set(sesion).expect(200);
    expect(mias.body).toEqual([
      expect.objectContaining({
        comercioId: n.a.comercioId,
        saldos: [expect.objectContaining({ disponibles: 20 })],
        tiqueteras: [expect.objectContaining({ precio: null, saldo: 20 })],
      }),
    ]);
    expect(await n.auditado('SALE_CREATED')).toBeGreaterThanOrEqual(1);
  });

  it('la venta hecha sin señal llega después con su hora y su precio (ADR-0004)', async () => {
    const tipo = await n.crearTipo({ vigenciaDias: 1 });
    const { clienteId } = await n.clienteAfiliado('Rosa');
    await n
      .http()
      .patch(`/tiqueteras/tipos/${tipo.tipoId}`)
      .set(n.propietaria)
      .send({ ...PIZARRA, nombre: `${PIZARRA.nombre} nueva ${randomUUID()}`, precio: 240000 })
      .expect(200);
    const ocurridaEn = new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString();
    const venta = await n
      .vender({ clienteId, tipoId: tipo.tipoId, sinConexion: true, ocurridaEn })
      .expect(200);
    expect(venta.body).toMatchObject({ origen: 'OFFLINE_SYNC', tiquetera: { precio: 220000 } });
    expect(venta.body.tiquetera.compradaEn).toBe(ocurridaEn);
    const futura = new Date(Date.now() + 60 * 60 * 1000).toISOString();
    await n
      .vender({ clienteId, tipoId: tipo.tipoId, sinConexion: true, ocurridaEn: futura })
      .expect(422);
  });

  it('otro negocio no ve ni le vende a los clientes ajenos (RLS)', async () => {
    const { clienteId } = await n.clienteAfiliado('Marta');
    const tipoA = await n.crearTipo();
    await n.vender({ clienteId, tipoId: tipoA.tipoId }).expect(200);
    await n.saldo(clienteId, n.otroNegocio).expect(404);
    const tipoB = await n.crearTipo({}, n.otroNegocio);
    const ajena = await n.vender({ clienteId, tipoId: tipoB.tipoId }, n.otroNegocio).expect(404);
    expect(ajena.body.codigo).toBe('CLIENTE_NO_ENCONTRADO');
    await n.vender({ clienteId, tipoId: tipoA.tipoId }, n.otroNegocio).expect(404);
  });

  it('la propietaria anula con motivo y queda en la historia (HU-05-05)', async () => {
    const tipo = await n.crearTipo();
    const { clienteId } = await n.clienteAfiliado('Gloria');
    const venta = await n.vender({ clienteId, tipoId: tipo.tipoId }).expect(200);
    const { ventaId } = venta.body;
    const recientes = await n.http().get('/ventas').set(n.propietaria).expect(200);
    expect(recientes.body).toContainEqual(
      expect.objectContaining({ ventaId, cliente: expect.stringContaining('Gloria'), saldo: 20 }),
    );
    await n.http().get('/ventas').set(n.cajera).expect(403);
    const anular = (cuerpo: Record<string, unknown>) =>
      n.http().post(`/ventas/${ventaId}/anulacion`).set(n.propietaria).send(cuerpo);
    expect((await anular({ motivo: 'OTHER' }).expect(422)).body.codigo).toBe('MOTIVO_OBLIGATORIO');
    const anulada = await anular({ motivo: 'DATA_ENTRY_ERROR' }).expect(200);
    expect(anulada.body.saldos).toEqual([]);
    expect(anulada.body.tiqueteras[0]).toMatchObject({ estado: 'VOIDED', saldo: 0 });
    expect(anulada.body.movimientos.map((m: { tipo: string }) => m.tipo)).toEqual([
      'SALE_VOID',
      'SALE',
    ]);
    expect(anulada.body.movimientos[0]).toMatchObject({
      unidades: -20,
      motivo: 'Error al registrar',
    });
    expect((await anular({ motivo: 'DATA_ENTRY_ERROR' }).expect(409)).body.codigo).toBe(
      'VENTA_YA_ANULADA',
    );
    expect(await n.auditado('SALE_VOIDED')).toBe(1);
  });

  it('ajusta el saldo con motivo, sin dejarlo en negativo (HU-05-05)', async () => {
    const tipo = await n.crearTipo();
    const { clienteId } = await n.clienteAfiliado('Nidia');
    const venta = await n.vender({ clienteId, tipoId: tipo.tipoId }).expect(200);
    const tiqueteraId = venta.body.tiquetera.tiqueteraId;
    const ajustar = (cuerpo: Record<string, unknown>) =>
      n.http().post(`/tiqueteras/${tiqueteraId}/ajustes`).set(n.propietaria).send(cuerpo);
    const motivos = await n.http().get('/tiqueteras/motivos').set(n.propietaria).expect(200);
    expect(motivos.body.map((m: { codigo: string }) => m.codigo)).toContain('COURTESY');
    expect(
      (await ajustar({ unidades: -30, motivo: 'CUSTOMER_CLAIM' }).expect(422)).body.codigo,
    ).toBe('SALDO_INSUFICIENTE');
    const ajuste = await ajustar({ unidades: -2, motivo: 'OTHER', nota: 'Se anotó doble' }).expect(
      200,
    );
    expect(ajuste.body.saldos[0].disponibles).toBe(18);
    expect(ajuste.body.movimientos[0]).toMatchObject({
      tipo: 'ADJUSTMENT',
      unidades: -2,
      nota: 'Se anotó doble',
    });
    const cero = await ajustar({ unidades: -18, motivo: 'COURTESY' }).expect(200);
    expect(cero.body.tiqueteras[0]).toMatchObject({ estado: 'DEPLETED', saldo: 0 });
    const vuelve = await ajustar({ unidades: 1, motivo: 'CUSTOMER_CLAIM' }).expect(200);
    expect(vuelve.body.tiqueteras[0]).toMatchObject({ estado: 'ACTIVE', saldo: 1 });
    await n
      .http()
      .post(`/tiqueteras/${tiqueteraId}/ajustes`)
      .set(n.cajera)
      .send({ unidades: 1, motivo: 'COURTESY' })
      .expect(403);
    expect(await n.auditado('BALANCE_ADJUSTED')).toBe(3);
  });

  it('vence la tiquetera a su hora y deja el movimiento para reportes (HU-05-04)', async () => {
    const tipo = await n.crearTipo();
    const { clienteId } = await n.clienteAfiliado('Edith');
    const venta = await n.vender({ clienteId, tipoId: tipo.tipoId }).expect(200);
    const tiqueteraId = venta.body.tiquetera.tiqueteraId;
    await n.envejecer(tiqueteraId);
    const antes = await n.saldo(clienteId).expect(200);
    expect(antes.body.saldos).toEqual([]);
    expect(antes.body.tiqueteras[0]).toMatchObject({ vigente: false, estado: 'ACTIVE' });
    await n.app.get(ProgramadorDeVencimiento).correr();
    const despues = await n.saldo(clienteId).expect(200);
    expect(despues.body.tiqueteras[0]).toMatchObject({ estado: 'EXPIRED', saldo: 0 });
    // El vencimiento queda con la hora en que venció (aquí, antes de la venta envejecida).
    expect(despues.body.movimientos).toContainEqual(
      expect.objectContaining({ tipo: 'EXPIRATION', unidades: -20, quien: null }),
    );
    const ajuste = await n
      .http()
      .post(`/tiqueteras/${tiqueteraId}/ajustes`)
      .set(n.propietaria)
      .send({ unidades: 1, motivo: 'COURTESY' })
      .expect(422);
    expect(ajuste.body.codigo).toBe('TIQUETERA_NO_SE_AJUSTA');
  });
});
