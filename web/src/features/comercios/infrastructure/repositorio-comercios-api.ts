import { CABECERA_COMERCIO } from '@/shared/api/cabeceras';
import type { ClienteVeci, components } from '@/shared/api/cliente';
import { leerProblema } from '@/shared/api/problema';
import type {
  CambiosPerfil,
  CodigoPaso,
  DatosAlta,
  Municipio,
  Perfil,
  RepositorioComercios,
  TipoDeNegocio,
} from '../domain/comercio';

type PerfilApi = components['schemas']['PerfilComercioResponse'];

const falla = (error: unknown) => new Error(leerProblema(error).mensaje);

const aPerfil = (p: PerfilApi): Perfil => ({
  comercioId: p.comercioId,
  nombre: p.nombre,
  slug: p.slug,
  tipoNegocio: p.tipoNegocio,
  documento: p.documento,
  celular: p.contacto.celular ?? null,
  correo: p.contacto.correo ?? null,
  logoUrl: p.logoUrl ?? null,
  abierto: p.abierto,
  plan: p.plan ? { nombre: p.plan.nombre, codigo: p.plan.codigo, venceEl: p.plan.venceEl } : null,
  camino: p.camino.map((paso) => ({ ...paso, codigo: paso.codigo as CodigoPaso })),
  puedeAbrir: p.puedeAbrir,
});

/** Comercios con el cliente generado desde OpenAPI. */
export class RepositorioComerciosApi implements RepositorioComercios {
  constructor(
    private readonly cliente: ClienteVeci,
    private readonly comercioId: string | null = null,
  ) {}

  private get cabecera() {
    if (!this.comercioId) throw new Error('Primero elige un negocio, veci.');
    return { header: { [CABECERA_COMERCIO]: this.comercioId } };
  }

  async tipos(): Promise<TipoDeNegocio[]> {
    const { data, error } = await this.cliente.GET('/comercios/tipos');
    if (!data) throw falla(error);
    return data;
  }

  async municipios(): Promise<Municipio[]> {
    const { data, error } = await this.cliente.GET('/comercios/municipios');
    if (!data) throw falla(error);
    return data;
  }

  async registrar(datos: DatosAlta): Promise<{ comercioId: string }> {
    const { data, error } = await this.cliente.POST('/comercios', { body: datos });
    if (!data) throw falla(error);
    return { comercioId: data.comercioId };
  }

  async perfil(): Promise<Perfil> {
    const { data, error } = await this.cliente.GET('/comercio', { params: this.cabecera });
    if (!data) throw falla(error);
    return aPerfil(data);
  }

  async editar(cambios: CambiosPerfil): Promise<Perfil> {
    const { data, error } = await this.cliente.PATCH('/comercio', {
      params: this.cabecera,
      body: cambios,
    });
    if (!data) throw falla(error);
    return aPerfil(data);
  }

  async abrir(): Promise<Perfil> {
    const { data, error } = await this.cliente.POST('/comercio/abrir', { params: this.cabecera });
    if (!data) throw falla(error);
    return aPerfil(data);
  }
}
