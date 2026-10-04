/** Huella del contenido del evento (sync.inbound_events.payload_sha256). */
export interface PayloadHasher {
  hash(payload: Record<string, unknown>): string;
}

export const PAYLOAD_HASHER = Symbol('PayloadHasher');
