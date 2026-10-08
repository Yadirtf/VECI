import {
  DatosDeTipo,
  EstadoTipo,
  TipoDeTiquetera,
  UnidadDeConsumo,
} from '../../domain/entities/tipo-de-tiquetera';

/** La pizarra de tiqueteras del comercio activo (HU-05-01). Todo corre con RLS. */
export interface TiposRepository {
  /** Activos e inactivos; los archivados no se muestran. */
  listar(): Promise<TipoDeTiquetera[]>;
  buscar(tipoId: string): Promise<TipoDeTiquetera | null>;
  /** Unidades de VECI y las propias del comercio. */
  unidades(): Promise<UnidadDeConsumo[]>;
  /** Lanza NombreDeTipoRepetido si ya hay uno con ese nombre. */
  crear(tipoId: string, datos: DatosDeTipo, actorUsuarioId: string): Promise<void>;
  actualizar(tipoId: string, datos: DatosDeTipo): Promise<void>;
  cambiarEstado(tipoId: string, estado: EstadoTipo): Promise<void>;
  /** Cambia cada vez que cambia un tipo: es la ETag del catálogo de la caja. */
  versionCatalogo(): Promise<string>;
}

export const TIPOS_REPOSITORY = Symbol('TiposRepository');
