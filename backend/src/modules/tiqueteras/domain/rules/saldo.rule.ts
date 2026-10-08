import { UnidadDeConsumo } from '../entities/tipo-de-tiquetera';
import { Tiquetera } from '../entities/tiquetera';
import { SaldoInsuficiente } from '../errors/errores-tiqueteras';

/** Sirve hoy: activa, sin vencer y con unidades. */
export function estaVigente(t: Tiquetera, ahora: Date): boolean {
  return t.estado === 'ACTIVE' && t.venceEn.getTime() > ahora.getTime() && t.saldo > 0;
}

/**
 * Orden en que se gastan (HU-05-03, RF-TIQ-04): primero la que vence antes; si dos
 * vencen el mismo día, la que se compró primero.
 */
export function ordenDeConsumo(tiqueteras: readonly Tiquetera[], ahora: Date): Tiquetera[] {
  return tiqueteras
    .filter((t) => estaVigente(t, ahora))
    .sort(
      (a, b) =>
        a.venceEn.getTime() - b.venceEn.getTime() ||
        a.compradaEn.getTime() - b.compradaEn.getTime() ||
        a.tiqueteraId.localeCompare(b.tiqueteraId),
    );
}

/** Saldo de una unidad: la suma de las tiqueteras vigentes y la que se gasta primero. */
export interface SaldoPorUnidad {
  readonly unidad: UnidadDeConsumo;
  readonly disponibles: number;
  readonly proximoVencimiento: Date;
  readonly tiqueteras: number;
}

/**
 * El saldo que se muestra (HU-05-03): la suma de las tiqueteras vigentes, por unidad
 * (no se suman almuerzos con desayunos). Las vencidas, agotadas o anuladas no cuentan.
 */
export function saldosPorUnidad(tiqueteras: readonly Tiquetera[], ahora: Date): SaldoPorUnidad[] {
  const porUnidad = new Map<string, SaldoPorUnidad>();
  for (const t of ordenDeConsumo(tiqueteras, ahora)) {
    const previo = porUnidad.get(t.unidad.codigo);
    porUnidad.set(t.unidad.codigo, {
      unidad: t.unidad,
      disponibles: (previo?.disponibles ?? 0) + t.saldo,
      proximoVencimiento: previo?.proximoVencimiento ?? t.venceEn,
      tiqueteras: (previo?.tiqueteras ?? 0) + 1,
    });
  }
  return [...porUnidad.values()];
}

/** Cuánto se descuenta de cada tiquetera. */
export interface Descuento {
  readonly tiqueteraId: string;
  readonly unidades: number;
}

/**
 * Reparte un consumo entre las tiqueteras vigentes de una misma unidad, empezando
 * por la que vence antes (HU-05-03). Si la primera no alcanza, sigue con la siguiente.
 * Es la regla que usa el registro de consumos (EP-06) en línea y en el celular.
 */
export function repartirConsumo(
  tiqueteras: readonly Tiquetera[],
  unidades: number,
  ahora: Date,
): Descuento[] {
  const fila = ordenDeConsumo(tiqueteras, ahora);
  const disponibles = fila.reduce((suma, t) => suma + t.saldo, 0);
  if (unidades > disponibles) throw new SaldoInsuficiente(disponibles);
  const descuentos: Descuento[] = [];
  let faltan = unidades;
  for (const t of fila) {
    if (faltan === 0) break;
    const aqui = Math.min(t.saldo, faltan);
    descuentos.push({ tiqueteraId: t.tiqueteraId, unidades: aqui });
    faltan -= aqui;
  }
  return descuentos;
}
