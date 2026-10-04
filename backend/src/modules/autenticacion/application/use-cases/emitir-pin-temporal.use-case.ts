import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { CifradorSecretos } from '../../../../shared/application/puertos/cifrador-secretos.port';
import { GeneradorSecretos } from '../../../../shared/application/puertos/generador-secretos.port';
import { esPinFacilDeAdivinar } from '../../domain/rules/pin-facil-de-adivinar.rule';
import { CredencialesRepository } from '../puertos/credenciales.repository';
import { SesionesRepository } from '../puertos/sesiones.repository';

export interface DependenciasPinTemporal {
  credenciales: CredencialesRepository;
  sesiones: SesionesRepository;
  cifrador: CifradorSecretos;
  secretos: GeneradorSecretos;
  auditoria: Auditoria;
}

/** Para qué se entrega el PIN temporal. */
export type MotivoPinTemporal = 'INVITACION' | 'RESET_BY_OWNER' | 'RESET_BY_SUPPORT';

export interface PinTemporalInput {
  usuarioId: string;
  motivo: MotivoPinTemporal;
  porUsuarioId: string;
  /** Comercio desde donde se hizo (propietario); null si fue soporte VECI. */
  comercioId: string | null;
}

/**
 * Un solo mecanismo para invitar cajeros y restablecer PIN (HU-02-04, HU-02-05):
 * VECI genera 6 dígitos que se muestran una vez a quien los entrega. Al entrar
 * con ellos, la persona debe crear su PIN propio. Un restablecimiento cierra las
 * sesiones abiertas y queda en auditoría.
 */
export class EmitirPinTemporal {
  constructor(private readonly d: DependenciasPinTemporal) {}

  async ejecutar(entrada: PinTemporalInput): Promise<string> {
    const pin = this.generar();
    const esRestablecimiento = entrada.motivo !== 'INVITACION';
    const credencialId = await this.d.credenciales.reemplazar({
      usuarioId: entrada.usuarioId,
      tipo: 'PIN',
      hash: await this.d.cifrador.cifrar(pin),
      debeCambiar: true,
      motivo: entrada.motivo === 'RESET_BY_SUPPORT' ? 'RESET_BY_SUPPORT' : 'RESET_BY_OWNER',
      creadaPor: entrada.porUsuarioId,
    });
    if (esRestablecimiento) await this.registrarRestablecimiento(entrada, credencialId);
    return pin;
  }

  private generar(): string {
    let pin = this.d.secretos.digitos();
    while (esPinFacilDeAdivinar(pin)) pin = this.d.secretos.digitos();
    return pin;
  }

  private async registrarRestablecimiento(
    entrada: PinTemporalInput,
    credencialId: string,
  ): Promise<void> {
    await this.d.sesiones.cerrarTodasDe(
      entrada.usuarioId,
      'CREDENTIAL_RESET',
      entrada.porUsuarioId,
    );
    await this.d.auditoria.registrar({
      accion: 'PIN_RESET',
      tabla: 'identity.user_credentials',
      entidadId: credencialId,
      actorUsuarioId: entrada.porUsuarioId,
      comercioId: entrada.comercioId,
      despues: { usuarioId: entrada.usuarioId, motivo: entrada.motivo },
    });
  }
}
