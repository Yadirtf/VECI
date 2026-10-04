import { FirmadorTokens } from '../../../../shared/application/puertos/firmador-tokens.port';
import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { GeneradorSecretos } from '../../../../shared/application/puertos/generador-secretos.port';
import { Reloj } from '../../../../shared/application/puertos/reloj.port';
import { Cuenta } from '../../domain/entities/cuenta';
import { SesionOutput } from '../dto/sesion.output';
import { CuentasRepository } from '../puertos/cuentas.repository';
import { ReglasSesion, TOKEN_ACCESO } from '../puertos/reglas-sesion';
import { Dispositivo, SesionesRepository } from '../puertos/sesiones.repository';
import { ConsultarEspacios } from '../use-cases/consultar-espacios.use-case';

export interface DependenciasEmisor {
  sesiones: SesionesRepository;
  cuentas: CuentasRepository;
  espacios: ConsultarEspacios;
  firmador: FirmadorTokens;
  secretos: GeneradorSecretos;
  ids: GeneradorIds;
  reloj: Reloj;
  reglas: ReglasSesion;
}

/**
 * Abre sesiones por dispositivo (HU-02-01, HU-02-06). El token de renovación es
 * "<sesión>.<secreto>": la base guarda solo la huella del secreto.
 */
export class EmisorSesion {
  constructor(private readonly d: DependenciasEmisor) {}

  async abrir(cuenta: Cuenta, dispositivo: Dispositivo): Promise<SesionOutput> {
    await this.d.sesiones.registrarDispositivo(dispositivo);
    const sesionId = this.d.ids.siguiente();
    const secreto = this.d.secretos.token();
    await this.d.sesiones.crear({
      id: sesionId,
      usuarioId: cuenta.usuarioId,
      dispositivoId: dispositivo.id,
      huella: this.d.secretos.huella(secreto),
      expiraEn: this.vencimiento(),
    });
    await this.d.cuentas.registrarIngreso(cuenta.usuarioId);
    return this.salida(cuenta, { sesionId, dispositivoId: dispositivo.id, secreto });
  }

  /** Arma la respuesta con un token de acceso nuevo y los espacios al día. */
  async salida(
    cuenta: Cuenta,
    sesion: { sesionId: string; dispositivoId: string; secreto: string },
  ): Promise<SesionOutput> {
    const tokenAcceso = this.d.firmador.firmar(
      { typ: TOKEN_ACCESO, sub: cuenta.usuarioId, sid: sesion.sesionId, dev: sesion.dispositivoId },
      this.d.reglas.segundosAcceso,
    );
    return {
      tokenAcceso,
      tokenRenovacion: `${sesion.sesionId}.${sesion.secreto}`,
      segundosAcceso: this.d.reglas.segundosAcceso,
      usuario: { id: cuenta.usuarioId, nombre: cuenta.nombre },
      espacios: await this.d.espacios.ejecutar(cuenta.usuarioId, cuenta.personaId),
    };
  }

  /** Cada apertura o renovación da otra ventana completa: sesión persistente en uso. */
  vencimiento(): Date {
    return new Date(this.d.reloj.ahora().getTime() + this.d.reglas.diasSesion * 86_400_000);
  }
}
