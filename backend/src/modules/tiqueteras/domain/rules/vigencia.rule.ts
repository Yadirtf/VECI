const MS_POR_DIA = 86_400_000;

/** Partes de la fecha y hora de pared en una zona horaria (sin librerías). */
function partesLocales(instante: Date, zona: string): number[] {
  const formato = new Intl.DateTimeFormat('en-CA', {
    timeZone: zona,
    hourCycle: 'h23',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  });
  const partes = Object.fromEntries(formato.formatToParts(instante).map((p) => [p.type, p.value]));
  return ['year', 'month', 'day', 'hour', 'minute', 'second'].map((k) => Number(partes[k]));
}

/** Diferencia entre la hora de pared de la zona y UTC en ese instante, en milisegundos. */
function desfase(instante: Date, zona: string): number {
  const [a, mes, d, h, m, s] = partesLocales(instante, zona);
  return Date.UTC(a, mes - 1, d, h, m, s) - Math.floor(instante.getTime() / 1000) * 1000;
}

/** Fecha del negocio (AAAA-MM-DD) en que cae un instante. */
export function fechaLocal(instante: Date, zona: string): string {
  const [a, mes, d] = partesLocales(instante, zona);
  return `${a}-${String(mes).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
}

/** Medianoche de una fecha del negocio, como instante. */
function medianocheLocal(fecha: string, zona: string): Date {
  const [a, mes, d] = fecha.split('-').map(Number);
  const supuesto = Date.UTC(a, mes - 1, d);
  const primera = supuesto - desfase(new Date(supuesto), zona);
  return new Date(supuesto - desfase(new Date(primera), zona));
}

/**
 * Hasta cuándo sirve una tiquetera (HU-05-01, HU-05-04). El día de la compra cuenta
 * como el primero y se vence a la medianoche del negocio después del último: una de
 * 30 días comprada el 8 de octubre sirve hasta el 6 de noviembre a cualquier hora.
 * Así no se vence a media mañana ni depende de la hora del servidor.
 */
export function calcularVencimiento(compradaEn: Date, vigenciaDias: number, zona: string): Date {
  const compra = medianocheLocal(fechaLocal(compradaEn, zona), zona);
  const destino = new Date(compra.getTime() + vigenciaDias * MS_POR_DIA + MS_POR_DIA / 2);
  return medianocheLocal(fechaLocal(destino, zona), zona);
}

/** Último día (fecha del negocio) en que la tiquetera todavía sirve. */
export function ultimoDiaDeUso(venceEn: Date, zona: string): string {
  return fechaLocal(new Date(venceEn.getTime() - 1), zona);
}
