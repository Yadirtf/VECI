/** QR personal: firmado por VECI, solo sirve para afiliarse (ADR-0005, ADR-0017). */
export interface CargaQrPersonal {
  readonly k: string;
  readonly q: string;
  readonly v: number;
}

/** QR del cliente en un comercio, firmado por ese comercio (ADR-0011). */
export interface CargaQrAfiliacion {
  readonly k: string;
  readonly t: string;
  readonly a: string;
  readonly q: string;
  readonly v: number;
}

export const PREFIJO_PERSONAL = 'VP1';
export const PREFIJO_AFILIACION = 'V1';

/** Token separado en su parte firmada y su firma, todavía sin verificar. */
export type TokenQr =
  | { tipo: 'PERSONAL'; carga: CargaQrPersonal; firmado: string; firma: string }
  | { tipo: 'AFILIACION'; carga: CargaQrAfiliacion; firmado: string; firma: string }
  | { tipo: 'AJENO' };

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
const KEY_ID = /^[a-z0-9]{1,40}$/;

/** "<prefijo>.<base64url(JSON)>": la parte que se firma. */
export function parteFirmada(prefijo: string, carga: CargaQrPersonal | CargaQrAfiliacion): string {
  return `${prefijo}.${Buffer.from(JSON.stringify(carga)).toString('base64url')}`;
}

function leerCarga(texto: string): Record<string, unknown> | null {
  try {
    const carga: unknown = JSON.parse(Buffer.from(texto, 'base64url').toString('utf8'));
    return carga && typeof carga === 'object' ? (carga as Record<string, unknown>) : null;
  } catch {
    return null;
  }
}

function esComun(c: Record<string, unknown>): boolean {
  const { k, q, v } = c;
  return (
    typeof k === 'string' &&
    KEY_ID.test(k) &&
    typeof q === 'string' &&
    UUID.test(q) &&
    Number.isInteger(v) &&
    (v as number) > 0
  );
}

/**
 * Separa y valida la forma del token. Cualquier otra cosa (un QR de un banco, una URL,
 * un token roto) es AJENO: la caja dice "este QR no es de VECI" sin más detalle.
 */
export function leerTokenQr(texto: string): TokenQr {
  const partes = texto.trim().split('.');
  if (partes.length !== 3 || !partes[2]) return { tipo: 'AJENO' };
  const [prefijo, cuerpo, firma] = partes;
  const c = leerCarga(cuerpo);
  if (!c || !esComun(c)) return { tipo: 'AJENO' };
  const firmado = `${prefijo}.${cuerpo}`;
  if (prefijo === PREFIJO_PERSONAL) {
    const carga = { k: c.k as string, q: c.q as string, v: c.v as number };
    return { tipo: 'PERSONAL', carga, firmado, firma };
  }
  const { t, a } = c;
  if (prefijo !== PREFIJO_AFILIACION || typeof t !== 'string' || typeof a !== 'string') {
    return { tipo: 'AJENO' };
  }
  if (!UUID.test(t) || !UUID.test(a)) return { tipo: 'AJENO' };
  const carga = { k: c.k as string, t, a, q: c.q as string, v: c.v as number };
  return { tipo: 'AFILIACION', carga, firmado, firma };
}
