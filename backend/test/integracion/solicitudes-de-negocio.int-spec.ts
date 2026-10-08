import { INestApplication } from '@nestjs/common';
import { Client } from 'pg';
import request from 'supertest';
import { conectarDueno, urlApp } from '../soporte/base-de-datos';
import { celularAleatorio } from '../soporte/acceso';
import { levantarApi } from '../soporte/aplicacion';
import { crearEquipoVeci } from '../soporte/negocios';
import { crearUsuario } from '../soporte/personas';

// Roles y seguridad: registrar un negocio es una solicitud que decide Administración VECI.
describe('Solicitudes para registrar un negocio', () => {
  let app: INestApplication;
  let dueno: Client;
  let api: Client;
  let adminId: string;
  let soporteId: string;

  const negocio = (municipioId = 86001) => ({
    nombre: 'Asadero El Vecino',
    tipoNegocio: 'RESTAURANT',
    tipoDocumento: 'CC',
    numeroDocumento: '1124500321',
    celular: celularAleatorio(),
    municipioId,
  });
  const como = (usuarioId: string) => ({ 'x-veci-usuario': usuarioId });
  const servidor = () => app.getHttpServer();
  const radicar = (usuarioId: string, datos = negocio()) =>
    request(servidor()).post('/solicitudes-de-negocio').set(como(usuarioId)).send(datos);
  const mias = async (usuarioId: string) =>
    (await request(servidor()).get('/solicitudes-de-negocio').set(como(usuarioId)).expect(200))
      .body;
  const decidir = (id: string, accion: 'aprobacion' | 'rechazo', usuarioId = adminId) =>
    request(servidor())
      .post(`/plataforma/solicitudes-de-negocio/${id}/${accion}`)
      .set(como(usuarioId));

  beforeAll(async () => {
    dueno = await conectarDueno();
    api = new Client({ connectionString: urlApp() });
    await api.connect();
    adminId = await crearEquipoVeci(dueno);
    soporteId = await crearEquipoVeci(dueno, 'VECI_SUPPORT');
    app = await levantarApi();
  });

  afterAll(async () => {
    await app.close();
    await api.end();
    await dueno.end();
  });

  it('solo se reciben negocios de municipios con cobertura (por ahora Mocoa)', async () => {
    const municipios = await request(servidor())
      .get('/comercios/municipios')
      .set(como(adminId))
      .expect(200);
    expect(municipios.body).toEqual([{ id: 86001, nombre: 'Mocoa' }]);
    const fuera = await radicar(await crearUsuario(dueno), negocio(86568)).expect(422);
    expect(fuera.body.codigo).toBe('MUNICIPIO_FUERA_DE_COBERTURA');
  });

  it('la persona ve solo sus solicitudes y no puede revisarlas', async () => {
    const marta = await crearUsuario(dueno);
    const otra = await crearUsuario(dueno);
    await radicar(marta).expect(204);
    expect(await mias(marta)).toEqual([
      expect.objectContaining({
        estado: 'PENDING',
        nombre: 'Asadero El Vecino',
        municipio: 'Mocoa',
      }),
    ]);
    expect(await mias(otra)).toEqual([]);
    const repetida = await radicar(marta).expect(409);
    expect(repetida.body.codigo).toBe('SOLICITUD_EN_REVISION');
    const [{ solicitudId }] = await mias(marta);
    await request(servidor())
      .get('/plataforma/solicitudes-de-negocio')
      .set(como(marta))
      .expect(403);
    await decidir(solicitudId, 'aprobacion', marta).expect(403);
    // Soporte VECI atiende cuentas, pero no da de alta negocios.
    await decidir(solicitudId, 'aprobacion', soporteId).expect(403);
  });

  it('al aprobar nace el negocio con quien lo pidió como propietaria', async () => {
    const rosa = await crearUsuario(dueno);
    await radicar(rosa).expect(204);
    const [{ solicitudId }] = await mias(rosa);
    const pendientes = await request(servidor())
      .get('/plataforma/solicitudes-de-negocio?estado=PENDING')
      .set(como(adminId))
      .expect(200);
    expect(pendientes.body).toContainEqual(
      expect.objectContaining({
        solicitudId,
        solicitante: expect.objectContaining({ usuarioId: rosa, nombre: 'Prueba' }),
      }),
    );
    const { comercioId } = (await decidir(solicitudId, 'aprobacion').expect(201)).body;
    await decidir(solicitudId, 'aprobacion').expect(409);
    const espacios = await request(servidor()).get('/cuenta/espacios').set(como(rosa)).expect(200);
    expect(espacios.body).toContainEqual(expect.objectContaining({ comercioId, roles: ['OWNER'] }));
    expect(await mias(rosa)).toEqual([expect.objectContaining({ estado: 'APPROVED', comercioId })]);
    await request(servidor())
      .get('/comercio')
      .set({ ...como(rosa), 'x-veci-comercio': comercioId })
      .expect(200);
  });

  it('al rechazar le dice por qué y puede volver a pedirlo', async () => {
    const luis = await crearUsuario(dueno);
    await radicar(luis).expect(204);
    const [{ solicitudId }] = await mias(luis);
    await decidir(solicitudId, 'rechazo').send({ motivo: 'corto' }).expect(400);
    const motivo = 'La cédula no coincide con la del dueño. Revísala y vuelve a pedirlo.';
    await decidir(solicitudId, 'rechazo').send({ motivo }).expect(204);
    expect(await mias(luis)).toEqual([
      expect.objectContaining({ estado: 'REJECTED', nota: motivo, comercioId: null }),
    ]);
    await radicar(luis).expect(204);
  });

  it('la base de datos aplica las mismas reglas aunque la API se equivoque', async () => {
    const ana = await crearUsuario(dueno);
    await radicar(ana).expect(204);
    const ver = async (usuarioId: string) => {
      await api.query('BEGIN');
      await api.query(`SELECT set_config('app.user_id', $1, true)`, [usuarioId]);
      const { rows } = await api.query(
        'SELECT applicant_user_id FROM tenancy.business_applications',
      );
      return { rows, fin: () => api.query('ROLLBACK') };
    };
    const extrano = await ver(await crearUsuario(dueno));
    expect(extrano.rows).toEqual([]);
    const propia = await api.query(
      `UPDATE tenancy.business_applications SET review_note = 'yo misma me apruebo'`,
    );
    expect(propia.rowCount).toBe(0);
    await extrano.fin();

    const deAna = await ver(ana);
    expect(deAna.rows).toEqual([{ applicant_user_id: ana }]);
    const autoaprobada = await api
      .query(
        `INSERT INTO tenancy.business_applications (applicant_user_id, display_name, document_type_id,
                document_number, business_type_id, contact_phone, municipality_id,
                business_application_status_id)
         VALUES ($1, 'Trampa', 1, '1124500999', 1, '+573100000000', 86001, 2)`,
        [ana],
      )
      .catch((error: Error) => error);
    expect(String(autoaprobada)).toContain('row-level security');
    await deAna.fin();

    const delEquipo = await ver(adminId);
    expect(delEquipo.rows.length).toBeGreaterThanOrEqual(1);
    await delEquipo.fin();
  });

  it('dice qué puede hacer cada quien en la consola VECI', async () => {
    const ruta = '/cuenta/permisos-de-plataforma';
    const admin = await request(servidor()).get(ruta).set(como(adminId)).expect(200);
    expect(admin.body).toContain('platform.manage_tenants');
    const cliente = await request(servidor())
      .get(ruta)
      .set(como(await crearUsuario(dueno)))
      .expect(200);
    expect(cliente.body).toEqual([]);
  });
});
