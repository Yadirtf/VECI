import { agruparEspacios, Espacio } from '../../domain/entities/espacio';
import { CuentasRepository } from '../puertos/cuentas.repository';
import { EspaciosRepository } from '../puertos/espacios.repository';

/** Comercios donde el usuario trabaja o es cliente, con sus roles (HU-02-03). */
export class ConsultarEspacios {
  constructor(
    private readonly espacios: EspaciosRepository,
    private readonly cuentas: CuentasRepository,
  ) {}

  async ejecutar(usuarioId: string, personaId: string): Promise<Espacio[]> {
    return agruparEspacios(await this.espacios.listar(usuarioId, personaId));
  }

  async deUsuario(usuarioId: string): Promise<Espacio[]> {
    const cuenta = await this.cuentas.buscarPorId(usuarioId);
    return cuenta ? this.ejecutar(cuenta.usuarioId, cuenta.personaId) : [];
  }
}
