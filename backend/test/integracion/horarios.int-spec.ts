import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { Client } from 'pg';
import request from 'supertest';
import { AppModule } from '../../src/app.module';
import { configurarAplicacion } from '../../src/app.setup';
import { ComercioDePrueba, conectarDueno, urlApp } from '../soporte/base-de-datos';
import { crearComercio } from '../soporte/escenario';

// HU-01-05 y HU-01-10: el guard fija el comercio y el módulo de ejemplo responde por HTTP.
describe('API de horarios con comercio activo', () => {
  let app: INestApplication;
  let dueno: Client;
  let a: ComercioDePrueba;
  let b: ComercioDePrueba;

  const comoUsuario = (usuarioId: string, comercioId: string) => ({
    'x-veci-usuario': usuarioId,
    'x-veci-comercio': comercioId,
  });
  const horario = (c: ComercioDePrueba, horaInicio: string, horaFin: string) => ({
    servicioId: c.servicioId,
    sedeId: c.sedeId,
    dias: ['MONDAY'],
    horaInicio,
    horaFin,
  });

  beforeAll(async () => {
    process.env.DATABASE_APP_URL = urlApp();
    dueno = await conectarDueno();
    [a, b] = [await crearComercio(dueno), await crearComercio(dueno)];
    const modulo = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = modulo.createNestApplication({ logger: false });
    configurarAplicacion(app);
    await app.init();
  });

  afterAll(async () => {
    await app.close();
    await dueno.end();
  });

  it('pide sesión, negocio activo y membresía', async () => {
    const servidor = app.getHttpServer();
    await request(servidor).get('/horarios').expect(401);
    await request(servidor).get('/horarios').set({ 'x-veci-usuario': a.usuarioId }).expect(400);
    await request(servidor)
      .get('/horarios')
      .set(comoUsuario(a.usuarioId, b.comercioId))
      .expect(403);
  });

  it('crea un horario y rechaza otro que se cruza', async () => {
    const servidor = app.getHttpServer();
    const cabeceras = comoUsuario(a.usuarioId, a.comercioId);
    await request(servidor)
      .post('/horarios')
      .set(cabeceras)
      .send(horario(a, '11:30', '15:00'))
      .expect(201);
    const cruce = await request(servidor)
      .post('/horarios')
      .set(cabeceras)
      .send(horario(a, '14:00', '16:00'));
    expect(cruce.status).toBe(409);
    expect(cruce.body.codigo).toBe('HORARIO_SE_CRUZA');
  });

  it('un comercio no puede usar la sede de otro', async () => {
    const respuesta = await request(app.getHttpServer())
      .post('/horarios')
      .set(comoUsuario(b.usuarioId, b.comercioId))
      .send({ ...horario(b, '06:00', '09:00'), sedeId: a.sedeId });
    expect(respuesta.status).toBe(404);
  });

  it('cada comercio lista solo sus horarios', async () => {
    const respuesta = await request(app.getHttpServer())
      .get('/horarios')
      .set(comoUsuario(b.usuarioId, b.comercioId))
      .expect(200);
    expect(respuesta.body).toEqual([]);
  });

  it('edita desde hoy, pausa y avisa a la caja con la ETag', async () => {
    const servidor = app.getHttpServer();
    const cabeceras = comoUsuario(b.usuarioId, b.comercioId);
    const [creado] = (
      await request(servidor)
        .post('/horarios')
        .set(cabeceras)
        .send(horario(b, '18:00', '21:00'))
        .expect(201)
    ).body;
    const primera = await request(servidor).get('/horarios').set(cabeceras).expect(200);
    const etag = primera.headers.etag as string;
    await request(servidor)
      .get('/horarios')
      .set({ ...cabeceras, 'if-none-match': etag })
      .expect(304);

    const editado = (
      await request(servidor)
        .patch(`/horarios/${creado.id}`)
        .set(cabeceras)
        .send({ horaInicio: '18:30', horaFin: '21:30' })
        .expect(200)
    ).body;
    expect(editado.id).not.toBe(creado.id);
    const despues = await request(servidor)
      .get('/horarios')
      .set({ ...cabeceras, 'if-none-match': etag })
      .expect(200);
    expect(despues.body.map((h: { horaInicio: string }) => h.horaInicio)).toEqual(['18:30']);

    const pausado = await request(servidor)
      .patch(`/horarios/${editado.id}/estado`)
      .set(cabeceras)
      .send({ activo: false })
      .expect(200);
    expect(pausado.body.activo).toBe(false);
    await request(servidor)
      .patch(`/horarios/${creado.id}`)
      .set(cabeceras)
      .send({ horaInicio: '18:00', horaFin: '19:00' })
      .expect(404);
  });

  it('cuenta el horario que la fecha UTC del servidor dejó empezando mañana', async () => {
    const servidor = app.getHttpServer();
    const cabeceras = comoUsuario(a.usuarioId, a.comercioId);
    const { rows } = await dueno.query<{ id: string }>(
      `INSERT INTO tenancy.service_schedules (tenant_id, service_id, branch_id, weekday_id, hours, valid_during)
       SELECT $1, $2, $3, w.id, core.time_range('06:00'::time, '09:00'::time, '[)'), daterange(current_date + 1, NULL, '[)')
         FROM core.weekdays w WHERE w.code = 'TUESDAY' RETURNING id::text`,
      [a.comercioId, a.servicioId, a.sedeId],
    );
    const lista = await request(servidor).get('/horarios').set(cabeceras).expect(200);
    expect(lista.body.map((h: { id: string }) => h.id)).toContain(rows[0].id);
    await request(servidor)
      .patch(`/horarios/${rows[0].id}`)
      .set(cabeceras)
      .send({ horaInicio: '06:30', horaFin: '09:00' })
      .expect(200);
    const despues = await request(servidor).get('/horarios').set(cabeceras).expect(200);
    const martes = despues.body.filter((h: { dia: string }) => h.dia === 'TUESDAY');
    expect(martes.map((h: { horaInicio: string }) => h.horaInicio)).toEqual(['06:30']);
  });

  it('programa un servicio en varios días: reemplaza el que había y crea el que faltaba', async () => {
    const servidor = app.getHttpServer();
    const c = await crearComercio(dueno);
    const cabeceras = comoUsuario(c.usuarioId, c.comercioId);
    await request(servidor)
      .post('/horarios')
      .set(cabeceras)
      .send(horario(c, '08:00', '10:00'))
      .expect(201);
    const semana = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'];
    const programados = await request(servidor)
      .put('/horarios/programacion')
      .set(cabeceras)
      .send({ ...horario(c, '11:30', '15:00'), dias: semana })
      .expect(200);
    expect(programados.body).toHaveLength(5);
    const lista = await request(servidor).get('/horarios').set(cabeceras).expect(200);
    expect(
      lista.body.map((h: { dia: string; horaInicio: string }) => `${h.dia} ${h.horaInicio}`),
    ).toEqual(semana.map((dia) => `${dia} 11:30`));
  });

  it('valida el formato de la petición', async () => {
    await request(app.getHttpServer())
      .post('/horarios')
      .set(comoUsuario(a.usuarioId, a.comercioId))
      .send({ ...horario(a, '7am', '15:00') })
      .expect(400);
  });

  it('expone el estado de salud sin pedir comercio', async () => {
    const respuesta = await request(app.getHttpServer()).get('/salud').expect(200);
    expect(respuesta.body).toMatchObject({ estado: 'ok', baseDatos: 'ok' });
  });
});
