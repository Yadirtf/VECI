import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { CifradorSecretos } from '../../../../shared/application/puertos/cifrador-secretos.port';
import { Reloj } from '../../../../shared/application/puertos/reloj.port';
import { Credencial } from '../../domain/entities/credencial.entity';
import { CredencialesIncorrectas } from '../../domain/errors/credenciales-incorrectas.error';
import { CuentaBloqueada } from '../../domain/errors/cuenta-bloqueada.error';
import { CredencialesRepository } from '../puertos/credenciales.repository';
import { IntentoIngreso, IntentosIngreso } from '../puertos/intentos-ingreso.port';

export interface DependenciasComprobador {
  credenciales: CredencialesRepository;
  cifrador: CifradorSecretos;
  intentos: IntentosIngreso;
  auditoria: Auditoria;
  reloj: Reloj;
}

/** Datos del intento, sin el resultado (lo decide el comprobador). */
export type DatosIntento = Omit<IntentoIngreso, 'motivoFallo'>;

/**
 * Compara un PIN o contraseña con su hash y aplica el bloqueo (HU-02-01):
 * al quinto fallo la entrada se pausa y el bloqueo queda en auditoría.
 * Registra los fallos; el éxito lo registra quien termina de decidir el ingreso.
 */
export class ComprobadorCredencial {
  constructor(private readonly d: DependenciasComprobador) {}

  async comprobar(
    credencial: Credencial,
    secreto: string,
    intento: DatosIntento,
    mensajeFallo?: string,
  ): Promise<void> {
    const ahora = this.d.reloj.ahora();
    if (credencial.estaBloqueada(ahora)) {
      await this.d.intentos.registrar({ ...intento, motivoFallo: 'CREDENTIAL_LOCKED' });
      throw new CuentaBloqueada(credencial.minutosRestantes(ahora));
    }
    if (await this.d.cifrador.coincide(credencial.hash, secreto)) {
      if (credencial.intentosFallidos > 0 || credencial.bloqueadaHasta) {
        credencial.registrarExito();
        await this.d.credenciales.guardarIntentos(credencial);
      }
      return;
    }
    await this.registrarFallo(credencial, intento, ahora);
    throw new CredencialesIncorrectas(mensajeFallo);
  }

  private async registrarFallo(
    credencial: Credencial,
    intento: DatosIntento,
    ahora: Date,
  ): Promise<void> {
    const seBloqueo = credencial.registrarFallo(ahora);
    await this.d.credenciales.guardarIntentos(credencial);
    await this.d.intentos.registrar({ ...intento, motivoFallo: 'WRONG_SECRET' });
    if (!seBloqueo) return;
    await this.d.auditoria.registrar({
      accion: 'LOGIN_LOCKED',
      tabla: 'identity.user_credentials',
      entidadId: credencial.id,
      actorUsuarioId: credencial.usuarioId,
      comercioId: null,
      dispositivoId: intento.dispositivoId,
      despues: { tipo: credencial.tipo, bloqueadaHasta: credencial.bloqueadaHasta?.toISOString() },
    });
    throw new CuentaBloqueada(credencial.minutosRestantes(ahora));
  }
}
