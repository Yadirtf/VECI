import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';
import { Actor } from '../dto/personal.input';
import { DispositivosRepository } from '../puertos/dispositivos.repository';

class DispositivoNoEncontrado extends ErrorDeDominio {
  readonly codigo = 'DISPOSITIVO_NO_ENCONTRADO';
  readonly tipo = 'no-encontrado' as const;

  constructor() {
    super('Ese dispositivo no está registrado en este negocio.');
  }
}

/**
 * Cierre remoto (HU-02-06): si se pierde el celular de la caja, el propietario
 * cierra desde el panel las sesiones de su equipo en ese celular. La próxima
 * petición del celular recibe SESION_CERRADA y la app avisa si quedó algo sin subir.
 */
export class CerrarSesionDispositivo {
  constructor(
    private readonly dispositivos: DispositivosRepository,
    private readonly auditoria: Auditoria,
  ) {}

  async ejecutar(actor: Actor, dispositivoId: string): Promise<{ sesionesCerradas: number }> {
    if (!(await this.dispositivos.existe(dispositivoId))) throw new DispositivoNoEncontrado();
    const sesionesCerradas = await this.dispositivos.cerrarSesiones(dispositivoId, actor.usuarioId);
    await this.auditoria.registrar({
      accion: 'SESSION_REVOKED',
      tabla: 'identity.sessions',
      entidadId: null,
      actorUsuarioId: actor.usuarioId,
      comercioId: actor.comercioId,
      dispositivoId,
      despues: { sesionesCerradas, motivo: 'REMOTE_LOGOUT' },
    });
    return { sesionesCerradas };
  }
}
