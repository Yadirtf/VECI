import { Cliente } from '../../domain/entities/cliente';
import { ClienteNoEncontrado } from '../../domain/errors/errores-clientes';
import { Actor, LecturaDeQr } from '../dto/clientes.dto';
import { ClientesRepository } from '../puertos/clientes.repository';
import { LectorQr } from '../servicios/lector-qr';

/**
 * La caja escanea un QR (HU-04-03). Si es el QR personal de alguien nuevo, muestra su
 * nombre y documento enmascarado para confirmar; si ya es cliente, abre su ficha.
 * Un QR cambiado no muestra el nombre: puede estar en manos de otra persona.
 */
export class LeerQrDeCliente {
  constructor(
    private readonly lector: LectorQr,
    private readonly clientes: ClientesRepository,
  ) {}

  async ejecutar(actor: Actor, texto: string): Promise<LecturaDeQr> {
    const leido = await this.lector.leer(actor.comercioId, texto);
    if (leido.tipo === 'CLIENTE') {
      return { resultado: 'CLIENTE', cliente: await fichaDe(this.clientes, leido.clienteId) };
    }
    if (leido.tipo !== 'PERSONAL') return { resultado: leido.tipo };
    const { previa } = leido;
    if (previa.clienteId) {
      return { resultado: 'CLIENTE', cliente: await fichaDe(this.clientes, previa.clienteId) };
    }
    const { personaId, nombre, documento, clienteId } = previa;
    return {
      resultado: 'PERSONA_POR_AFILIAR',
      persona: { personaId, nombre, documento, clienteId },
    };
  }
}

export async function fichaDe(clientes: ClientesRepository, clienteId: string): Promise<Cliente> {
  const cliente = await clientes.ficha(clienteId);
  if (!cliente) throw new ClienteNoEncontrado();
  return cliente;
}
