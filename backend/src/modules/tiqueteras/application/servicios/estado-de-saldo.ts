import { Tiquetera } from '../../domain/entities/tiquetera';
import { estaVigente, ordenDeConsumo, saldosPorUnidad } from '../../domain/rules/saldo.rule';
import { ultimoDiaDeUso } from '../../domain/rules/vigencia.rule';
import { EstadoDeSaldo, TiqueteraOutput } from '../dto/tiqueteras.dto';

/** Las que ya no sirven se muestran después, de la más reciente a la más antigua. */
function porFecha(a: Tiquetera, b: Tiquetera): number {
  return b.compradaEn.getTime() - a.compradaEn.getTime();
}

/**
 * Arma lo que ven la caja, el panel y la app del cliente (HU-05-03): el saldo por
 * unidad y cada tiquetera con su turno (la que vence antes se gasta primero).
 */
export function estadoDeSaldo(
  tiqueteras: readonly Tiquetera[],
  zona: string,
  ahora: Date,
): EstadoDeSaldo {
  const fila = ordenDeConsumo(tiqueteras, ahora);
  const turno = new Map(fila.map((t, i) => [t.tiqueteraId, i + 1]));
  const otras = tiqueteras.filter((t) => !turno.has(t.tiqueteraId)).sort(porFecha);
  return {
    saldos: saldosPorUnidad(tiqueteras, ahora).map((s) => ({
      ...s,
      ultimoDia: ultimoDiaDeUso(s.proximoVencimiento, zona),
    })),
    tiqueteras: [...fila, ...otras].map((t): TiqueteraOutput => ({
      ...t,
      ultimoDia: ultimoDiaDeUso(t.venceEn, zona),
      vigente: estaVigente(t, ahora),
      turno: turno.get(t.tiqueteraId) ?? null,
    })),
  };
}
