'use client';

import * as Sentry from '@sentry/nextjs';
import { useEffect } from 'react';

/** Último recurso ante un error inesperado: lo reporta y habla en tono VECI. */
export default function ErrorGlobal({ error }: { error: Error & { digest?: string } }) {
  useEffect(() => {
    Sentry.captureException(error);
  }, [error]);

  return (
    <html lang="es-CO">
      <body
        style={{ fontFamily: 'system-ui', padding: 32, background: '#FFF8EE', color: '#1C2420' }}
      >
        <h1>Algo salió mal, veci</h1>
        <p>Ya nos avisaron y lo estamos revisando. Recarga la página en un momento.</p>
      </body>
    </html>
  );
}
