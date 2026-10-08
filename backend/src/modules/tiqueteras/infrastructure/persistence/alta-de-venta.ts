import { anotarEnBitacora } from '../../../../shared/infrastructure/auditoria/prisma-auditoria';
import { ClienteTransaccion } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { NuevaVenta, ResultadoRegistro } from '../../application/puertos/ventas.repository';
import { anotarAsiento, anotarEvento } from './libro';

/**
 * La venta completa en una transacción (HU-05-02): evento SALE, venta, línea con el
 * precio cobrado, pago, tiquetera y su asiento de +N unidades, más su rastro.
 * Si el evento ya existía no escribe nada: es la misma venta que llegó otra vez.
 */
export async function registrarVenta(
  tx: ClienteTransaccion,
  v: NuevaVenta,
): Promise<ResultadoRegistro> {
  const nueva = await anotarEvento(tx, {
    id: v.ventaId,
    tipo: 'SALE',
    origen: v.origen,
    clienteId: v.clienteId,
    ocurridoEn: v.ocurridaEn,
    actorUsuarioId: v.actorUsuarioId,
    dispositivoId: v.dispositivoId,
    enSedePrincipal: true,
  });
  if (!nueva) return 'YA_EXISTIA';
  const itemId = await escribirVenta(tx, v);
  await tx.$executeRaw`
    INSERT INTO prepaid.packages (id, tenant_id, affiliation_id, package_type_id, sale_item_id,
                                  starts_at, expires_at, package_status_id)
    SELECT ${v.tiqueteraId}::uuid, core.current_tenant_id(), ${v.clienteId}::uuid,
           ${v.tipo.tipoId}::uuid, ${itemId}::uuid, ${v.ocurridaEn}, ${v.venceEn}, s.id
      FROM prepaid.package_statuses s WHERE s.code = 'ACTIVE'`;
  await anotarAsiento(tx, v.ventaId, v.tiqueteraId, v.tipo.unidades);
  await anotarEnBitacora(tx, {
    accion: 'SALE_CREATED',
    tabla: 'sales.sales',
    entidadId: v.ventaId,
    actorUsuarioId: v.actorUsuarioId,
    comercioId: null,
    dispositivoId: v.dispositivoId,
    despues: {
      tiqueteraId: v.tiqueteraId,
      precio: v.precio,
      medio: v.pago.medio,
      origen: v.origen,
    },
  });
  return 'REGISTRADA';
}

/** Venta, línea y pago. Devuelve el id de la línea, que origina la tiquetera. */
async function escribirVenta(tx: ClienteTransaccion, v: NuevaVenta): Promise<string> {
  await tx.$executeRaw`
    INSERT INTO sales.sales (event_id, tenant_id, sale_status_id)
    SELECT ${v.ventaId}::uuid, core.current_tenant_id(), s.id
      FROM sales.sale_statuses s WHERE s.code = 'COMPLETED'`;
  const [linea] = await tx.$queryRaw<{ id: string }[]>`
    INSERT INTO sales.sale_items (tenant_id, sale_id, line_number, package_type_id, quantity, unit_price)
    VALUES (core.current_tenant_id(), ${v.ventaId}::uuid, 1, ${v.tipo.tipoId}::uuid, 1, ${v.precio})
    RETURNING id::text`;
  await tx.$executeRaw`
    INSERT INTO sales.sale_payments (tenant_id, sale_id, payment_method_id, payment_channel_id,
                                     amount, reference)
    SELECT core.current_tenant_id(), ${v.ventaId}::uuid, pm.id,
           (SELECT pc.id FROM core.payment_channels pc
             WHERE pc.payment_method_id = pm.id AND pc.code = ${v.pago.canal}),
           ${v.precio}, ${v.pago.referencia}
      FROM core.payment_methods pm WHERE pm.code = ${v.pago.medio}`;
  return linea.id;
}
