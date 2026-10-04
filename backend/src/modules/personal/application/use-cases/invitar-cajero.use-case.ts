import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { Celular, EmitirPinTemporal } from '../../../autenticacion';
import { CelularNoCoincide, YaEsDelEquipo } from '../../domain/errors/errores-personal';
import { asegurarCupo } from '../../domain/rules/reglas-personal.rule';
import { Actor, InvitacionOutput, InvitarCajeroInput } from '../dto/personal.input';
import { Invitacion, PersonalRepository } from '../puertos/personal.repository';

export interface DependenciasInvitar {
  personal: PersonalRepository;
  pinTemporal: EmitirPinTemporal;
  auditoria: Auditoria;
}

/**
 * Invita a un cajero por su celular (HU-02-04). Si la persona no tiene cuenta, se
 * crea con sus datos; si fue cajera antes y la retiraron, se reinvita. VECI da un
 * PIN temporal que el propietario le entrega: al entrar, ella crea el suyo.
 */
export class InvitarCajero {
  constructor(private readonly d: DependenciasInvitar) {}

  async ejecutar(actor: Actor, entrada: InvitarCajeroInput): Promise<InvitacionOutput> {
    const persona = { ...entrada, celular: Celular.de(entrada.celular).valor };
    asegurarCupo(await this.d.personal.cupoDeCajeros());
    const { invitacion, necesitaPin } = await this.planear(actor, persona);
    const { membresiaId, usuarioId } = await this.d.personal.invitar(invitacion);
    await this.auditar(actor, membresiaId, usuarioId);
    const pinTemporal = necesitaPin
      ? await this.d.pinTemporal.ejecutar({
          usuarioId,
          motivo: 'INVITACION',
          porUsuarioId: actor.usuarioId,
          comercioId: actor.comercioId,
        })
      : null;
    return { membresiaId, pinTemporal };
  }

  private async planear(
    actor: Actor,
    persona: InvitarCajeroInput,
  ): Promise<{ invitacion: Invitacion; necesitaPin: boolean }> {
    const base = { persona, invitadoPor: actor.usuarioId, membresiaRetirada: null };
    const existente = await this.d.personal.buscarUsuarioPorCelular(persona.celular);
    if (existente) {
      const membresia = await this.d.personal.membresiaDe(existente.usuarioId);
      if (membresia && membresia.estado !== 'REMOVED') throw new YaEsDelEquipo();
      const membresiaRetirada = membresia?.membresiaId ?? null;
      return {
        invitacion: {
          ...base,
          usuarioId: existente.usuarioId,
          personaExistenteId: null,
          membresiaRetirada,
        },
        necesitaPin: !existente.tienePinPropio,
      };
    }
    const porDocumento = await this.d.personal.buscarPorDocumento(
      persona.tipoDocumento,
      persona.numeroDocumento,
    );
    if (porDocumento?.usuarioId) throw new CelularNoCoincide();
    const personaExistenteId = porDocumento?.personaId ?? null;
    return { invitacion: { ...base, usuarioId: null, personaExistenteId }, necesitaPin: true };
  }

  private async auditar(actor: Actor, membresiaId: string, usuarioId: string): Promise<void> {
    const comun = {
      tabla: 'tenancy.memberships',
      entidadId: membresiaId,
      actorUsuarioId: actor.usuarioId,
      comercioId: actor.comercioId,
    };
    await this.d.auditoria.registrar({
      ...comun,
      accion: 'MEMBERSHIP_CHANGED',
      despues: { estado: 'INVITED', usuarioId },
    });
    await this.d.auditoria.registrar({
      ...comun,
      accion: 'ROLE_GRANTED',
      despues: { rol: 'CASHIER', usuarioId },
    });
  }
}
