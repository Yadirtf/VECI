import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { DatosDeTipo, TipoDeTiquetera } from '../../domain/entities/tipo-de-tiquetera';
import { CantidadYaVendida, TipoNoEncontrado } from '../../domain/errors/errores-tiqueteras';
import { precioPorUnidad, validarTipo } from '../../domain/rules/reglas-tipo.rule';
import { Actor, CatalogoDeVenta, TipoOutput } from '../dto/tiqueteras.dto';
import { TiposRepository } from '../puertos/tipos.repository';
import { VentasRepository } from '../puertos/ventas.repository';

export function aTipoOutput(tipo: TipoDeTiquetera): TipoOutput {
  return { ...tipo, precioPorUnidad: precioPorUnidad(tipo.precio, tipo.unidades) };
}

/**
 * La pizarra de tiqueteras (HU-05-01): el propietario crea, cambia, guarda y vuelve
 * a sacar los paquetes que vende. Guardar uno no toca lo que ya vendió.
 */
export class GestionarTipos {
  constructor(
    private readonly tipos: TiposRepository,
    private readonly ids: GeneradorIds,
  ) {}

  async listar(): Promise<TipoOutput[]> {
    return (await this.tipos.listar()).map(aTipoOutput);
  }

  unidades() {
    return this.tipos.unidades();
  }

  async crear(actor: Actor, datos: DatosDeTipo): Promise<TipoOutput> {
    const limpios = await this.revisar(datos);
    const tipoId = this.ids.siguiente();
    await this.tipos.crear(tipoId, limpios, actor.usuarioId);
    return this.uno(tipoId);
  }

  async editar(tipoId: string, datos: DatosDeTipo): Promise<TipoOutput> {
    const actual = await this.existente(tipoId);
    const limpios = await this.revisar(datos);
    const cambiaCantidad =
      limpios.unidades !== actual.unidades || limpios.unidad !== actual.unidad.codigo;
    // El dinero comprometido se calcula con la cantidad del tipo (v_committed_liability).
    if (actual.vendidas > 0 && cambiaCantidad) throw new CantidadYaVendida();
    await this.tipos.actualizar(tipoId, limpios);
    return this.uno(tipoId);
  }

  async cambiarEstado(tipoId: string, activo: boolean): Promise<TipoOutput> {
    const actual = await this.existente(tipoId);
    const estado = activo ? 'ACTIVE' : 'INACTIVE';
    if (actual.estado !== estado) await this.tipos.cambiarEstado(tipoId, estado);
    return this.uno(tipoId);
  }

  private async revisar(datos: DatosDeTipo): Promise<DatosDeTipo> {
    const limpios = validarTipo(datos);
    const unidades = await this.tipos.unidades();
    if (!unidades.some((u) => u.codigo === limpios.unidad)) {
      throw new DatoInvalido('Elige la unidad de la lista: almuerzo, desayuno, café…');
    }
    return limpios;
  }

  private async existente(tipoId: string): Promise<TipoDeTiquetera> {
    const tipo = await this.tipos.buscar(tipoId);
    if (!tipo || tipo.estado === 'ARCHIVED') throw new TipoNoEncontrado();
    return tipo;
  }

  private async uno(tipoId: string): Promise<TipoOutput> {
    return aTipoOutput(await this.existente(tipoId));
  }
}

/** Lo que baja la caja para vender, también sin internet (HU-05-02). */
export class ConsultarCatalogoDeVenta {
  constructor(
    private readonly tipos: TiposRepository,
    private readonly ventas: VentasRepository,
  ) {}

  version(): Promise<string> {
    return this.tipos.versionCatalogo();
  }

  async catalogo(): Promise<CatalogoDeVenta> {
    const [version, tipos, contexto] = await Promise.all([
      this.tipos.versionCatalogo(),
      this.tipos.listar(),
      this.ventas.contexto(),
    ]);
    return {
      version,
      tipos: tipos.filter((t) => t.estado === 'ACTIVE').map(aTipoOutput),
      medios: contexto.medios,
    };
  }
}
