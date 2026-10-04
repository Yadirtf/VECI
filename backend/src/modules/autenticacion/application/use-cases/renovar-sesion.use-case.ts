import { GeneradorSecretos } from '../../../../shared/application/puertos/generador-secretos.port';
import { Reloj } from '../../../../shared/application/puertos/reloj.port';
import { SesionNoValida } from '../../../../shared/domain/errores/sesion-no-valida.error';
import { SesionOutput } from '../dto/sesion.output';
import { CuentasRepository } from '../puertos/cuentas.repository';
import { SesionesRepository, SesionGuardada } from '../puertos/sesiones.repository';
import { EmisorSesion } from '../servicios/emisor-sesion';

export interface DependenciasRenovar {
  sesiones: SesionesRepository;
  cuentas: CuentasRepository;
  secretos: GeneradorSecretos;
  emisor: EmisorSesion;
  reloj: Reloj;
}

/**
 * Cambia el token de renovación por uno nuevo y entrega otro token de acceso
 * (HU-02-01). Si alguien usa un token ya cambiado, la sesión se cierra entera:
 * es la señal de que lo copiaron (rotación con detección de reúso).
 */
export class RenovarSesion {
  constructor(private readonly d: DependenciasRenovar) {}

  async ejecutar(tokenRenovacion: string): Promise<SesionOutput> {
    const [sesionId, secreto] = tokenRenovacion.split('.');
    const sesion = sesionId && secreto ? await this.d.sesiones.buscar(sesionId) : null;
    if (!sesion || sesion.cerrada) throw new SesionNoValida('SESION_CERRADA');
    if (sesion.expiraEn <= this.d.reloj.ahora()) throw new SesionNoValida('SESION_VENCIDA');
    const huella = this.d.secretos.huella(secreto);
    if (huella !== sesion.huella) {
      await this.d.sesiones.cerrar(sesion.id, 'TOKEN_REUSE_DETECTED', null);
      throw new SesionNoValida('SESION_CERRADA');
    }
    return this.rotar(sesion, huella);
  }

  private async rotar(sesion: SesionGuardada, huella: string): Promise<SesionOutput> {
    const cuenta = await this.d.cuentas.buscarPorId(sesion.usuarioId);
    if (!cuenta?.puedeEntrar) throw new SesionNoValida('SESION_CERRADA');
    const secreto = this.d.secretos.token();
    const rotada = await this.d.sesiones.rotar(
      sesion.id,
      huella,
      this.d.secretos.huella(secreto),
      this.d.emisor.vencimiento(),
    );
    if (!rotada) throw new SesionNoValida('SESION_CERRADA');
    return this.d.emisor.salida(cuenta, {
      sesionId: sesion.id,
      dispositivoId: sesion.dispositivoId,
      secreto,
    });
  }
}
