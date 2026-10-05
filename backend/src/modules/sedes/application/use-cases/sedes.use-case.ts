import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { CajeroEnSedes, CupoDeSedes, Sede } from '../../domain/entities/sede';
import { CambioDeSedeNoPermitido, SedeNoEncontrada } from '../../domain/errors/errores-sedes';
import {
  asegurarCupoDeSedes,
  asegurarQueSePuedeDesactivar,
  nombreDeSede,
} from '../../domain/rules/reglas-sedes.rule';
import { CambiosSede, DatosSede, SedesRepository } from '../puertos/sedes.repository';

export interface MapaDeSedes {
  sedes: Sede[];
  cajeros: CajeroEnSedes[];
  cupo: CupoDeSedes;
}

/** Sedes del negocio y cajeros por sede (HU-03-03). */
export class GestionarSedes {
  constructor(
    private readonly sedes: SedesRepository,
    private readonly ids: GeneradorIds,
  ) {}

  async mapa(): Promise<MapaDeSedes> {
    const [sedes, cajeros, cupo] = await Promise.all([
      this.sedes.listar(),
      this.sedes.cajeros(),
      this.sedes.cupo(),
    ]);
    return { sedes, cajeros, cupo };
  }

  async crear(datos: DatosSede): Promise<Sede> {
    asegurarCupoDeSedes(await this.sedes.cupo());
    const sedeId = this.ids.siguiente();
    await this.sedes.crear(sedeId, { ...datos, nombre: nombreDeSede(datos.nombre) });
    return this.existente(sedeId);
  }

  async editar(sedeId: string, cambios: CambiosSede): Promise<Sede> {
    const sede = await this.existente(sedeId);
    if (cambios.activa === false) asegurarQueSePuedeDesactivar(sede);
    if (cambios.activa === true && !sede.activa) asegurarCupoDeSedes(await this.sedes.cupo());
    const nombre = cambios.nombre !== undefined ? nombreDeSede(cambios.nombre) : undefined;
    await this.sedes.actualizar(sedeId, { ...cambios, nombre });
    return this.existente(sedeId);
  }

  /** Sin sedes = trabaja en todas. Solo a sedes activas y solo a cajeros. */
  async asignar(membresiaId: string, sedeIds: string[], porUsuarioId: string): Promise<void> {
    if (!(await this.sedes.esCajero(membresiaId))) {
      throw new CambioDeSedeNoPermitido('Solo los cajeros se asignan a sedes.');
    }
    const activas = new Set(
      (await this.sedes.listar()).filter((s) => s.activa).map((s) => s.sedeId),
    );
    if (sedeIds.some((id) => !activas.has(id))) throw new SedeNoEncontrada();
    await this.sedes.asignar(membresiaId, [...new Set(sedeIds)], porUsuarioId);
  }

  private async existente(sedeId: string): Promise<Sede> {
    const sede = await this.sedes.buscar(sedeId);
    if (!sede) throw new SedeNoEncontrada();
    return sede;
  }
}
