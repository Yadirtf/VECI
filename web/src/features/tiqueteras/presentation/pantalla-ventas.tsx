'use client';

import { Aviso, Boton, Tarjeta } from '@/shared/ui';
import { formatearPesos } from '@/shared/lib/moneda';
import { useVentas } from '../application/use-ventas';
import { momentoLegible } from '../domain/reglas-tiqueteras';
import type { MedioDePago, RepositorioCuentas, VentaReciente } from '../domain/tiquetera';
import { FormularioCorreccion } from './correccion';

type Ventas = ReturnType<typeof useVentas>;

const MEDIO: Record<string, string> = { CASH: 'Efectivo', BANK_TRANSFER: 'Transferencia' };
const CANAL: Record<string, string> = {
  NEQUI: 'Nequi',
  DAVIPLATA: 'Daviplata',
  BANCOLOMBIA: 'Bancolombia',
};

export const pagoLegible = (
  v: Pick<VentaReciente, 'pago'>,
  medios: readonly MedioDePago[] = [],
) => {
  const medio =
    medios.find((m) => m.codigo === v.pago.medio)?.nombre ?? MEDIO[v.pago.medio] ?? v.pago.medio;
  return v.pago.canal ? `${medio} · ${CANAL[v.pago.canal] ?? v.pago.canal}` : medio;
};

function Venta({ venta, v }: { venta: VentaReciente; v: Ventas }) {
  const motivos = v.estado.tipo === 'listo' ? v.estado.datos.motivos : [];
  return (
    <li className="flex flex-col gap-s border-b border-dashed border-borde py-m">
      <div className="flex flex-wrap items-center justify-between gap-m">
        <div className={venta.anulada ? 'opacity-70' : ''}>
          <p className="text-subtitulo font-fuerte">
            {venta.cliente} · {venta.tiquetera}
          </p>
          <p className="text-cuerpo">
            {formatearPesos(venta.precio)} · {pagoLegible(venta)} ·{' '}
            {momentoLegible(venta.ocurridaEn)}
            {venta.cajero ? ` · vendió ${venta.cajero}` : ''}
            {venta.sinConexion ? ' · hecha sin señal' : ''}
          </p>
          <p className="text-pequeno text-tinta-suave">
            {venta.anulada
              ? 'Anulada: sigue en la historia con su motivo.'
              : `Le quedan ${venta.saldo}.`}
          </p>
        </div>
        {!venta.anulada && v.anulando !== venta.ventaId && (
          <Boton variante="secundario" onClick={() => v.elegir(venta.ventaId)}>
            Anular
          </Boton>
        )}
      </div>
      {v.anulando === venta.ventaId && (
        <FormularioCorreccion
          titulo={`Anular la venta de ${venta.cliente}`}
          motivos={motivos}
          textoBoton="Anular venta"
          ocupado={v.ocupado}
          problema={v.problema}
          alEnviar={(c) => v.anular(venta, c)}
          alCancelar={() => v.elegir(null)}
        />
      )}
    </li>
  );
}

/** Las últimas ventas, para anular la que quedó mal con su motivo (HU-05-05). */
export function PantallaVentas({ repositorio }: { repositorio: RepositorioCuentas }) {
  const v = useVentas(repositorio);
  if (v.estado.tipo === 'cargando')
    return <Aviso tono="aviso">Un momento, veci, ya traemos las ventas…</Aviso>;
  if (v.estado.tipo === 'error') return <Aviso tono="error">{v.estado.mensaje}</Aviso>;
  const { ventas } = v.estado.datos;
  return (
    <div className="flex flex-col gap-l">
      <p className="text-subtitulo text-tinta-suave">
        Anular quita lo que le quedaba a esa tiquetera. Nada se borra: queda quién, cuándo y por
        qué.
      </p>
      {v.aviso && <Aviso tono="exito">{v.aviso}</Aviso>}
      <Tarjeta aria-label="Ventas recientes">
        {ventas.length === 0 ? (
          <p className="text-cuerpo">
            Aún no hay ventas. Se hacen en la caja o en la ficha del cliente.
          </p>
        ) : (
          <ul>
            {ventas.map((venta) => (
              <Venta key={venta.ventaId} venta={venta} v={v} />
            ))}
          </ul>
        )}
      </Tarjeta>
    </div>
  );
}
