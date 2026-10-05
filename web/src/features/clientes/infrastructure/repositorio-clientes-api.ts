import { CABECERA_COMERCIO } from '@/shared/api/cabeceras';
import type { ClienteVeci, components } from '@/shared/api/cliente';
import { leerProblema } from '@/shared/api/problema';
import {
  ProblemaClientes,
  type ClienteEnLibreta,
  type DatosRegistroAsistido,
  type DocumentoPersona,
  type FichaCliente,
  type FuentePolitica,
  type PersonaEncontrada,
  type Politica,
  type RepositorioClientes,
  type ResultadoRegistro,
  type TipoDocumento,
} from '../domain/cliente';
import { aRenglon } from '../domain/reglas-clientes';

type ClienteApi = components['schemas']['ClienteResponse'];
type EnCajaApi = components['schemas']['ClienteEnCajaResponse'];

const falla = (error: unknown) => {
  const { codigo, mensaje } = leerProblema(error);
  return new ProblemaClientes(codigo, mensaje);
};

const aFicha = (c: ClienteApi): FichaCliente => ({
  ...c,
  apellidos: c.apellidos ?? null,
  celular: c.celular ?? null,
  afiliadoEn: new Date(c.afiliadoEn),
});

const aEnLibreta = (c: EnCajaApi): ClienteEnLibreta => ({
  ...c,
  celular: c.celular ?? null,
  celularFinal: c.celularFinal ?? null,
});

/** Política de datos vigente; es pública, no necesita sesión ni negocio. */
export class PoliticaApi implements FuentePolitica {
  constructor(protected readonly cliente: ClienteVeci) {}

  async politica(): Promise<Politica> {
    const { data, error } = await this.cliente.GET('/politica-de-datos');
    if (!data) throw falla(error);
    return { ...data, publicadaEn: new Date(data.publicadaEn) };
  }
}

/** Clientes del negocio activo con el cliente generado desde OpenAPI. */
export class RepositorioClientesApi extends PoliticaApi implements RepositorioClientes {
  constructor(
    cliente: ClienteVeci,
    private readonly comercioId: string,
  ) {
    super(cliente);
  }

  private get cabecera() {
    return { header: { [CABECERA_COMERCIO]: this.comercioId } };
  }

  async libreta(): Promise<ClienteEnLibreta[]> {
    const { data, error } = await this.cliente.GET('/clientes/copia-local', {
      params: this.cabecera,
    });
    if (!data) throw falla(error);
    return data.clientes.map(aEnLibreta);
  }

  async buscar(texto: string): Promise<ClienteEnLibreta[]> {
    const { data, error } = await this.cliente.GET('/clientes', {
      params: { ...this.cabecera, query: { q: texto } },
    });
    if (!data) throw falla(error);
    return data.map((c) => aRenglon(aFicha(c)));
  }

  async ficha(clienteId: string): Promise<FichaCliente> {
    const { data, error } = await this.cliente.GET('/clientes/{clienteId}', {
      params: { ...this.cabecera, path: { clienteId } },
    });
    if (!data) throw falla(error);
    return aFicha(data);
  }

  async darPinBienvenida(clienteId: string): Promise<string> {
    const { data, error } = await this.cliente.POST('/clientes/{clienteId}/pin-bienvenida', {
      params: { ...this.cabecera, path: { clienteId } },
    });
    if (!data) throw falla(error);
    return data.pinBienvenida;
  }

  async tiposDocumento(): Promise<TipoDocumento[]> {
    const { data, error } = await this.cliente.GET('/registro/tipos-documento');
    if (!data) throw falla(error);
    return data.map((t) => ({ ...t, patron: t.patron ?? null }));
  }

  async revisar(documento: DocumentoPersona): Promise<PersonaEncontrada | null> {
    const { data, error } = await this.cliente.POST('/clientes/registro-asistido/revisar', {
      params: this.cabecera,
      body: documento,
    });
    if (!data) throw falla(error);
    return data.persona ? { ...data.persona, clienteId: data.persona.clienteId ?? null } : null;
  }

  async registrar(datos: DatosRegistroAsistido): Promise<ResultadoRegistro> {
    const { data, error } = await this.cliente.POST('/clientes/registro-asistido', {
      params: this.cabecera,
      body: datos,
    });
    if (!data) throw falla(error);
    return {
      vinculado: data.vinculado,
      cliente: aFicha(data.cliente),
      pinBienvenida: data.pinBienvenida ?? null,
    };
  }
}
