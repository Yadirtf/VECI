import { celularAleatorio, dispositivo, entrarConPin } from '../soporte/acceso';
import { NegociosConClientes, documento, finalDe } from '../soporte/clientes';

// EP-04: registro asistido en caja, PIN de bienvenida y búsqueda.
describe('Registro asistido y búsqueda de clientes (EP-04)', () => {
  const n = new NegociosConClientes();

  beforeAll(() => n.preparar());
  afterAll(() => n.cerrar());

  it('registro asistido: PIN de bienvenida que pide crear el propio (HU-04-04)', async () => {
    const celular = celularAleatorio();
    const numero = documento();
    const revision = await n
      .http()
      .post('/clientes/registro-asistido/revisar')
      .set(n.cajera)
      .send({ tipoDocumento: 'CC', numeroDocumento: numero })
      .expect(200);
    expect(revision.body).toEqual({ persona: null });
    const alta = await n
      .registroAsistido({
        numeroDocumento: numero,
        nombres: 'Jesús',
        apellidos: 'Jacanamejoy',
        celular,
      })
      .expect(201);
    expect(alta.body).toMatchObject({ vinculado: false, cliente: { cuenta: 'PENDIENTE' } });
    expect(alta.body.pinBienvenida).toMatch(/^\d{6}$/);

    const d = dispositivo();
    const ingreso = await entrarConPin(n.servidor(), celular, alta.body.pinBienvenida, d).expect(
      200,
    );
    expect(ingreso.body.requiereCambioDePin).toBe(true);
    const sesion = await n
      .http()
      .post('/sesion/pin-nuevo')
      .send({ tokenCambio: ingreso.body.tokenCambio, pinNuevo: '582039', dispositivo: d })
      .expect(200);
    expect(sesion.body.espacios).toContainEqual(
      expect.objectContaining({ comercioId: n.a.comercioId }),
    );
    const ficha = await n
      .http()
      .get(`/clientes/${alta.body.cliente.clienteId}`)
      .set(n.cajera)
      .expect(200);
    expect(ficha.body).toMatchObject({ cuenta: 'ACTIVA', datosCompletos: false });
    const pin = await n
      .http()
      .post(`/clientes/${alta.body.cliente.clienteId}/pin-bienvenida`)
      .set(n.cajera)
      .expect(409);
    expect(pin.body.codigo).toBe('YA_ACTIVO_SU_APP');
  });

  it('registro asistido de alguien que ya está en VECI: solo lo vincula', async () => {
    const vecina = await n.registrarse('Carmen', 'Mutumbajoy');
    const revision = await n
      .http()
      .post('/clientes/registro-asistido/revisar')
      .set(n.cajera)
      .send({ tipoDocumento: 'CC', numeroDocumento: vecina.numeroDocumento })
      .expect(200);
    expect(revision.body.persona).toMatchObject({ nombre: 'Carmen M.', clienteId: null });
    const alta = await n.registroAsistido({ numeroDocumento: vecina.numeroDocumento }).expect(201);
    expect(alta.body).toMatchObject({ vinculado: true, pinBienvenida: null });
  });

  it('celular en uso: lo deja como celular compartido y sin cuenta propia', async () => {
    const vecina = await n.registrarse('Marta', 'Tisoy');
    const enUso = await n
      .registroAsistido({
        numeroDocumento: documento(),
        nombres: 'Dayana',
        celular: vecina.celular,
      })
      .expect(409);
    expect(enUso.body.codigo).toBe('CELULAR_EN_USO');
    const alta = await n
      .registroAsistido({
        numeroDocumento: documento(),
        nombres: 'Dayana',
        celular: vecina.celular,
        celularCompartido: true,
      })
      .expect(201);
    expect(alta.body).toMatchObject({ pinBienvenida: null, cliente: { cuenta: 'SIN_CUENTA' } });
    const pin = await n
      .http()
      .post(`/clientes/${alta.body.cliente.clienteId}/pin-bienvenida`)
      .set(n.cajera)
      .expect(409);
    expect(pin.body.codigo).toBe('SIN_CUENTA_PROPIA');
    const faltan = await n.registroAsistido({ numeroDocumento: documento() }).expect(422);
    expect(faltan.body.codigo).toBe('FALTAN_DATOS');
  });

  it('busca por nombre o números y la copia local responde 304 si no cambió (HU-04-05)', async () => {
    const numero = documento();
    await n
      .registroAsistido({
        numeroDocumento: numero,
        nombres: 'Ofelia',
        apellidos: 'Muchavisoy',
        celular: celularAleatorio(),
      })
      .expect(201);
    await n.http().get('/clientes?q=of').set(n.cajera).expect(422);
    const porNombre = await n.http().get('/clientes?q=ofelia').set(n.cajera).expect(200);
    expect(porNombre.body).toEqual([expect.objectContaining({ nombres: 'Ofelia' })]);
    const porNumero = await n.http().get(`/clientes?q=${numero}`).set(n.cajera).expect(200);
    expect(porNumero.body).toHaveLength(1);
    const enOtro = await n.http().get('/clientes?q=ofelia').set(n.otroNegocio).expect(200);
    expect(enOtro.body).toEqual([]);

    const copia = await n.http().get('/clientes/copia-local').set(n.cajera).expect(200);
    expect(copia.body.claves).toEqual([expect.objectContaining({ keyId: 'k1' })]);
    const ofelia = copia.body.clientes.find(
      (c: { nombreBusqueda: string }) => c.nombreBusqueda === 'ofelia muchavisoy',
    );
    expect(ofelia).toMatchObject({ documento: `****${finalDe(numero)}` });
    expect(JSON.stringify(copia.body)).not.toContain(numero);
    await n
      .http()
      .get('/clientes/copia-local')
      .set({ ...n.cajera, 'if-none-match': copia.headers.etag })
      .expect(304);
  });
});
