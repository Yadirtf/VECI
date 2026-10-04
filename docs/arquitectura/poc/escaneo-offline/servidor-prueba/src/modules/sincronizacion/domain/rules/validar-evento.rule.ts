import { IncomingEvent, RejectionReason, SUPPORTED_EVENT_KINDS } from '../inbound-event';

/** Tolerancia para relojes de celular adelantados. */
const MAX_CLOCK_SKEW_MS = 5 * 60 * 1000;
const UUID_V7 = /^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export interface ValidationContext {
  tenantId: string;
  now: Date;
}

/**
 * Reglas de forma de un evento offline. Devuelve el motivo de rechazo o null.
 * Lo que ya pasó no se rechaza por reglas de negocio (ADR-0004): eso es un conflicto.
 */
export function validarEvento(event: IncomingEvent, ctx: ValidationContext): RejectionReason | null {
  if (!UUID_V7.test(event.id)) return 'VALIDATION_ERROR';
  if (!(SUPPORTED_EVENT_KINDS as readonly string[]).includes(event.kind)) return 'VALIDATION_ERROR';
  const occurredAt = Date.parse(event.occurredAt);
  if (Number.isNaN(occurredAt)) return 'VALIDATION_ERROR';
  if (occurredAt - ctx.now.getTime() > MAX_CLOCK_SKEW_MS) return 'VALIDATION_ERROR';
  if (event.payload['tenant_id'] !== ctx.tenantId) return 'QR_FROM_OTHER_TENANT';
  if (typeof event.payload['affiliation_qr_code_id'] !== 'string') return 'VALIDATION_ERROR';
  return null;
}
