import { EmitirPinTemporal } from '../../../autenticacion';
import { MiembroNoEncontrado } from '../../domain/errors/errores-personal';
import { asegurarQueSePuedeGestionar } from '../../domain/rules/reglas-personal.rule';
import { Actor } from '../dto/personal.input';
import { PersonalRepository } from '../puertos/personal.repository';

/**
 * El propietario restablece el PIN de un cajero desde el panel (HU-02-05): sale un
 * PIN temporal, se cierran las sesiones del cajero y queda en auditoría.
 */
export class RestablecerPinCajero {
  constructor(
    private readonly personal: PersonalRepository,
    private readonly pinTemporal: EmitirPinTemporal,
  ) {}

  async ejecutar(actor: Actor, membresiaId: string): Promise<{ pinTemporal: string }> {
    const miembro = await this.personal.buscar(membresiaId);
    if (!miembro || miembro.estado === 'REMOVED') throw new MiembroNoEncontrado();
    asegurarQueSePuedeGestionar(miembro, actor.usuarioId);
    const pinTemporal = await this.pinTemporal.ejecutar({
      usuarioId: miembro.usuarioId,
      motivo: 'RESET_BY_OWNER',
      porUsuarioId: actor.usuarioId,
      comercioId: actor.comercioId,
    });
    return { pinTemporal };
  }
}
