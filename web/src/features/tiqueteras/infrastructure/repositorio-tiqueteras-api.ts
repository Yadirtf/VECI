import { CABECERA_COMERCIO } from '@/shared/api/cabeceras';
import type { ClienteVeci, components } from '@/shared/api/cliente';
import { leerProblema } from '@/shared/api/problema';
import {
  ProblemaTiqueteras,
  type Correccion,
  type DatosDeTipo,
  type EstadoDeCuenta,
  type EstadoTipo,
  type Motivo,
  type MedioDePago,
  type NuevaVenta,
  type RepositorioCuentas,
  type RepositorioPizarra,
  type TipoDeMovimiento,
  type TipoDeTiquetera,
  type Tiquetera,
  type Unidad,
  type VentaReciente,
} from '../domain/tiquetera';

type Esquemas = components['schemas'];

const falla = (error: unknown) => {
  const { codigo, mensaje } = leerProblema(error);
  return new ProblemaTiqueteras(codigo, mensaje);
};

/** openapi-fetch responde { data } o { error }; aquí se vuelve un valor o una excepción. */
async function dato<T>(llamada: Promise<{ data?: T; error?: unknown }>): Promise<T> {
  const { data, error } = await llamada;
  if (data === undefined) throw falla(error);
  return data;
}

const aTipo = (t: Esquemas['TipoResponse']): TipoDeTiquetera => ({
  ...t,
  estado: t.estado as EstadoTipo,
});

const aTiquetera = (t: Esquemas['TiqueteraResponse']): Tiquetera => ({
  tiqueteraId: t.tiqueteraId,
  ventaId: t.ventaId,
  nombre: t.nombre,
  unidad: t.unidad,
  compradas: t.compradas,
  saldo: t.saldo,
  estado: t.estado as Tiquetera['estado'],
  compradaEn: new Date(t.compradaEn),
  ultimoDia: t.ultimoDia,
  vigente: t.vigente,
  turno: t.turno ?? null,
  precio: t.precio ?? null,
});

const aCuenta = (
  c: Pick<Esquemas['EstadoDeCuentaResponse'], 'saldos' | 'tiqueteras'> & {
    clienteId: string;
    movimientos?: Esquemas['MovimientoResponse'][];
  },
): EstadoDeCuenta => ({
  clienteId: c.clienteId,
  saldos: c.saldos.map((s) => ({
    unidad: s.unidad,
    disponibles: s.disponibles,
    ultimoDia: s.ultimoDia,
    tiqueteras: s.tiqueteras,
  })),
  tiqueteras: c.tiqueteras.map(aTiquetera),
  movimientos: (c.movimientos ?? []).map((m) => ({
    eventoId: m.eventoId,
    tipo: m.tipo as TipoDeMovimiento,
    ocurridoEn: new Date(m.ocurridoEn),
    unidades: m.unidades,
    tiquetera: m.tiquetera ?? null,
    motivo: m.motivo ?? null,
    nota: m.nota ?? null,
    quien: m.quien ?? null,
  })),
});

const aVenta = (v: Esquemas['VentaResumenResponse']): VentaReciente => ({
  ventaId: v.ventaId,
  clienteId: v.clienteId,
  cliente: v.cliente,
  tiquetera: v.tiquetera,
  precio: v.precio,
  pago: { medio: v.pago.medio, canal: v.pago.canal ?? null, referencia: v.pago.referencia ?? null },
  ocurridaEn: new Date(v.ocurridaEn),
  sinConexion: v.origen === 'OFFLINE_SYNC',
  anulada: v.estado === 'VOIDED',
  cajero: v.cajero ?? null,
  saldo: v.saldo,
});

const cuerpoCorreccion = (c: Correccion) => ({
  motivo: c.motivo,
  ...(c.nota?.trim() ? { nota: c.nota.trim() } : {}),
});

/** Base: el cliente generado desde OpenAPI con el negocio activo en la cabecera. */
class ConNegocio {
  constructor(
    protected readonly cliente: ClienteVeci,
    private readonly comercioId: string,
  ) {}

  protected get cabecera() {
    return { header: { [CABECERA_COMERCIO]: this.comercioId } };
  }
}

/** La pizarra de tiqueteras (HU-05-01). */
export class PizarraApi extends ConNegocio implements RepositorioPizarra {
  async tipos(): Promise<TipoDeTiquetera[]> {
    const tipos = await dato(this.cliente.GET('/tiqueteras/tipos', { params: this.cabecera }));
    return tipos.map(aTipo);
  }

  unidades(): Promise<Unidad[]> {
    return dato(this.cliente.GET('/tiqueteras/unidades', { params: this.cabecera }));
  }

  async crear(datos: DatosDeTipo): Promise<TipoDeTiquetera> {
    const params = this.cabecera;
    return aTipo(await dato(this.cliente.POST('/tiqueteras/tipos', { params, body: datos })));
  }

  async editar(tipoId: string, datos: DatosDeTipo): Promise<TipoDeTiquetera> {
    const params = { ...this.cabecera, path: { tipoId } };
    return aTipo(
      await dato(this.cliente.PATCH('/tiqueteras/tipos/{tipoId}', { params, body: datos })),
    );
  }

  async cambiarEstado(tipoId: string, activo: boolean): Promise<TipoDeTiquetera> {
    const params = { ...this.cabecera, path: { tipoId } };
    const ruta = '/tiqueteras/tipos/{tipoId}/estado';
    return aTipo(await dato(this.cliente.PATCH(ruta, { params, body: { activo } })));
  }
}

/** Ventas, saldos y correcciones (HU-05-02, HU-05-03, HU-05-05). */
export class CuentasApi extends ConNegocio implements RepositorioCuentas {
  async catalogo(): Promise<{ tipos: TipoDeTiquetera[]; medios: MedioDePago[] }> {
    const c = await dato(this.cliente.GET('/ventas/catalogo', { params: this.cabecera }));
    return { tipos: c.tipos.map(aTipo), medios: c.medios };
  }

  async cuenta(clienteId: string): Promise<EstadoDeCuenta> {
    const params = { ...this.cabecera, path: { clienteId } };
    return aCuenta(await dato(this.cliente.GET('/tiqueteras/cliente/{clienteId}', { params })));
  }

  async vender(venta: NuevaVenta): Promise<EstadoDeCuenta> {
    const { pago } = venta;
    const body = {
      ...venta,
      sinConexion: false,
      pago: {
        medio: pago.medio,
        ...(pago.canal ? { canal: pago.canal } : {}),
        ...(pago.referencia ? { referencia: pago.referencia } : {}),
      },
    };
    await dato(this.cliente.POST('/ventas', { params: this.cabecera, body }));
    // La respuesta trae el saldo; la historia se pide aparte para mostrar la compra.
    return this.cuenta(venta.clienteId);
  }

  async ventas(): Promise<VentaReciente[]> {
    return (await dato(this.cliente.GET('/ventas', { params: this.cabecera }))).map(aVenta);
  }

  motivos(): Promise<Motivo[]> {
    return dato(this.cliente.GET('/tiqueteras/motivos', { params: this.cabecera }));
  }

  async anular(ventaId: string, correccion: Correccion): Promise<EstadoDeCuenta> {
    const params = { ...this.cabecera, path: { ventaId } };
    const body = cuerpoCorreccion(correccion);
    return aCuenta(await dato(this.cliente.POST('/ventas/{ventaId}/anulacion', { params, body })));
  }

  async ajustar(tiqueteraId: string, unidades: number, c: Correccion): Promise<EstadoDeCuenta> {
    const params = { ...this.cabecera, path: { tiqueteraId } };
    const body = { unidades, ...cuerpoCorreccion(c) };
    const ruta = '/tiqueteras/{tiqueteraId}/ajustes';
    return aCuenta(await dato(this.cliente.POST(ruta, { params, body })));
  }
}
