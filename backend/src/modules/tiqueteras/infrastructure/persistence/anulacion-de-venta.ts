import { anotarEnBitacora } from '../../../../shared/infrastructure/auditoria/prisma-auditoria';
import { ClienteTransaccion } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { EstadoTiquetera } from '../../domain/entities/tiquetera';
import { VentaNoEncontrada, VentaYaAnulada } from '../../domain/errors/errores-tiqueteras';
import { Anulacion } from '../../application/puertos/ventas.repository';
import { anotarAsiento, anotarEvento, cambiarEstadoTiquetera } from './libro';

interface VentaBloqueada {
  estado: 'COMPLETED' | 'VOIDED';
  cliente_id: string;
  tiquetera_id: string;
  estado_tiquetera: EstadoTiquetera;
  saldo: number;
}

/**
 * Anula una venta (HU-05-05) con la venta y su tiquetera bloqueadas: la venta pasa a
 * anulada, la tiquetera también (si aún servía) y un evento SALE_VOID que apunta a la
 * venta quita lo que quedaba. El índice de reversos impide anular dos veces.
 */
export async function anularVenta(tx: ClienteTransaccion, a: Anulacion): Promise<void> {
  const [venta] = await tx.$queryRaw<VentaBloqueada[]>`
    SELECT ss.code AS estado, e.affiliation_id::text AS cliente_id, p.id::text AS tiquetera_id,
           ps.code AS estado_tiquetera, p.units_balance AS saldo
      FROM sales.sales s
      JOIN sales.sale_statuses ss ON ss.id = s.sale_status_id
      JOIN ledger.events e ON e.id = s.event_id
      JOIN sales.sale_items si ON si.sale_id = s.event_id AND si.line_number = 1
      JOIN prepaid.packages p ON p.sale_item_id = si.id
      JOIN prepaid.package_statuses ps ON ps.id = p.package_status_id
     WHERE s.event_id = ${a.ventaId}::uuid
       FOR UPDATE OF s, p`;
  if (!venta) throw new VentaNoEncontrada();
  if (venta.estado === 'VOIDED') throw new VentaYaAnulada();
  await tx.$executeRaw`
    UPDATE sales.sales
       SET sale_status_id = (SELECT id FROM sales.sale_statuses WHERE code = 'VOIDED'),
           status_changed_at = now()
     WHERE event_id = ${a.ventaId}::uuid`;
  const servia = venta.estado_tiquetera === 'ACTIVE' || venta.estado_tiquetera === 'DEPLETED';
  if (servia) await cambiarEstadoTiquetera(tx, venta.tiquetera_id, 'VOIDED');
  await anotarEvento(tx, {
    id: a.anulacionId,
    tipo: 'SALE_VOID',
    origen: 'ONLINE',
    clienteId: venta.cliente_id,
    ocurridoEn: new Date(),
    actorUsuarioId: a.actorUsuarioId,
    dispositivoId: a.dispositivoId,
    corrigeA: a.ventaId,
    motivo: a.motivo.codigo,
    nota: a.motivo.nota,
  });
  if (servia && venta.saldo > 0) {
    await anotarAsiento(tx, a.anulacionId, venta.tiquetera_id, -venta.saldo);
  }
  await anotarEnBitacora(tx, {
    accion: 'SALE_VOIDED',
    tabla: 'sales.sales',
    entidadId: a.ventaId,
    actorUsuarioId: a.actorUsuarioId,
    comercioId: null,
    dispositivoId: a.dispositivoId,
    antes: { estado: 'COMPLETED', saldo: venta.saldo, tiquetera: venta.estado_tiquetera },
    despues: { estado: 'VOIDED', motivo: a.motivo.codigo, nota: a.motivo.nota },
  });
}
