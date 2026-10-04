import { INestApplication } from '@nestjs/common';
import { Client } from 'pg';
import request from 'supertest';
import { ComercioDePrueba, conectarDueno } from '../soporte/base-de-datos';
import { crearComercio } from '../soporte/escenario';
import { crearUsuario } from '../soporte/personas';
import {
  PIN_DE_PRUEBA,
  celularAleatorio,
  darAcceso,
  dispositivo,
  entrarAlComercio,
  entrarConPin,
} from '../soporte/acceso';
import { levantarApi } from '../soporte/aplicacion';

type Cabeceras = Record<string, string>;
const documento = () => String(Math.floor(1_000_000_000 + Math.random() * 8_999_999_999));

// EP-02: invitar cajeros, su primer ingreso, suspender, restablecer PIN y cierre remoto.
describe('Equipo del negocio y dispositivos (EP-02)', () => {
  let app: INestApplication;
  let dueno: Client;
  let a: ComercioDePrueba;
  let propietaria: Cabeceras;

  const invitar = (celular: string) =>
    request(app.getHttpServer())
      .post('/equipo/cajeros')
      .set(propietaria)
      .send({ celular, nombres: 'Ana Lucía', tipoDocumento: 'CC', numeroDocumento: documento() });

  /** Primer ingreso de la cajera: PIN temporal → crea el suyo → elige el negocio. */
  async function primerIngreso(celular: string, pinTemporal: string, d = dispositivo()) {
    const servidor = app.getHttpServer();
    const ingreso = await entrarConPin(servidor, celular, pinTemporal, d).expect(200);
    expect(ingreso.body).toMatchObject({ requiereCambioDePin: true });
    const sesion = await request(servidor)
      .post('/sesion/pin-nuevo')
      .send({ tokenCambio: ingreso.body.tokenCambio, pinNuevo: '730284', dispositivo: d })
      .expect(200);
    expect(sesion.body.espacios).toEqual([
      expect.objectContaining({ comercioId: a.comercioId, invitacionPendiente: true }),
    ]);
    const authorization = `Bearer ${sesion.body.tokenAcceso}`;
    await request(servidor)
      .post('/cuenta/comercio-activo')
      .set({ authorization })
      .send({ comercioId: a.comercioId })
      .expect(200);
    return { authorization, 'x-veci-comercio': a.comercioId };
  }

  beforeAll(async () => {
    dueno = await conectarDueno();
    a = await crearComercio(dueno);
    const celular = await darAcceso(dueno, a.usuarioId);
    app = await levantarApi();
    const sesion = await entrarAlComercio(
      app.getHttpServer(),
      celular,
      a.comercioId,
      dispositivo('WEB'),
    );
    propietaria = { authorization: sesion.authorization, 'x-veci-comercio': a.comercioId };
  });

  afterAll(async () => {
    await app.close();
    await dueno.end();
  });

  it('invita una cajera que entra con PIN temporal y crea el suyo (HU-02-04, HU-02-05)', async () => {
    const celular = celularAleatorio();
    const invitacion = await invitar(celular).expect(201);
    expect(invitacion.body.pinTemporal).toMatch(/^\d{6}$/);
    const cajera = await primerIngreso(celular, invitacion.body.pinTemporal);
    const equipo = await request(app.getHttpServer()).get('/equipo').set(propietaria).expect(200);
    expect(equipo.body).toContainEqual(
      expect.objectContaining({ membresiaId: invitacion.body.membresiaId, estado: 'ACTIVE' }),
    );
    await request(app.getHttpServer()).get('/horarios').set(cajera).expect(200);
    await request(app.getHttpServer()).get('/equipo').set(cajera).expect(403);
  });

  it('respeta el cupo de cajeros del plan y permite volver a invitar a quien se retiró', async () => {
    const segunda = await invitar(celularAleatorio()).expect(201);
    const sinCupo = await invitar(celularAleatorio()).expect(409);
    expect(sinCupo.body.codigo).toBe('LIMITE_DE_CAJEROS');
    await request(app.getHttpServer())
      .patch(`/equipo/${segunda.body.membresiaId}/estado`)
      .set(propietaria)
      .send({ accion: 'RETIRAR' })
      .expect(200);
    await invitar(celularAleatorio()).expect(201);
  });

  it('suspende y reactiva: suspendida no entra al negocio (HU-02-04)', async () => {
    const servidor = app.getHttpServer();
    const equipo = await request(servidor).get('/equipo').set(propietaria).expect(200);
    const activa = equipo.body.find(
      (m: { estado: string; roles: string[] }) =>
        m.estado === 'ACTIVE' && m.roles.includes('CASHIER'),
    );
    const ruta = `/equipo/${activa.membresiaId}/estado`;
    await request(servidor).patch(ruta).set(propietaria).send({ accion: 'SUSPENDER' }).expect(200);
    const celular = activa.celular.replace('+57', '');
    const ingreso = await entrarConPin(servidor, celular, '730284').expect(200);
    await request(servidor)
      .post('/cuenta/comercio-activo')
      .set({ authorization: `Bearer ${ingreso.body.sesion.tokenAcceso}` })
      .send({ comercioId: a.comercioId })
      .expect(403);
    await request(servidor).patch(ruta).set(propietaria).send({ accion: 'REACTIVAR' }).expect(200);
  });

  it('la propietaria restablece el PIN y cierra la sesión del celular a distancia', async () => {
    const servidor = app.getHttpServer();
    const equipo = await request(servidor).get('/equipo').set(propietaria).expect(200);
    const cajera = equipo.body.find(
      (m: { estado: string; roles: string[] }) =>
        m.estado === 'ACTIVE' && m.roles.includes('CASHIER'),
    );
    const restablecido = await request(servidor)
      .post(`/equipo/${cajera.membresiaId}/restablecer-pin`)
      .set(propietaria)
      .expect(200);
    const d = dispositivo();
    const sesion = await primerIngresoTrasRestablecer(
      cajera.celular,
      restablecido.body.pinTemporal,
      d,
    );
    const dispositivos = await request(servidor).get('/dispositivos').set(propietaria).expect(200);
    expect(dispositivos.body).toContainEqual(expect.objectContaining({ dispositivoId: d.id }));
    const cierre = await request(servidor)
      .post(`/dispositivos/${d.id}/cerrar-sesion`)
      .set(propietaria)
      .expect(200);
    expect(cierre.body.sesionesCerradas).toBeGreaterThanOrEqual(1);
    await request(servidor).get('/horarios').set(sesion).expect(401);
  });

  async function primerIngresoTrasRestablecer(celularE164: string, pin: string, d = dispositivo()) {
    const servidor = app.getHttpServer();
    const ingreso = await entrarConPin(servidor, celularE164, pin, d).expect(200);
    const sesion = await request(servidor)
      .post('/sesion/pin-nuevo')
      .send({ tokenCambio: ingreso.body.tokenCambio, pinNuevo: '518027', dispositivo: d })
      .expect(200);
    const authorization = `Bearer ${sesion.body.tokenAcceso}`;
    await request(servidor)
      .post('/cuenta/comercio-activo')
      .set({ authorization })
      .send({ comercioId: a.comercioId })
      .expect(200);
    return { authorization, 'x-veci-comercio': a.comercioId };
  }

  it('Soporte VECI restablece el PIN de un cliente si el documento coincide (HU-02-07)', async () => {
    const servidor = app.getHttpServer();
    const clienteId = await crearUsuario(dueno);
    const celular = await darAcceso(dueno, clienteId);
    const { rows } = await dueno.query(
      `SELECT p.document_number FROM identity.users u
         JOIN identity.people p ON p.id = u.person_id WHERE u.id = $1`,
      [clienteId],
    );
    const pedido = { celular, tipoDocumento: 'CC', numeroDocumento: rows[0].document_number };
    const ingreso = await entrarConPin(servidor, await usuarioDeSoporte(), PIN_DE_PRUEBA);
    const soporte = { authorization: `Bearer ${ingreso.body.sesion.tokenAcceso}` };
    const ruta = '/soporte/clientes/restablecer-pin';
    await request(servidor)
      .post(ruta)
      .set(soporte)
      .send({ ...pedido, numeroDocumento: '1111111111' })
      .expect(422);
    const ok = await request(servidor).post(ruta).set(soporte).send(pedido).expect(200);
    expect(ok.body.pinTemporal).toMatch(/^\d{6}$/);
    const conPinTemporal = await entrarConPin(servidor, celular, ok.body.pinTemporal).expect(200);
    expect(conPinTemporal.body.requiereCambioDePin).toBe(true);
    const ajeno = { authorization: propietaria.authorization };
    await request(servidor).post(ruta).set(ajeno).send(pedido).expect(403);
  });

  async function usuarioDeSoporte(): Promise<string> {
    const usuarioId = await crearUsuario(dueno);
    await dueno.query(
      `INSERT INTO identity.user_platform_roles (user_id, role_id)
       SELECT $1, id FROM identity.roles WHERE code = 'VECI_SUPPORT'`,
      [usuarioId],
    );
    return darAcceso(dueno, usuarioId);
  }
});
