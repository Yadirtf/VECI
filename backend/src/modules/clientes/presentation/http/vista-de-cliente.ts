import { VerificadorMembresia } from '../../../../shared/application/contexto/verificador-membresia.port';
import { Actor } from '../../application/dto/clientes.dto';
import { Cliente } from '../../domain/entities/cliente';
import {
  enmascararCelular,
  enmascararDocumento,
  nombreCompleto,
  plegar,
} from '../../domain/rules/enmascarar.rule';
import { ClienteEnCajaResponse, ClienteResponse } from './clientes.response';

/** Permiso que deja ver documento y celular completos (solo el propietario, HU-04-03). */
export const VER_DOCUMENTO_COMPLETO = 'customers.view_full_document';

/** El propietario ve documento y celular completos; el cajero, enmascarados. */
export async function verCompleto(
  membresias: VerificadorMembresia,
  actor: Actor,
): Promise<boolean> {
  const permisos = await membresias.permisosEn(actor.usuarioId, actor.comercioId);
  return permisos.has(VER_DOCUMENTO_COMPLETO);
}

/** Ficha con el documento y el celular enmascarados salvo que quien mira tenga el permiso. */
export function aClienteResponse(cliente: Cliente, completo: boolean): ClienteResponse {
  return {
    clienteId: cliente.clienteId,
    personaId: cliente.personaId,
    nombre: nombreCompleto(cliente.nombres, cliente.apellidos),
    nombres: cliente.nombres,
    apellidos: cliente.apellidos,
    tipoDocumento: cliente.tipoDocumento,
    documento: completo ? cliente.numeroDocumento : enmascararDocumento(cliente.numeroDocumento),
    celular: cliente.celular && (completo ? cliente.celular : enmascararCelular(cliente.celular)),
    datosCompletos: completo,
    cuenta: cliente.cuenta,
    estado: cliente.estado,
    canal: cliente.canal,
    afiliadoEn: cliente.afiliadoEn,
  };
}

/**
 * Lo que baja al celular de la caja: nunca el documento ni el celular completos,
 * solo sus últimos 4 dígitos para buscar sin internet (ADR-0017).
 */
export function aClienteEnCaja(cliente: Cliente): ClienteEnCajaResponse {
  const nombre = nombreCompleto(cliente.nombres, cliente.apellidos);
  return {
    clienteId: cliente.clienteId,
    nombre,
    nombreBusqueda: plegar(nombre),
    documento: enmascararDocumento(cliente.numeroDocumento),
    documentoFinal: cliente.numeroDocumento.slice(-4),
    celular: cliente.celular && enmascararCelular(cliente.celular),
    celularFinal: cliente.celular?.slice(-4) ?? null,
    cuenta: cliente.cuenta,
    estado: cliente.estado,
  };
}
