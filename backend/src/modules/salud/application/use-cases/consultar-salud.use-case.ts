import { SondaBaseDatos } from '../puertos/sonda-base-datos.port';

export interface EstadoSalud {
  estado: 'ok' | 'degradado';
  baseDatos: 'ok' | 'sin-conexion';
  version: string;
}

/** Estado de la API para el balanceador, el despliegue y la alerta de caída (HU-01-07). */
export class ConsultarSalud {
  constructor(
    private readonly sonda: SondaBaseDatos,
    private readonly version: string,
  ) {}

  async ejecutar(): Promise<EstadoSalud> {
    const baseDatosOk = await this.sonda.responde().catch(() => false);
    return {
      estado: baseDatosOk ? 'ok' : 'degradado',
      baseDatos: baseDatosOk ? 'ok' : 'sin-conexion',
      version: this.version,
    };
  }
}
