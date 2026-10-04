/** SQLSTATE dentro de un error de Prisma con el adaptador pg (ver módulo horarios). */
export function codigoPostgres(error: unknown): string | undefined {
  const meta = (error as { meta?: { driverAdapterError?: { cause?: { originalCode?: unknown } } } })
    ?.meta;
  const codigo = meta?.driverAdapterError?.cause?.originalCode;
  return typeof codigo === 'string' ? codigo : undefined;
}

/** 23505: violación de un índice único. */
export const VIOLACION_UNICA = '23505';
