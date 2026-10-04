import { withSentryConfig } from '@sentry/nextjs/config';
import type { NextConfig } from 'next';

const configuracion: NextConfig = {
  reactStrictMode: true,
};

// Sube los mapas de fuente a Sentry solo si hay token (CI de despliegue, HU-01-07).
export default withSentryConfig(configuracion, {
  org: process.env.SENTRY_ORG,
  project: process.env.SENTRY_PROJECT_WEB,
  authToken: process.env.SENTRY_AUTH_TOKEN,
  silent: !process.env.CI,
  sourcemaps: { disable: !process.env.SENTRY_AUTH_TOKEN },
});
