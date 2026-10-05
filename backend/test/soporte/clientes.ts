import { INestApplication } from '@nestjs/common';
import { Client } from 'pg';
import request from 'supertest';
import { ComercioDePrueba, conectarDueno } from './base-de-datos';
import { crearComercio } from './escenario';
import { celularAleatorio, darAcceso, dispositivo, entrarAlComercio, entrarConPin } from './acceso';
import { levantarApi } from './aplicacion';

export type Cabeceras = Record<string, string>;

export const documento = () => String(Math.floor(1_000_000_000 + Math.random() * 8_999_999_999));
export const finalDe = (texto: string) => texto.slice(-4);

/**
 * Escenario de EP-04: negocio A (propietaria y cajera) y negocio B (otra propietaria),
 * con la API levantada y la política de datos vigente.
 */
export class NegociosConClientes {
  app!: INestApplication;
  dueno!: Client;
  a!: ComercioDePrueba;
  propietaria!: Cabeceras;
  cajera!: Cabeceras;
  otroNegocio!: Cabeceras;
  politicaId!: string;

  async preparar(): Promise<void> {
    this.dueno = await conectarDueno();
    this.a = await crearComercio(this.dueno);
    const b = await crearComercio(this.dueno);
    this.app = await levantarApi();
    this.propietaria = await this.propietariaDe(this.a);
    this.otroNegocio = await this.propietariaDe(b);
    this.cajera = await this.invitarCajera();
    const politica = await this.http().get('/politica-de-datos').expect(200);
    this.politicaId = politica.body.id;
  }

  async cerrar(): Promise<void> {
    await this.app.close();
    await this.dueno.end();
  }

  servidor() {
    return this.app.getHttpServer();
  }

  http() {
    return request(this.servidor());
  }

  /** Una vecina que se registra sola en la app. Devuelve sus cabeceras y sus datos. */
  async registrarse(nombres = 'Luz Marina', apellidos = 'Chindoy') {
    const datos = { celular: celularAleatorio(), numeroDocumento: documento() };
    const sesion = await this.http()
      .post('/registro')
      .send({
        ...datos,
        nombres,
        apellidos,
        tipoDocumento: 'CC',
        pin: '190573',
        politicaVersionId: this.politicaId,
        dispositivo: dispositivo(),
      })
      .expect(201);
    return { ...datos, sesion: { authorization: `Bearer ${sesion.body.tokenAcceso}` } };
  }

  leerQr(quien: Cabeceras, token: string) {
    return this.http().post('/clientes/qr').set(quien).send({ token });
  }

  registroAsistido(cuerpo: Record<string, unknown>) {
    return this.http()
      .post('/clientes/registro-asistido')
      .set(this.cajera)
      .send({ tipoDocumento: 'CC', politicaVersionId: this.politicaId, ...cuerpo });
  }

  private async propietariaDe(comercio: ComercioDePrueba): Promise<Cabeceras> {
    const celular = await darAcceso(this.dueno, comercio.usuarioId);
    const sesion = await entrarAlComercio(
      this.servidor(),
      celular,
      comercio.comercioId,
      dispositivo('WEB'),
    );
    return { authorization: sesion.authorization, 'x-veci-comercio': comercio.comercioId };
  }

  /** La cajera del negocio A: invitada por la propietaria y con su PIN propio. */
  private async invitarCajera(): Promise<Cabeceras> {
    const celular = celularAleatorio();
    const invitacion = await this.http()
      .post('/equipo/cajeros')
      .set(this.propietaria)
      .send({ celular, nombres: 'Ana Lucía', tipoDocumento: 'CC', numeroDocumento: documento() })
      .expect(201);
    const d = dispositivo();
    const ingreso = await entrarConPin(this.servidor(), celular, invitacion.body.pinTemporal, d);
    const sesion = await this.http()
      .post('/sesion/pin-nuevo')
      .send({ tokenCambio: ingreso.body.tokenCambio, pinNuevo: '730284', dispositivo: d })
      .expect(200);
    const authorization = `Bearer ${sesion.body.tokenAcceso}`;
    await this.http()
      .post('/cuenta/comercio-activo')
      .set({ authorization })
      .send({ comercioId: this.a.comercioId })
      .expect(200);
    return { authorization, 'x-veci-comercio': this.a.comercioId };
  }
}
