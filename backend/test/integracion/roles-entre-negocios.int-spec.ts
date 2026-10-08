import { INestApplication } from '@nestjs/common';
import { Client } from 'pg';
import request from 'supertest';
import { ComercioDePrueba, conectarDueno } from '../soporte/base-de-datos';
import { darAcceso } from '../soporte/acceso';
import { levantarApi } from '../soporte/aplicacion';
import { crearComercio } from '../soporte/escenario';
import { crearEquipoVeci } from '../soporte/negocios';

type Cabeceras = Record<string, string>;

// Roles y seguridad: una misma persona puede ser cliente, cajera y dueña en negocios
// distintos; cada negocio solo alcanza lo que le corresponde.
describe('Roles entre negocios', () => {
  let app: INestApplication;
  let dueno: Client;
  let a: ComercioDePrueba;
  let b: ComercioDePrueba;

  const en = (c: ComercioDePrueba, usuarioId = c.usuarioId): Cabeceras => ({
    'x-veci-usuario': usuarioId,
    'x-veci-comercio': c.comercioId,
  });
  const servidor = () => app.getHttpServer();

  async function documentoDe(usuarioId: string): Promise<string> {
    const { rows } = await dueno.query(
      `SELECT p.document_number FROM identity.users u
         JOIN identity.people p ON p.id = u.person_id WHERE u.id = $1`,
      [usuarioId],
    );
    return rows[0].document_number;
  }

  /** Invita como cajera de A a quien ya tiene cuenta (por su celular). */
  async function cajeraDeA(usuarioId: string, celular: string): Promise<string> {
    const invitacion = await request(servidor())
      .post('/equipo/cajeros')
      .set(en(a))
      .send({
        celular,
        nombres: 'Doris',
        tipoDocumento: 'CC',
        numeroDocumento: await documentoDe(usuarioId),
      })
      .expect(201);
    expect(invitacion.body.pinTemporal).toBeNull();
    return invitacion.body.membresiaId;
  }

  beforeAll(async () => {
    dueno = await conectarDueno();
    a = await crearComercio(dueno);
    b = await crearComercio(dueno);
    app = await levantarApi();
  });

  afterAll(async () => {
    await app.close();
    await dueno.end();
  });

  it('la dueña de A no saca un PIN temporal de quien también es dueña de B', async () => {
    const membresiaId = await cajeraDeA(b.usuarioId, await darAcceso(dueno, b.usuarioId));
    const respuesta = await request(servidor())
      .post(`/equipo/${membresiaId}/restablecer-pin`)
      .set(en(a))
      .expect(403);
    expect(respuesta.body.codigo).toBe('PIN_TEMPORAL_NO_PERMITIDO');
  });

  it('quien es cajera en A no administra A, aunque sea dueña en B', async () => {
    await request(servidor())
      .post('/cuenta/comercio-activo')
      .set({ 'x-veci-usuario': b.usuarioId })
      .send({ comercioId: a.comercioId })
      .expect(200);
    const cajera = en(a, b.usuarioId);
    await request(servidor()).get('/horarios').set(cajera).expect(200);
    await request(servidor()).patch('/comercio').set(cajera).send({ nombre: 'Mío' }).expect(403);
    await request(servidor()).get('/equipo').set(cajera).expect(403);
    await request(servidor()).get('/dispositivos').set(cajera).expect(403);
    await request(servidor()).get('/tiqueteras/tipos').set(cajera).expect(403);
    await request(servidor()).get('/equipo').set(en(b)).expect(200);
  });

  it('una clienta del negocio no entra a operarlo', async () => {
    const { rows } = await dueno.query(
      `SELECT u.id FROM customers.affiliations af
         JOIN identity.users u ON u.person_id = af.person_id WHERE af.id = $1`,
      [a.afiliacionId],
    );
    const clienteId =
      rows[0]?.id ??
      (
        await dueno.query(
          `INSERT INTO identity.users (person_id, user_status_id)
           SELECT af.person_id, us.id FROM customers.affiliations af, identity.user_statuses us
            WHERE af.id = $1 AND us.code = 'ACTIVE' RETURNING id`,
          [a.afiliacionId],
        )
      ).rows[0].id;
    const eleccion = await request(servidor())
      .post('/cuenta/comercio-activo')
      .set({ 'x-veci-usuario': clienteId })
      .send({ comercioId: a.comercioId })
      .expect(200);
    expect(eleccion.body.permisos).toEqual([]);
    await request(servidor()).get('/comercio').set(en(a, clienteId)).expect(403);
    await request(servidor()).get('/clientes?q=pru').set(en(a, clienteId)).expect(403);
  });

  it('Soporte VECI no restablece el PIN de una cuenta del equipo VECI', async () => {
    const soporte = await crearEquipoVeci(dueno, 'VECI_SUPPORT');
    const admin = await crearEquipoVeci(dueno);
    const respuesta = await request(servidor())
      .post('/soporte/clientes/restablecer-pin')
      .set({ 'x-veci-usuario': soporte })
      .send({
        celular: await darAcceso(dueno, admin),
        tipoDocumento: 'CC',
        numeroDocumento: await documentoDe(admin),
      })
      .expect(403);
    expect(respuesta.body.codigo).toBe('PIN_TEMPORAL_NO_PERMITIDO');
  });
});
