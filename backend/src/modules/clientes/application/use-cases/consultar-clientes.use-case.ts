import { EmitirPinTemporal } from '../../../autenticacion';
import { Cliente } from '../../domain/entities/cliente';
import {
  ClienteNoEncontrado,
  SinCuentaPropia,
  YaActivoSuApp,
} from '../../domain/errors/errores-clientes';
import { leerConsulta } from '../../domain/rules/consulta-de-clientes.rule';
import { Actor } from '../dto/clientes.dto';
import { ClientesRepository, CopiaLocal } from '../puertos/clientes.repository';
import { fichaDe } from './leer-qr.use-case';

/**
 * Buscar clientes del negocio (HU-04-05): por nombre, celular o documento desde 3
 * caracteres. La caja además baja una copia local para buscar sin internet.
 */
export class ConsultarClientes {
  constructor(private readonly clientes: ClientesRepository) {}

  async buscar(texto: string): Promise<Cliente[]> {
    return this.clientes.buscar(leerConsulta(texto));
  }

  ficha(clienteId: string): Promise<Cliente> {
    return fichaDe(this.clientes, clienteId);
  }

  /** Cambia cuando se afilia alguien o cambia una afiliación: la caja la compara antes de bajar. */
  versionDeCopia(): Promise<string> {
    return this.clientes.versionDeCopia();
  }

  copiaLocal(): Promise<CopiaLocal> {
    return this.clientes.copiaLocal();
  }
}

/**
 * Un PIN de bienvenida nuevo para quien registraron en la caja y aún no activa su app
 * (HU-04-04): el anterior deja de servir. A quien ya tiene su PIN propio no se le toca.
 */
export class DarPinDeBienvenida {
  constructor(
    private readonly clientes: ClientesRepository,
    private readonly pinTemporal: EmitirPinTemporal,
  ) {}

  async ejecutar(actor: Actor, clienteId: string): Promise<{ pinBienvenida: string }> {
    const usuario = await this.clientes.usuarioDe(clienteId);
    if (!usuario) throw new ClienteNoEncontrado();
    if (usuario.cuenta === 'ACTIVA') throw new YaActivoSuApp();
    if (!usuario.usuarioId) throw new SinCuentaPropia();
    const pinBienvenida = await this.pinTemporal.ejecutar({
      usuarioId: usuario.usuarioId,
      motivo: 'INVITACION',
      porUsuarioId: actor.usuarioId,
      comercioId: actor.comercioId,
    });
    return { pinBienvenida };
  }
}
