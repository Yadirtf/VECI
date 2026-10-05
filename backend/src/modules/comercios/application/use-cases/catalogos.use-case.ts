import { ComerciosRepository, Municipio, TipoDeNegocio } from '../puertos/comercios.repository';

/** Catálogos para registrar un negocio: tipos (con servicios sugeridos) y municipios. */
export class CatalogosDeComercio {
  constructor(private readonly comercios: ComerciosRepository) {}

  tiposDeNegocio(): Promise<TipoDeNegocio[]> {
    return this.comercios.tiposDeNegocio();
  }

  municipios(): Promise<Municipio[]> {
    return this.comercios.municipios();
  }
}
