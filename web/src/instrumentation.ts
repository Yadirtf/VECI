import * as Sentry from '@sentry/nextjs';
import { opcionesSentry } from './shared/lib/sentry-opciones';

export function register() {
  Sentry.init(opcionesSentry(process.env.SENTRY_DSN_WEB ?? process.env.NEXT_PUBLIC_SENTRY_DSN));
}

export const onRequestError = Sentry.captureRequestError;
