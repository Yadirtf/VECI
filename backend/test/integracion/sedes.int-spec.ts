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

// HU-03-03 por HTTP: varias sedes solo con el plan Pro, y cajeros por sede.
describe('Sedes del negocio', () => {
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

  it('en el plan de prueba no se abre otra sede', async () => {
    const { comercioId } = (await registrarNegocio(servidor(), adminId, usuarioId, negocio())).body;
    const respuesta = await request(servidor())
      .post('/sedes')
      .set(enComercio(comercioId))
      .send({ nombre: 'Norte' });
    expect(respuesta.status).toBe(409);
    expect(respuesta.body.codigo).toBe('SEDES_SOLO_EN_PRO');
  });

  it('con el plan Pro abre sedes y asigna cajeros', async () => {
    const { comercioId } = (await registrarNegocio(servidor(), adminId, usuarioId, negocio())).body;
    await dueno.query(
      `UPDATE billing.subscriptions SET plan_id = (SELECT id FROM billing.plans WHERE code = 'PRO')
        WHERE tenant_id = $1`,
      [comercioId],
    );
    const norte = (
      await request(servidor())
        .post('/sedes')
        .set(enComercio(comercioId))
        .send({ nombre: 'Norte' })
        .expect(201)
    ).body;
    const repetida = await request(servidor())
      .post('/sedes')
      .set(enComercio(comercioId))
      .send({ nombre: 'Norte' });
    expect(repetida.status).toBe(409);

    const invitado = (
      await request(servidor())
        .post('/equipo/cajeros')
        .set(enComercio(comercioId))
        .send({
          celular: celularAleatorio(),
          nombres: 'Ana',
          tipoDocumento: 'CC',
          numeroDocumento: `11${Date.now() % 100000000}`,
        })
        .expect(201)
    ).body;
    await request(servidor())
      .put(`/sedes/cajeros/${invitado.membresiaId}`)
      .set(enComercio(comercioId))
      .send({ sedeIds: [norte.sedeId] })
      .expect(204);
    const mapa = (await request(servidor()).get('/sedes').set(enComercio(comercioId)).expect(200))
      .body;
    expect(mapa.cajeros).toEqual([
      expect.objectContaining({ nombre: 'Ana', sedeIds: [norte.sedeId] }),
    ]);
    expect(mapa.cupo).toEqual({ ocupadas: 2, limite: null, variasSedes: true });

    const principal = mapa.sedes.find((s: { principal: boolean }) => s.principal);
    await request(servidor())
      .patch(`/sedes/${principal.sedeId}`)
      .set(enComercio(comercioId))
      .send({ activa: false })
      .expect(422);
    const cerrada = (
      await request(servidor())
        .patch(`/sedes/${norte.sedeId}`)
        .set(enComercio(comercioId))
        .send({ activa: false })
        .expect(200)
    ).body;
    expect(cerrada).toMatchObject({ activa: false, estado: 'INACTIVE' });
  });
});
