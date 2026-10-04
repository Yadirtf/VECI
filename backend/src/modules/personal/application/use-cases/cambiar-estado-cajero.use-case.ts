import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { EstadoMembresia, Miembro } from '../../domain/entities/miembro';
import { MiembroNoEncontrado } from '../../domain/errors/errores-personal';
import { asegurarCupo, asegurarQueSePuedeGestionar } from '../../domain/rules/reglas-personal.rule';
import { Actor } from '../dto/personal.input';
import { PersonalRepository } from '../puertos/personal.repository';

/** Lo que el propietario puede hacer con un cajero. */
export type AccionCajero = 'SUSPENDER' | 'REACTIVAR' | 'RETIRAR';

const ESTADO_DESTINO: Record<AccionCajero, EstadoMembresia> = {
  SUSPENDER: 'SUSPENDED',
  REACTIVAR: 'ACTIVE',
  RETIRAR: 'REMOVED',
};

/**
 * Suspender, reactivar o retirar a un cajero (HU-02-04). Desde ese momento el
 * guard de comercio le niega el acceso a este negocio en la siguiente petición.
 * Las transiciones permitidas viven en la base (membership_status_transitions).
 */
export class CambiarEstadoCajero {
  constructor(
    private readonly personal: PersonalRepository,
    private readonly auditoria: Auditoria,
  ) {}

  async ejecutar(actor: Actor, membresiaId: string, accion: AccionCajero): Promise<Miembro> {
    const miembro = await this.personal.buscar(membresiaId);
    if (!miembro) throw new MiembroNoEncontrado();
    asegurarQueSePuedeGestionar(miembro, actor.usuarioId);
    const destino = ESTADO_DESTINO[accion];
    if (miembro.estado === destino) return miembro;
    if (destino === 'ACTIVE' && miembro.estado !== 'SUSPENDED') {
      throw new DatoInvalido(
        'Solo se reactiva a un cajero suspendido. A un retirado, invítalo de nuevo.',
      );
    }
    if (destino === 'ACTIVE') asegurarCupo(await this.personal.cupoDeCajeros());
    await this.personal.cambiarEstado(membresiaId, destino, actor.usuarioId);
    await this.auditoria.registrar({
      accion: 'MEMBERSHIP_CHANGED',
      tabla: 'tenancy.memberships',
      entidadId: membresiaId,
      actorUsuarioId: actor.usuarioId,
      comercioId: actor.comercioId,
      antes: { estado: miembro.estado },
      despues: { estado: destino },
    });
    return { ...miembro, estado: destino };
  }
}
