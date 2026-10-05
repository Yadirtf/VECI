import { CuentaNoHabilitada } from '../../domain/errors/cuenta-no-habilitada.error';
import { SesionOutput } from '../dto/sesion.output';
import { CuentasRepository } from '../puertos/cuentas.repository';
import { Dispositivo } from '../puertos/sesiones.repository';
import { EmisorSesion } from '../servicios/emisor-sesion';

/**
 * Abre la primera sesión de quien acaba de crear su cuenta (HU-04-01): el cliente
 * que se registra en la app entra de una vez, sin volver a escribir celular y PIN.
 */
export class EntrarConCuentaNueva {
  constructor(
    private readonly cuentas: CuentasRepository,
    private readonly emisor: EmisorSesion,
  ) {}

  async ejecutar(usuarioId: string, dispositivo: Dispositivo): Promise<SesionOutput> {
    const cuenta = await this.cuentas.buscarPorId(usuarioId);
    if (!cuenta?.puedeEntrar) throw new CuentaNoHabilitada();
    return this.emisor.abrir(cuenta, dispositivo);
  }
}
