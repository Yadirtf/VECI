import { dispositivo, celularAleatorio } from '../soporte/acceso';
import { NegociosConClientes, documento, finalDe } from '../soporte/clientes';

// EP-04: registro propio, Mi QR, afiliación por QR y rastro.
describe('Clientes y afiliación (EP-04)', () => {
  const n = new NegociosConClientes();

  beforeAll(() => n.preparar());
  afterAll(() => n.cerrar());

  it('publica la política en corto y los tipos de documento (HU-12-01)', async () => {
    const politica = await n.http().get('/politica-de-datos').expect(200);
    expect(politica.body).toMatchObject({ version: '1.0', huella: expect.any(String) });
    expect(politica.body.enCorto.anotamos.length).toBeGreaterThan(0);
    expect(politica.body.secciones[0]).toHaveProperty('enPalabrasDeVecino');
    const tipos = await n.http().get('/registro/tipos-documento').expect(200);
    expect(tipos.body).toContainEqual(expect.objectContaining({ codigo: 'CC' }));
  });

  it('se registra sola, tiene su QR y al regenerarlo el anterior deja de servir (HU-04-01, HU-04-02)', async () => {
    const vecina = await n.registrarse();
    const primero = await n.http().get('/mi-qr').set(vecina.sesion).expect(200);
    expect(primero.body.token).toMatch(/^VP1\./);
    const nuevo = await n.http().post('/mi-qr/regenerar').set(vecina.sesion).expect(200);
    expect(nuevo.body.version).toBe(primero.body.version + 1);
    const viejo = await n.leerQr(n.cajera, primero.body.token).expect(200);
    expect(viejo.body).toEqual({ resultado: 'QR_CAMBIADO' });
    const vigente = await n.leerQr(n.cajera, nuevo.body.token).expect(200);
    expect(vigente.body).toMatchObject({
      resultado: 'PERSONA_POR_AFILIAR',
      persona: { nombre: 'Luz Marina C.', documento: `****${finalDe(vecina.numeroDocumento)}` },
    });
  });

  it('no deja registrar dos veces el mismo celular ni con otra versión de la política', async () => {
    const vecina = await n.registrarse();
    const repetido = await n
      .http()
      .post('/registro')
      .send({
        celular: vecina.celular,
        numeroDocumento: documento(),
        nombres: 'Otra',
        tipoDocumento: 'CC',
        pin: '190573',
        politicaVersionId: n.politicaId,
        dispositivo: dispositivo(),
      })
      .expect(409);
    expect(repetido.body.codigo).toBe('YA_TIENE_CUENTA');
    const vieja = await n
      .http()
      .post('/registro')
      .send({
        celular: celularAleatorio(),
        numeroDocumento: documento(),
        nombres: 'Otra',
        tipoDocumento: 'CC',
        pin: '190573',
        politicaVersionId: '00000000-0000-4000-8000-000000000000',
        dispositivo: dispositivo(),
      })
      .expect(409);
    expect(vieja.body.codigo).toBe('POLITICA_DESACTUALIZADA');
  });

  it('la cajera afilia por QR una sola vez y el cliente ve el QR de ese negocio (HU-04-03)', async () => {
    const vecina = await n.registrarse('Rosa', 'Pantoja');
    const qr = await n.http().get('/mi-qr').set(vecina.sesion).expect(200);
    const afiliacion = await n
      .http()
      .post('/clientes/afiliaciones')
      .set(n.cajera)
      .send({ token: qr.body.token })
      .expect(200);
    expect(afiliacion.body).toMatchObject({ yaEstaba: false, cliente: { cuenta: 'ACTIVA' } });
    expect(afiliacion.body.cliente.documento).toBe(`****${finalDe(vecina.numeroDocumento)}`);
    const otraVez = await n
      .http()
      .post('/clientes/afiliaciones')
      .set(n.cajera)
      .send({ token: qr.body.token })
      .expect(200);
    expect(otraVez.body.yaEstaba).toBe(true);
    const repetida = await n.leerQr(n.cajera, qr.body.token).expect(200);
    expect(repetida.body.resultado).toBe('CLIENTE');

    const comercios = await n.http().get('/mis-comercios').set(vecina.sesion).expect(200);
    expect(comercios.body).toEqual([expect.objectContaining({ comercioId: n.a.comercioId })]);
    const deNegocio = comercios.body[0].qr.token as string;
    expect(deNegocio).toMatch(/^V1\./);
    expect((await n.leerQr(n.cajera, deNegocio).expect(200)).body.resultado).toBe('CLIENTE');
    expect((await n.leerQr(n.otroNegocio, deNegocio).expect(200)).body).toEqual({
      resultado: 'OTRO_NEGOCIO',
    });
    const alterado = `${deNegocio.slice(0, -2)}xx`;
    expect((await n.leerQr(n.cajera, alterado).expect(200)).body.resultado).toBe('NO_ES_DE_VECI');
    expect((await n.leerQr(n.cajera, 'https://otra.app/qr').expect(200)).body.resultado).toBe(
      'NO_ES_DE_VECI',
    );

    const ficha = await n
      .http()
      .get(`/clientes/${afiliacion.body.cliente.clienteId}`)
      .set(n.propietaria)
      .expect(200);
    expect(ficha.body).toMatchObject({
      documento: vecina.numeroDocumento,
      datosCompletos: true,
      canal: expect.any(String),
    });
    await n
      .http()
      .get(`/clientes/${afiliacion.body.cliente.clienteId}`)
      .set(n.otroNegocio)
      .expect(404);
  });

  it('una afiliación sin QR (semilla, importada) recibe el suyo al abrir Tus negocios', async () => {
    const vecina = await n.registrarse('Gloria', 'Jamioy');
    await n.dueno.query(
      `INSERT INTO customers.affiliations (tenant_id, person_id, affiliation_status_id,
                                           affiliation_channel_id, branch_id)
       SELECT $1, u.person_id, st.id, ch.id,
              (SELECT b.id FROM tenancy.branches b WHERE b.tenant_id = $1 AND b.is_main)
         FROM identity.users u, customers.affiliation_statuses st, customers.affiliation_channels ch
        WHERE u.id = (SELECT user_id FROM identity.user_login_identifiers WHERE value = $2)
          AND st.code = 'ACTIVE' AND ch.code = 'PERSONAL_QR_SCAN'`,
      [n.a.comercioId, `+57${vecina.celular}`],
    );
    const primera = await n.http().get('/mis-comercios').set(vecina.sesion).expect(200);
    const token = primera.body[0].qr.token as string;
    expect(token).toMatch(/^V1\./);
    const segunda = await n.http().get('/mis-comercios').set(vecina.sesion).expect(200);
    expect(segunda.body[0].qr.token).toBe(token);
    expect((await n.leerQr(n.cajera, token).expect(200)).body.resultado).toBe('CLIENTE');
  });

  it('deja rastro: consentimientos aceptados y afiliaciones auditadas', async () => {
    const consentimientos = await n.dueno.query(
      `SELECT count(*)::int AS n FROM compliance.consents WHERE policy_version_id = $1`,
      [n.politicaId],
    );
    expect(consentimientos.rows[0].n).toBeGreaterThanOrEqual(3);
    const auditoria = await n.dueno.query(
      `SELECT count(*)::int AS n FROM audit.audit_log l JOIN audit.actions x ON x.id = l.action_id
        WHERE l.tenant_id = $1 AND x.code = 'CUSTOMER_AFFILIATED'`,
      [n.a.comercioId],
    );
    expect(auditoria.rows[0].n).toBe(1);
  });
});
