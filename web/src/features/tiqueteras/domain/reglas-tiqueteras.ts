import type {
  Correccion,
  DatosDeTipo,
  EstadoTiquetera,
  MedioDePago,
  Pago,
  TipoDeMovimiento,
  TipoDeTiquetera,
  Tiquetera,
  Unidad,
} from './tiquetera';

/** Los mismos límites que revisa la API (HU-05-01). */
export const LIMITES = {
  nombre: { min: 3, max: 60 },
  unidades: { min: 1, max: 500 },
  precio: { min: 1000, max: 20_000_000 },
  vigenciaDias: { min: 1, max: 365 },
  ajuste: 500,
} as const;

export const TEXTO_MOVIMIENTO: Record<TipoDeMovimiento, string> = {
  SALE: 'Compró',
  CONSUMPTION: 'Consumió',
  CONSUMPTION_REVERSAL: 'Se devolvió un consumo',
  SALE_VOID: 'Venta anulada',
  ADJUSTMENT: 'Ajuste',
  EXPIRATION: 'Venció',
};

export const TEXTO_ESTADO: Record<EstadoTiquetera, string> = {
  ACTIVE: 'Vigente',
  DEPLETED: 'Agotada',
  EXPIRED: 'Vencida',
  VOIDED: 'Anulada',
};

/** "1 almuerzo", "20 almuerzos". */
export const cantidad = (n: number, unidad: Unidad) =>
  `${n} ${Math.abs(n) === 1 ? unidad.singular : unidad.plural}`;

const enteroEntre = (valor: number, { min, max }: { min: number; max: number }) =>
  Number.isInteger(valor) && valor >= min && valor <= max;

/** Revisa el formulario de la pizarra; devuelve el primer problema en palabras de vecino. */
export function problemaDelTipo(d: DatosDeTipo): string | null {
  const nombre = d.nombre.trim();
  if (nombre.length < LIMITES.nombre.min || nombre.length > LIMITES.nombre.max) {
    return 'Ponle un nombre de 3 a 60 letras, como «20 almuerzos».';
  }
  if (!d.unidad) return 'Elige qué se descuenta: almuerzo, desayuno, café…';
  if (!enteroEntre(d.unidades, LIMITES.unidades)) return 'La cantidad va de 1 a 500.';
  if (!enteroEntre(d.precio, LIMITES.precio)) return 'El precio va de $1.000 a $20.000.000.';
  if (!enteroEntre(d.vigenciaDias, LIMITES.vigenciaDias)) return 'La vigencia va de 1 a 365 días.';
  return null;
}

/** Lo que se ve en la pizarra: primero lo que se vende, luego lo guardado; por nombre. */
export function ordenarPizarra(tipos: readonly TipoDeTiquetera[]): TipoDeTiquetera[] {
  return [...tipos].sort(
    (a, b) =>
      Number(a.estado !== 'ACTIVE') - Number(b.estado !== 'ACTIVE') ||
      a.nombre.localeCompare(b.nombre, 'es'),
  );
}

/** Pago listo para enviar: la transferencia exige canal; el efectivo no lleva ninguno. */
export function armarPago(
  medio: MedioDePago | undefined,
  canal: string,
  referencia: string,
): Pago | string {
  if (!medio) return 'Elige cómo pagó.';
  if (!medio.necesitaCanal) return { medio: medio.codigo, canal: null, referencia: null };
  if (!canal) return '¿Por dónde llegó la transferencia? Nequi, Daviplata…';
  return { medio: medio.codigo, canal, referencia: referencia.trim() || null };
}

/** Anular o ajustar pide motivo; con «Otro» hay que escribir qué pasó. */
export function problemaDeCorreccion(c: Correccion): string | null {
  if (!c.motivo) return 'Elige el motivo.';
  if (c.motivo === 'OTHER' && !c.nota?.trim()) return 'Con «Otro» cuenta en la nota qué pasó.';
  return null;
}

/** El ajuste no deja el saldo en negativo ni toca lo que ya no sirve. */
export function problemaDelAjuste(t: Tiquetera, unidades: number): string | null {
  if (!Number.isInteger(unidades) || unidades === 0 || Math.abs(unidades) > LIMITES.ajuste) {
    return 'Escribe cuántas suma (10) o quita (-2).';
  }
  if (t.estado === 'VOIDED' || t.estado === 'EXPIRED') {
    return `Esta tiquetera está ${TEXTO_ESTADO[t.estado].toLowerCase()}: no se ajusta.`;
  }
  if (t.saldo + unidades < 0) return `Solo le quedan ${cantidad(t.saldo, t.unidad)}.`;
  return null;
}

const MESES = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/** "2026-11-06" → "6 nov 2026", sin pasar por zonas horarias. */
export function diaLegible(dia: string): string {
  const [a, m, d] = dia.split('-').map(Number);
  return `${d} ${MESES[m - 1]} ${a}`;
}

const formatoHora = new Intl.DateTimeFormat('es-CO', {
  dateStyle: 'medium',
  timeStyle: 'short',
  timeZone: 'America/Bogota',
});

export const momentoLegible = (fecha: Date) => formatoHora.format(fecha);
