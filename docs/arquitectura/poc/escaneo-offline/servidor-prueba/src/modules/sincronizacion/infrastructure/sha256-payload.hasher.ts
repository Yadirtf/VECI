import { createHash } from 'node:crypto';
import { PayloadHasher } from '../domain/payload-hasher';

/** SHA-256 del JSON con llaves ordenadas, para que el orden de llaves no cambie la huella. */
export class Sha256PayloadHasher implements PayloadHasher {
  hash(payload: Record<string, unknown>): string {
    return createHash('sha256').update(canonicalJson(payload)).digest('hex');
  }
}

function canonicalJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(',')}]`;
  if (value !== null && typeof value === 'object') {
    const entries = Object.entries(value as Record<string, unknown>).sort(([a], [b]) => a.localeCompare(b));
    return `{${entries.map(([k, v]) => `${JSON.stringify(k)}:${canonicalJson(v)}`).join(',')}}`;
  }
  return JSON.stringify(value);
}
