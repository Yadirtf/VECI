import { Identidad } from '../../../../shared/application/contexto/identidad';
import { SesionesRepository } from '../puertos/sesiones.repository';

/** "Salir" en este dispositivo: la sesión deja de servir de inmediato. */
export class CerrarSesion {
  constructor(private readonly sesiones: SesionesRepository) {}

  async ejecutar(identidad: Identidad): Promise<void> {
    if (!identidad.sesionId) return;
    await this.sesiones.cerrar(identidad.sesionId, 'LOGOUT', identidad.usuarioId);
  }
}
