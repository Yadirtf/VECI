import { PerfilComercio } from '../../domain/entities/comercio';
import {
  AltaDeComercio,
  CambiosComercio,
  ComerciosRepository,
  TipoDeNegocio,
} from '../puertos/comercios.repository';

/** Comercios en memoria para probar los casos de uso sin base de datos. */
export class ComerciosEnMemoria implements ComerciosRepository {
  readonly altas: AltaDeComercio[] = [];
  readonly cambios: CambiosComercio[] = [];
  abiertos = 0;
  perfilActual: PerfilComercio = {
    comercioId: 'c-1',
    nombre: 'La Vecina',
    slug: 'la-vecina',
    tipoNegocio: 'RESTAURANT',
    documento: { tipo: 'CC', numero: '1124500001' },
    contacto: { celular: '+573100000101', correo: null },
    logoUrl: null,
    estado: 'ONBOARDING',
    abierto: false,
    plan: null,
    avance: { serviciosConHorario: 0, cajeros: 0, tiqueteras: 0 },
  };

  async tiposDeNegocio(): Promise<TipoDeNegocio[]> {
    return [{ codigo: 'RESTAURANT', nombre: 'Restaurante', servicios: [] }];
  }

  async municipios() {
    return [{ id: 86001, nombre: 'Mocoa' }];
  }

  async registrar(alta: AltaDeComercio): Promise<string> {
    this.altas.push(alta);
    return alta.nombre.slug;
  }

  async perfil(): Promise<PerfilComercio> {
    return this.perfilActual;
  }

  async actualizar(cambios: CambiosComercio): Promise<void> {
    this.cambios.push(cambios);
  }

  async abrir(): Promise<void> {
    this.abiertos++;
    this.perfilActual = { ...this.perfilActual, abierto: true, estado: 'ACTIVE' };
  }
}
