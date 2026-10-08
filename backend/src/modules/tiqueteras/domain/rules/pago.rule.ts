import { MedioDePago, Pago } from '../entities/venta';
import { PagoInvalido } from '../errors/errores-tiqueteras';

const LARGO_REFERENCIA = 60;

/**
 * Revisa el pago contra el catálogo de medios (HU-05-02): efectivo sin canal, o
 * transferencia por Nequi, Daviplata o Bancolombia con una referencia opcional.
 * Los medios y canales viven en datos (core.payment_methods, ADR-0006).
 */
export function validarPago(pago: Pago, catalogo: readonly MedioDePago[]): Pago {
  const medio = catalogo.find((m) => m.codigo === pago.medio);
  if (!medio) throw new PagoInvalido('Ese medio de pago no se recibe en VECI.');
  if (!medio.necesitaCanal) {
    if (pago.canal) throw new PagoInvalido(`${medio.nombre} no lleva canal.`);
    return { medio: medio.codigo, canal: null, referencia: null };
  }
  const canal = medio.canales.find((c) => c.codigo === pago.canal);
  if (!canal) {
    const opciones = medio.canales.map((c) => c.nombre).join(', ');
    throw new PagoInvalido(`Dinos por dónde llegó la transferencia: ${opciones}.`);
  }
  const referencia = pago.referencia?.trim() || null;
  if (referencia && referencia.length > LARGO_REFERENCIA) {
    throw new PagoInvalido(`La referencia es muy larga (máximo ${LARGO_REFERENCIA}).`);
  }
  return { medio: medio.codigo, canal: canal.codigo, referencia };
}
