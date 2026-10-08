import { momentoLegible, TEXTO_MOVIMIENTO } from '../domain/reglas-tiqueteras';
import type { Movimiento } from '../domain/tiquetera';

const CORRECCIONES = new Set(['SALE_VOID', 'ADJUSTMENT', 'CONSUMPTION_REVERSAL']);

/** La historia del saldo, como renglones de cuaderno; las enmiendas van en tinta roja. */
export function Historia({ movimientos }: { movimientos: readonly Movimiento[] }) {
  if (movimientos.length === 0) return null;
  return (
    <section aria-label="Historia del saldo" className="flex flex-col gap-s">
      <h3 className="text-subtitulo font-fuerte">Historia</h3>
      <ol className="flex flex-col">
        {movimientos.map((m) => {
          const enmienda = CORRECCIONES.has(m.tipo);
          return (
            <li
              key={m.eventoId}
              className={`flex flex-wrap justify-between gap-s border-b border-borde/40 py-s text-cuerpo ${enmienda ? 'text-arcilla-oscuro' : ''}`}
            >
              <span>
                <span className="font-medio">{TEXTO_MOVIMIENTO[m.tipo]}</span>
                {m.tiquetera ? ` · ${m.tiquetera}` : ''}
                {m.motivo ? ` · ${m.motivo}` : ''}
                {m.nota ? ` («${m.nota}»)` : ''}
                <span className="block text-pequeno text-tinta-suave">
                  {momentoLegible(m.ocurridoEn)}
                  {m.quien ? ` · ${m.quien}` : ' · VECI'}
                </span>
              </span>
              <span className="font-fuerte tabular-nums">
                {m.unidades > 0 ? `+${m.unidades}` : m.unidades}
              </span>
            </li>
          );
        })}
      </ol>
    </section>
  );
}
