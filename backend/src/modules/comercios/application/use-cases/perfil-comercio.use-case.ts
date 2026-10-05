import { Celular, Correo } from '../../../autenticacion';
import {
  asegurarListoParaAbrir,
  caminoDeApertura,
} from '../../domain/rules/camino-de-apertura.rule';
import { NegocioYaAbierto, TipoDeNegocioDesconocido } from '../../domain/errors/errores-comercios';
import { Logo } from '../../domain/value-objects/logo.vo';
import { NombreNegocio } from '../../domain/value-objects/nombre-negocio.vo';
import { EditarComercioInput, PerfilOutput } from '../dto/comercios.dto';
import { CambiosComercio, ComerciosRepository } from '../puertos/comercios.repository';

/** El negocio activo: sus datos, su plan y el camino que le falta para abrir. */
export class PerfilDelComercio {
  constructor(private readonly comercios: ComerciosRepository) {}

  async consultar(): Promise<PerfilOutput> {
    const perfil = await this.comercios.perfil();
    const camino = caminoDeApertura(perfil.avance);
    const puedeAbrir = !perfil.abierto && camino.every((p) => p.listo || !p.obligatorio);
    return { ...perfil, camino, puedeAbrir };
  }

  async editar(entrada: EditarComercioInput): Promise<PerfilOutput> {
    await this.comercios.actualizar(await this.cambios(entrada));
    return this.consultar();
  }

  /** Abre las puertas: el negocio empieza a vender y a registrar consumos. */
  async abrir(): Promise<PerfilOutput> {
    const perfil = await this.comercios.perfil();
    if (perfil.abierto) throw new NegocioYaAbierto();
    asegurarListoParaAbrir(perfil.avance);
    await this.comercios.abrir();
    return this.consultar();
  }

  private async cambios(e: EditarComercioInput): Promise<CambiosComercio> {
    if (e.tipoNegocio !== undefined) {
      const tipos = await this.comercios.tiposDeNegocio();
      if (!tipos.some((t) => t.codigo === e.tipoNegocio)) throw new TipoDeNegocioDesconocido();
    }
    return {
      nombre: e.nombre !== undefined ? NombreNegocio.de(e.nombre) : undefined,
      tipoNegocio: e.tipoNegocio,
      celular: e.celular !== undefined ? Celular.de(e.celular).valor : undefined,
      correo: e.correo === undefined ? undefined : e.correo ? Correo.de(e.correo).valor : null,
      logoUrl: e.logoUrl === undefined ? undefined : e.logoUrl ? Logo.de(e.logoUrl).url : null,
    };
  }
}
