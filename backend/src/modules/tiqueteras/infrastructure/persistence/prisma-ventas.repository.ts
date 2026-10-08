import { Injectable } from '@nestjs/common';
import { TransaccionComercio } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { Motivo } from '../../domain/entities/movimiento';
import {
  EstadoVenta,
  MedioDePago,
  OrigenVenta,
  VentaRegistrada,
} from '../../domain/entities/venta';
import {
  Anulacion,
  ContextoDeVenta,
  NuevaVenta,
  ResultadoRegistro,
  VentaResumen,
  VentasRepository,
} from '../../application/puertos/ventas.repository';
import { registrarVenta } from './alta-de-venta';
import { anularVenta } from './anulacion-de-venta';
import { consultaVentas, FilaVenta } from './consultas-ventas';

/** Motivos de otras épicas: autorizar un consumo extra (EP-06) y resolver conflictos (EP-07). */
const MOTIVOS_DE_OTRAS_EPICAS = ['AUTHORIZED_EXTRA_SERVICE', 'CONFLICT_RESOLUTION'];

const aVenta = (f: FilaVenta): VentaRegistrada => ({
  ventaId: f.venta_id,
  clienteId: f.cliente_id,
  tipoId: f.tipo_id,
  tiqueteraId: f.tiquetera_id,
  precio: f.precio,
  pago: { medio: f.medio, canal: f.canal, referencia: f.referencia },
  ocurridaEn: f.ocurrida_en,
  origen: f.origen as OrigenVenta,
  estado: f.estado as EstadoVenta,
});

/** Ventas del comercio activo (HU-05-02, HU-05-05). Todo con el comercio fijado (RLS). */
@Injectable()
export class PrismaVentasRepository implements VentasRepository {
  constructor(private readonly transaccion: TransaccionComercio) {}

  contexto(): Promise<ContextoDeVenta> {
    return this.transaccion.ejecutar(async (tx) => {
      const [comercio] = await tx.$queryRaw<{ zona: string }[]>`
        SELECT time_zone AS zona FROM tenancy.tenants WHERE id = core.current_tenant_id()`;
      const medios = await tx.$queryRaw<MedioDePago[]>`
        SELECT pm.code AS codigo, pm.name AS nombre, pm.needs_channel AS "necesitaCanal",
               coalesce(json_agg(json_build_object('codigo', pc.code, 'nombre', pc.name)
                                 ORDER BY pc.sort_order) FILTER (WHERE pc.id IS NOT NULL),
                        '[]'::json) AS canales
          FROM core.payment_methods pm
          LEFT JOIN core.payment_channels pc ON pc.payment_method_id = pm.id AND pc.is_active
         WHERE pm.is_active
         GROUP BY pm.id
         ORDER BY pm.sort_order`;
      return { zonaHoraria: comercio.zona, medios };
    });
  }

  estadoDelCliente(clienteId: string) {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<{ estado: 'ACTIVE' | 'BLOCKED' | 'ENDED' }[]>`
        SELECT st.code AS estado
          FROM customers.affiliations a
          JOIN customers.affiliation_statuses st ON st.id = a.affiliation_status_id
         WHERE a.id = ${clienteId}::uuid`;
      return fila?.estado ?? null;
    });
  }

  buscar(ventaId: string): Promise<VentaRegistrada | null> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<FilaVenta[]>(consultaVentas({ ventaId }));
      return fila ? aVenta(fila) : null;
    });
  }

  registrar(venta: NuevaVenta): Promise<ResultadoRegistro> {
    return this.transaccion.ejecutar((tx) => registrarVenta(tx, venta));
  }

  recientes(limite: number): Promise<VentaResumen[]> {
    return this.transaccion.ejecutar(async (tx) =>
      (await tx.$queryRaw<FilaVenta[]>(consultaVentas({ limite }))).map((f) => ({
        ...aVenta(f),
        cliente: f.cliente,
        tiquetera: f.tiquetera,
        cajero: f.cajero,
        saldo: f.saldo,
      })),
    );
  }

  motivos(): Promise<Motivo[]> {
    return this.transaccion.ejecutar(
      (tx) => tx.$queryRaw<Motivo[]>`
        SELECT code AS codigo, name AS nombre
          FROM ledger.event_reasons
         WHERE is_active AND code <> ALL (${MOTIVOS_DE_OTRAS_EPICAS}::text[])
         ORDER BY sort_order`,
    );
  }

  anular(anulacion: Anulacion): Promise<void> {
    return this.transaccion.ejecutar((tx) => anularVenta(tx, anulacion));
  }
}
