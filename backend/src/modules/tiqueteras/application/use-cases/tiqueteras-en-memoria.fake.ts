import { Movimiento, Motivo } from '../../domain/entities/movimiento';
import {
  DatosDeTipo,
  EstadoTipo,
  TipoDeTiquetera,
  UnidadDeConsumo,
} from '../../domain/entities/tipo-de-tiquetera';
import { Tiquetera } from '../../domain/entities/tiquetera';
import { MedioDePago, VentaRegistrada } from '../../domain/entities/venta';
import { NombreDeTipoRepetido, VentaYaAnulada } from '../../domain/errors/errores-tiqueteras';
import { Ajuste, SaldosRepository, TiqueterasEnComercio } from '../puertos/saldos.repository';
import { TiposRepository } from '../puertos/tipos.repository';
import { VencimientoRepository } from '../puertos/vencimiento.repository';
import {
  Anulacion,
  ContextoDeVenta,
  NuevaVenta,
  ResultadoRegistro,
  VentaResumen,
  VentasRepository,
} from '../puertos/ventas.repository';

export const uuid = (n: number) => `00000000-0000-7000-8000-${String(n).padStart(12, '0')}`;

export const UNIDADES: UnidadDeConsumo[] = [
  { codigo: 'LUNCH', singular: 'almuerzo', plural: 'almuerzos' },
  { codigo: 'BREAKFAST', singular: 'desayuno', plural: 'desayunos' },
];

export const MEDIOS: MedioDePago[] = [
  { codigo: 'CASH', nombre: 'Efectivo', necesitaCanal: false, canales: [] },
  {
    codigo: 'BANK_TRANSFER',
    nombre: 'Transferencia',
    necesitaCanal: true,
    canales: [{ codigo: 'NEQUI', nombre: 'Nequi' }],
  },
];

export const MOTIVOS: Motivo[] = [
  { codigo: 'DATA_ENTRY_ERROR', nombre: 'Error al registrar' },
  { codigo: 'OTHER', nombre: 'Otro' },
];

type TiqueteraEditable = { -readonly [K in keyof Tiquetera]: Tiquetera[K] };

/** Comercio en memoria para probar los casos de uso sin base de datos. */
export class TiqueterasEnMemoria
  implements TiposRepository, VentasRepository, SaldosRepository, VencimientoRepository
{
  readonly tipos = new Map<string, TipoDeTiquetera>();
  readonly ventas = new Map<string, VentaRegistrada>();
  readonly tiqueteras = new Map<string, TiqueteraEditable>();
  readonly clientes = new Map<string, 'ACTIVE' | 'BLOCKED' | 'ENDED'>();
  readonly historia: Movimiento[] = [];
  readonly bitacora: string[] = [];
  readonly porComercio = new Map<string, string[]>();
  zona = 'America/Bogota';
  /** Simula que otra petición registró la misma venta justo antes. */
  carrera: VentaRegistrada | null = null;

  async listar() {
    return [...this.tipos.values()].filter((t) => t.estado !== 'ARCHIVED');
  }
  async buscar(id: string): Promise<never> {
    return (this.tipos.get(id) ?? this.ventas.get(id) ?? null) as never;
  }
  async unidades() {
    return UNIDADES;
  }
  async crear(tipoId: string, datos: DatosDeTipo) {
    if ([...this.tipos.values()].some((t) => t.nombre === datos.nombre)) {
      throw new NombreDeTipoRepetido();
    }
    this.tipos.set(tipoId, this.aTipo(tipoId, datos, 'ACTIVE'));
  }
  async actualizar(tipoId: string, datos: DatosDeTipo) {
    const actual = this.tipos.get(tipoId)!;
    this.tipos.set(tipoId, {
      ...this.aTipo(tipoId, datos, actual.estado),
      vendidas: actual.vendidas,
    });
  }
  async cambiarEstado(tipoId: string, estado: EstadoTipo) {
    this.tipos.set(tipoId, { ...this.tipos.get(tipoId)!, estado });
  }
  async versionCatalogo() {
    return `v${this.tipos.size}`;
  }

  async contexto(): Promise<ContextoDeVenta> {
    return { zonaHoraria: this.zona, medios: MEDIOS };
  }
  async estadoDelCliente(clienteId: string) {
    return this.clientes.get(clienteId) ?? null;
  }
  async registrar(v: NuevaVenta): Promise<ResultadoRegistro> {
    if (this.carrera) {
      this.ventas.set(this.carrera.ventaId, this.carrera);
      this.carrera = null;
      return 'YA_EXISTIA';
    }
    const { tipo } = v;
    this.ventas.set(v.ventaId, { ...v, tipoId: tipo.tipoId, estado: 'COMPLETED' });
    this.tiqueteras.set(v.tiqueteraId, {
      tiqueteraId: v.tiqueteraId,
      clienteId: v.clienteId,
      ventaId: v.ventaId,
      tipoId: tipo.tipoId,
      nombre: tipo.nombre,
      unidad: tipo.unidad,
      compradas: tipo.unidades,
      saldo: tipo.unidades,
      estado: 'ACTIVE',
      compradaEn: v.ocurridaEn,
      venceEn: v.venceEn,
      precio: v.precio,
    });
    this.tipos.set(tipo.tipoId, { ...tipo, vendidas: tipo.vendidas + 1 });
    this.bitacora.push('SALE_CREATED');
    return 'REGISTRADA';
  }
  async recientes(): Promise<VentaResumen[]> {
    return [...this.ventas.values()].map((v) => ({
      ...v,
      cliente: 'Luz Marina C.',
      tiquetera: this.tipos.get(v.tipoId)?.nombre ?? '',
      cajero: null,
      saldo: this.tiqueteras.get(v.tiqueteraId)?.saldo ?? 0,
    }));
  }
  async motivos() {
    return MOTIVOS;
  }
  async anular(a: Anulacion) {
    const venta = this.ventas.get(a.ventaId)!;
    if (venta.estado === 'VOIDED') throw new VentaYaAnulada();
    this.ventas.set(a.ventaId, { ...venta, estado: 'VOIDED' });
    const t = this.tiqueteras.get(venta.tiqueteraId)!;
    this.anotar(a.anulacionId, 'SALE_VOID', -t.saldo, a.motivo.codigo);
    Object.assign(t, { saldo: 0, estado: 'VOIDED' });
    this.bitacora.push('SALE_VOIDED');
  }

  async zonaHoraria() {
    return this.zona;
  }
  async delCliente(clienteId: string) {
    if (!this.clientes.has(clienteId)) return null;
    return [...this.tiqueteras.values()].filter((t) => t.clienteId === clienteId);
  }
  async movimientos(clienteId: string, limite: number) {
    return this.historia.slice(0, limite).filter(() => this.clientes.has(clienteId));
  }
  async tiquetera(id: string) {
    return this.tiqueteras.get(id) ?? null;
  }
  async ajustar(a: Ajuste, revisar: (t: Tiquetera) => void) {
    const t = this.tiqueteras.get(a.tiqueteraId)!;
    revisar(t);
    t.saldo += a.unidades;
    if (t.estado === 'ACTIVE' && t.saldo <= 0) t.estado = 'DEPLETED';
    if (t.estado === 'DEPLETED' && t.saldo > 0) t.estado = 'ACTIVE';
    this.anotar(a.ajusteId, 'ADJUSTMENT', a.unidades, a.motivo.codigo);
    this.bitacora.push('BALANCE_ADJUSTED');
  }
  async deLaPersona(): Promise<TiqueterasEnComercio[]> {
    return [
      {
        comercioId: uuid(1),
        comercio: 'Restaurante La Vecina',
        zonaHoraria: this.zona,
        tiqueteras: [...this.tiqueteras.values()],
      },
    ];
  }

  async comerciosConVencidas(ahora: Date) {
    return [...this.porComercio.keys()].filter((c) =>
      this.porComercio.get(c)!.some((id) => this.debeVencer(id, ahora)),
    );
  }
  async vencer(comercioId: string, ahora: Date) {
    if (comercioId === 'roto') throw new Error('sin conexión');
    const vencen = this.porComercio.get(comercioId)!.filter((id) => this.debeVencer(id, ahora));
    for (const id of vencen)
      Object.assign(this.tiqueteras.get(id)!, { estado: 'EXPIRED', saldo: 0 });
    return vencen.length;
  }

  private debeVencer(id: string, ahora: Date): boolean {
    const t = this.tiqueteras.get(id);
    return !!t && t.estado === 'ACTIVE' && t.venceEn.getTime() <= ahora.getTime();
  }

  private anotar(eventoId: string, tipo: Movimiento['tipo'], unidades: number, motivo: string) {
    this.historia.unshift({
      eventoId,
      tipo,
      ocurridoEn: new Date(),
      unidades,
      tiquetera: null,
      motivo,
      nota: null,
      quien: 'Marta',
      corrigeA: null,
    });
  }

  private aTipo(tipoId: string, d: DatosDeTipo, estado: EstadoTipo): TipoDeTiquetera {
    const unidad = UNIDADES.find((u) => u.codigo === d.unidad)!;
    return { tipoId, ...d, unidad, estado, vendidas: 0, vigentes: 0 };
  }
}
