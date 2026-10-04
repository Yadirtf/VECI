/** Códigos de sync.inbound_event_kinds que acepta la prueba de concepto. */
export const SUPPORTED_EVENT_KINDS = ['CONSUMPTION'] as const;

/** Códigos de sync.inbound_event_statuses usados como respuesta. */
export type InboundEventStatus = 'APPLIED' | 'REJECTED';

/** Códigos de sync.rejection_reasons. */
export type RejectionReason = 'VALIDATION_ERROR' | 'QR_FROM_OTHER_TENANT';

/** Evento tal como llega del celular, antes de validarlo. */
export interface IncomingEvent {
  id: string;
  kind: string;
  occurredAt: string;
  payload: Record<string, unknown>;
}

/** Fila de sync.inbound_events: registro de idempotencia (PK = id del celular). */
export interface InboundEvent {
  id: string;
  tenantId: string;
  batchId: string;
  deviceId: string;
  kind: string;
  occurredAt: Date;
  receivedAt: Date;
  payloadSha256: string;
  status: InboundEventStatus;
  rejectionReason: RejectionReason | null;
}

/** Respuesta por evento (HU-07-03): estado y si ya se había recibido. */
export interface EventResult {
  id: string;
  status: InboundEventStatus;
  rejectionReason: RejectionReason | null;
  /** true si el id ya existía: se devuelve el resultado guardado y no se aplica de nuevo. */
  replayed: boolean;
}
