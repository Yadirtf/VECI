import { INestApplication } from '@nestjs/common';
import { Client } from 'pg';
import request from 'supertest';
import { ComercioDePrueba, conectarDueno } from '../soporte/base-de-datos';
import { crearComercio } from '../soporte/escenario';
import { crearUsuario } from '../soporte/personas';
import {
  PIN_DE_PRUEBA,
  darAcceso,
  dispositivo,
  entrarAlComercio,
  entrarConPin,
} from '../soporte/acceso';
import { levantarApi } from '../soporte/aplicacion';

// EP-02: ingreso con PIN, bloqueo, renovación con rotación, comercio activo y cierre.
describe('Sesión y cuenta (EP-02)', () => {
  let app: INestApplication;
  let dueno: Client;
  let a: ComercioDePrueba;
  let b: ComercioDePrueba;
  let celularA: string;

  beforeAll(async () => {
    dueno = await conectarDueno();
    [a, b] = [await crearComercio(dueno), await crearComercio(dueno)];
    celularA = await darAcceso(dueno, a.usuarioId);
    app = await levantarApi();
  });

  afterAll(async () => {
    await app.close();
    await dueno.end();
  });

  it('entra con celular y PIN y ve sus negocios (HU-02-01)', async () => {
    const respuesta = await entrarConPin(app.getHttpServer(), celularA, PIN_DE_PRUEBA).expect(200);
    expect(respuesta.body.requiereCambioDePin).toBe(false);
    expect(respuesta.body.sesion.segundosAcceso).toBe(900);
    expect(respuesta.body.sesion.espacios).toEqual([
      expect.objectContaining({ comercioId: a.comercioId, roles: ['OWNER'] }),
    ]);
  });

  it('acepta el celular escrito con espacios o con +57', async () => {
    const conEspacios = `${celularA.slice(0, 3)} ${celularA.slice(3, 6)} ${celularA.slice(6)}`;
    await entrarConPin(app.getHttpServer(), conEspacios, PIN_DE_PRUEBA).expect(200);
    await entrarConPin(app.getHttpServer(), `+57${celularA}`, PIN_DE_PRUEBA).expect(200);
  });

  it('responde igual si el celular no existe o el PIN no coincide', async () => {
    const servidor = app.getHttpServer();
    const sinCuenta = await entrarConPin(servidor, '3009998877', '909192').expect(401);
    const pinMalo = await entrarConPin(servidor, celularA, '909192').expect(401);
    expect(sinCuenta.body.codigo).toBe('CREDENCIALES_INCORRECTAS');
    expect(pinMalo.body.codigo).toBe(sinCuenta.body.codigo);
  });

  it('bloquea tras 5 intentos fallidos y lo deja en auditoría', async () => {
    const usuarioId = await crearUsuario(dueno);
    const celular = await darAcceso(dueno, usuarioId);
    const servidor = app.getHttpServer();
    for (let i = 0; i < 5; i++) await entrarConPin(servidor, celular, '909192').expect(401);
    const bloqueada = await entrarConPin(servidor, celular, PIN_DE_PRUEBA).expect(401);
    expect(bloqueada.body.codigo).toBe('CUENTA_BLOQUEADA');
    const { rowCount } = await dueno.query(
      `SELECT 1 FROM audit.audit_log l JOIN audit.actions a ON a.id = l.action_id
        WHERE a.code = 'LOGIN_LOCKED' AND l.actor_user_id = $1`,
      [usuarioId],
    );
    expect(rowCount).toBe(1);
  });

  it('renueva rotando el token y cierra la sesión si reusan el viejo', async () => {
    const servidor = app.getHttpServer();
    const ingreso = await entrarConPin(servidor, celularA, PIN_DE_PRUEBA).expect(200);
    const viejo = ingreso.body.sesion.tokenRenovacion;
    const renovada = await request(servidor)
      .post('/sesion/renovar')
      .send({ tokenRenovacion: viejo })
      .expect(200);
    expect(renovada.body.tokenRenovacion).not.toBe(viejo);
    const reuso = await request(servidor)
      .post('/sesion/renovar')
      .send({ tokenRenovacion: viejo })
      .expect(401);
    expect(reuso.body.codigo).toBe('SESION_CERRADA');
    await request(servidor)
      .get('/cuenta/espacios')
      .set({ authorization: `Bearer ${renovada.body.tokenAcceso}` })
      .expect(401);
  });

  it('elige su negocio y registra el celular de la caja (HU-02-06)', async () => {
    const servidor = app.getHttpServer();
    const d = dispositivo();
    const cabeceras = await entrarAlComercio(servidor, celularA, a.comercioId, d);
    const { rows } = await dueno.query(
      `SELECT 1 FROM tenancy.tenant_devices WHERE tenant_id = $1 AND device_id = $2`,
      [a.comercioId, d.id],
    );
    expect(rows).toHaveLength(1);
    await request(servidor).get('/horarios').set(cabeceras).expect(200);
  });

  it('no deja elegir ni usar un negocio ajeno', async () => {
    const servidor = app.getHttpServer();
    const { authorization } = await entrarAlComercio(servidor, celularA, a.comercioId);
    await request(servidor)
      .post('/cuenta/comercio-activo')
      .set({ authorization })
      .send({ comercioId: b.comercioId })
      .expect(403);
    await request(servidor)
      .get('/horarios')
      .set({ authorization, 'x-veci-comercio': b.comercioId })
      .expect(403);
  });

  it('al salir, el token deja de servir de inmediato', async () => {
    const servidor = app.getHttpServer();
    const { authorization } = await entrarAlComercio(servidor, celularA, a.comercioId);
    await request(servidor).post('/sesion/salir').set({ authorization }).expect(204);
    await request(servidor).get('/cuenta/espacios').set({ authorization }).expect(401);
  });

  it('cambia el PIN y rechaza uno fácil de adivinar (HU-02-03)', async () => {
    const usuarioId = await crearUsuario(dueno);
    const celular = await darAcceso(dueno, usuarioId);
    const servidor = app.getHttpServer();
    const ingreso = await entrarConPin(servidor, celular, PIN_DE_PRUEBA).expect(200);
    const authorization = `Bearer ${ingreso.body.sesion.tokenAcceso}`;
    const debil = await request(servidor)
      .put('/cuenta/pin')
      .set({ authorization })
      .send({ pinActual: PIN_DE_PRUEBA, pinNuevo: '123456' })
      .expect(422);
    expect(debil.body.message).toMatch(/adivinar|fácil/i);
    await request(servidor)
      .put('/cuenta/pin')
      .set({ authorization })
      .send({ pinActual: PIN_DE_PRUEBA, pinNuevo: '730284' })
      .expect(204);
    await entrarConPin(servidor, celular, PIN_DE_PRUEBA).expect(401);
    await entrarConPin(servidor, celular, '730284').expect(200);
  });
});
