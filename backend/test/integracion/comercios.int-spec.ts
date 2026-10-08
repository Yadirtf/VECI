import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { Client } from 'pg';
import request from 'supertest';
import { AppModule } from '../../src/app.module';
import { configurarAplicacion } from '../../src/app.setup';
import { conectarDueno, urlApp } from '../soporte/base-de-datos';
import { celularAleatorio } from '../soporte/acceso';
import { crearEquipoVeci, registrarNegocio } from '../soporte/negocios';
import { crearUsuario } from '../soporte/personas';

// HU-03-01 a HU-03-03 por HTTP, con RLS real: el alta corre como veci_api.
describe('Comercios, sedes y horarios', () => {
  let app: INestApplication;
  let dueno: Client;
  let usuarioId: string;
  let adminId: string;

  const negocio = () => ({
    nombre: 'Restaurante La Prueba',
    tipoNegocio: 'RESTAURANT',
    tipoDocumento: 'NIT',
    numeroDocumento: '800197268',
    celular: celularAleatorio(),
    municipioId: 86001,
  });
  const servidor = () => app.getHttpServer();
  const comoUsuario = (id: string) => ({ 'x-veci-usuario': id });
  const enComercio = (comercioId: string, id = usuarioId) => ({
    ...comoUsuario(id),
    'x-veci-comercio': comercioId,
  });

  beforeAll(async () => {
    process.env.DATABASE_APP_URL = urlApp();
    dueno = await conectarDueno();
    usuarioId = await crearUsuario(dueno);
    adminId = await crearEquipoVeci(dueno);
    const modulo = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = modulo.createNestApplication({ logger: false });
    configurarAplicacion(app);
    await app.init();
  });

  afterAll(async () => {
    await app.close();
    await dueno.end();
  });

  it('lista los tipos de negocio con sus servicios sugeridos', async () => {
    const tipos = (
      await request(servidor()).get('/comercios/tipos').set(comoUsuario(usuarioId)).expect(200)
    ).body;
    expect(tipos[0]).toEqual({
      codigo: 'RESTAURANT',
      nombre: 'Restaurante',
      servicios: [
        { nombre: 'Desayuno', horaInicio: '06:30', horaFin: '09:30' },
        { nombre: 'Almuerzo', horaInicio: '11:30', horaFin: '15:00' },
        { nombre: 'Cena', horaInicio: '18:00', horaFin: '21:00' },
      ],
    });
  });

  it('registra el negocio con todo lo que necesita y el camino para abrir', async () => {
    const alta = await registrarNegocio(servidor(), adminId, usuarioId, negocio());
    const { comercioId, slug } = alta.body;
    expect(slug).toMatch(/^restaurante-la-prueba/);

    const perfil = (
      await request(servidor()).get('/comercio').set(enComercio(comercioId)).expect(200)
    ).body;
    expect(perfil).toMatchObject({
      estado: 'ONBOARDING',
      abierto: false,
      documento: { tipo: 'NIT', numero: '8001972684' },
      plan: { codigo: 'TRIAL', estado: 'TRIAL' },
      puedeAbrir: false,
    });

    const servicios = (
      await request(servidor()).get('/servicios').set(enComercio(comercioId)).expect(200)
    ).body;
    expect(servicios.map((s: { nombre: string }) => s.nombre)).toEqual([
      'Desayuno',
      'Almuerzo',
      'Cena',
    ]);
    const sedes = (await request(servidor()).get('/sedes').set(enComercio(comercioId)).expect(200))
      .body;
    expect(sedes.sedes).toEqual([
      expect.objectContaining({ nombre: 'Principal', principal: true, municipio: 'Mocoa' }),
    ]);

    const abrirSinHorario = await request(servidor())
      .post('/comercio/abrir')
      .set(enComercio(comercioId));
    expect(abrirSinHorario.status).toBe(422);
    expect(abrirSinHorario.body.codigo).toBe('NEGOCIO_SIN_HORARIOS');

    await request(servidor())
      .post('/horarios')
      .set(enComercio(comercioId))
      .send({
        servicioId: servicios[1].id,
        sedeId: sedes.sedes[0].sedeId,
        dias: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
        horaInicio: '11:30',
        horaFin: '15:00',
      })
      .expect(201);
    const abierto = (
      await request(servidor()).post('/comercio/abrir').set(enComercio(comercioId)).expect(200)
    ).body;
    expect(abierto).toMatchObject({
      estado: 'ACTIVE',
      abierto: true,
      avance: { serviciosConHorario: 1 },
    });
  });

  it('el mismo nombre recibe otro enlace y el negocio aparece en mis negocios', async () => {
    const primero = (await registrarNegocio(servidor(), adminId, usuarioId, negocio())).body;
    const segundo = (await registrarNegocio(servidor(), adminId, usuarioId, negocio())).body;
    expect(segundo.slug).not.toBe(primero.slug);
    const { rows } = await dueno.query(
      `SELECT count(*)::int AS n FROM tenancy.memberships m
         JOIN tenancy.membership_roles mr ON mr.membership_id = m.id
         JOIN identity.roles r ON r.id = mr.role_id AND r.code = 'OWNER'
        WHERE m.user_id = $1`,
      [usuarioId],
    );
    expect(rows[0].n).toBeGreaterThanOrEqual(3);
  });

  it('rechaza un NIT con el dígito equivocado sin crear nada', async () => {
    const respuesta = await request(servidor())
      .post('/solicitudes-de-negocio')
      .set(comoUsuario(usuarioId))
      .send({ ...negocio(), numeroDocumento: '800197268-5' });
    expect(respuesta.status).toBe(422);
    expect(respuesta.body.message).toContain('dígito de verificación es 4');
  });

  it('edita los datos del negocio y deja el celular anterior en la historia', async () => {
    const { comercioId } = (await registrarNegocio(servidor(), adminId, usuarioId, negocio())).body;
    const perfil = (
      await request(servidor())
        .patch('/comercio')
        .set(enComercio(comercioId))
        .send({ nombre: 'La Prueba de Mocoa', celular: '3209998877', correo: 'hola@laprueba.co' })
        .expect(200)
    ).body;
    expect(perfil).toMatchObject({
      nombre: 'La Prueba de Mocoa',
      contacto: { celular: '+573209998877', correo: 'hola@laprueba.co' },
    });
    const { rows } = await dueno.query(
      `SELECT count(*)::int AS n FROM tenancy.tenant_contacts WHERE tenant_id = $1`,
      [comercioId],
    );
    expect(rows[0].n).toBe(3);
  });

  it('Administración VECI registra un negocio e invita a su dueño con PIN temporal', async () => {
    const adminId = await crearUsuario(dueno);
    await request(servidor())
      .post('/plataforma/comercios')
      .set(comoUsuario(adminId))
      .send({})
      .expect(403);
    await dueno.query(
      `INSERT INTO identity.user_platform_roles (user_id, role_id)
       SELECT $1, id FROM identity.roles WHERE code = 'VECI_ADMIN'`,
      [adminId],
    );
    const respuesta = await request(servidor())
      .post('/plataforma/comercios')
      .set(comoUsuario(adminId))
      .send({
        ...negocio(),
        propietario: {
          celular: celularAleatorio(),
          nombres: 'Rosa',
          tipoDocumento: 'CC',
          numeroDocumento: `12${Date.now() % 100000000}`,
        },
      })
      .expect(201);
    expect(respuesta.body.pinTemporal).toMatch(/^\d{6}$/);
    const { rows } = await dueno.query(
      `SELECT ms.code AS estado, r.code AS rol FROM tenancy.memberships m
         JOIN tenancy.membership_statuses ms ON ms.id = m.membership_status_id
         JOIN tenancy.membership_roles mr ON mr.membership_id = m.id
         JOIN identity.roles r ON r.id = mr.role_id
        WHERE m.tenant_id = $1`,
      [respuesta.body.comercioId],
    );
    expect(rows).toEqual([{ estado: 'INVITED', rol: 'OWNER' }]);
  });
});
