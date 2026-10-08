import { randomUUID } from 'node:crypto';
import { Cabeceras, NegociosConClientes } from './clientes';

export const PIZARRA = {
  nombre: '20 almuerzos',
  unidad: 'LUNCH',
  unidades: 20,
  precio: 220000,
  vigenciaDias: 30,
};

/** Escenario de EP-05: los negocios de EP-04 con clientes afiliados y su pizarra. */
export class NegociosConTiqueteras extends NegociosConClientes {
  /** Una vecina registrada que la cajera afilia con su QR. */
  async clienteAfiliado(nombres = 'Luz Marina') {
    const vecina = await this.registrarse(nombres, 'Chindoy');
    const qr = await this.http().get('/mi-qr').set(vecina.sesion).expect(200);
    const afiliacion = await this.http()
      .post('/clientes/afiliaciones')
      .set(this.cajera)
      .send({ token: qr.body.token })
      .expect(200);
    return { clienteId: afiliacion.body.cliente.clienteId as string, sesion: vecina.sesion };
  }

  async crearTipo(datos: Partial<typeof PIZARRA> = {}, quien: Cabeceras = this.propietaria) {
    const nombre = `${PIZARRA.nombre} ${randomUUID().slice(0, 6)}`;
    const tipo = await this.http()
      .post('/tiqueteras/tipos')
      .set(quien)
      .send({ ...PIZARRA, nombre, ...datos })
      .expect(201);
    return tipo.body as { tipoId: string; precio: number };
  }

  vender(cuerpo: Record<string, unknown>, quien: Cabeceras = this.cajera) {
    return this.http()
      .post('/ventas')
      .set(quien)
      .send({ ventaId: randomUUID(), precio: PIZARRA.precio, pago: { medio: 'CASH' }, ...cuerpo });
  }

  saldo(clienteId: string, quien: Cabeceras = this.cajera) {
    return this.http().get(`/tiqueteras/cliente/${clienteId}`).set(quien);
  }

  async auditado(accion: string): Promise<number> {
    const r = await this.dueno.query(
      `SELECT count(*)::int AS n FROM audit.audit_log l JOIN audit.actions x ON x.id = l.action_id
        WHERE l.tenant_id = $1 AND x.code = $2`,
      [this.a.comercioId, accion],
    );
    return r.rows[0].n;
  }

  /** Corre el reloj de una tiquetera hacia atrás, como si la hubieran comprado antes. */
  async envejecer(tiqueteraId: string): Promise<void> {
    await this.dueno.query('BEGIN');
    await this.dueno.query(`SELECT set_config('app.tenant_id', $1, true)`, [this.a.comercioId]);
    await this.dueno.query(
      `UPDATE prepaid.packages SET starts_at = now() - interval '31 days', expires_at = now() - interval '1 minute'
        WHERE id = $1`,
      [tiqueteraId],
    );
    await this.dueno.query('COMMIT');
  }
}
