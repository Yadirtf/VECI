/**
 * Código SQLSTATE de PostgreSQL dentro de un error de Prisma con el adaptador pg:
 * error.meta.driverAdapterError.cause.originalCode. El error.code de Prisma
 * (P2010...) no es el de PostgreSQL y se ignora.
 */
export function codigoPostgres(error: unknown): string | undefined {
  const meta = (error as { meta?: { driverAdapterError?: { cause?: { originalCode?: unknown } } } })
    ?.meta;
  const codigo = meta?.driverAdapterError?.cause?.originalCode;
  return typeof codigo === 'string' ? codigo : undefined;
}

/** 23P01: violación de una restricción de exclusión (horarios que se cruzan). */
export const VIOLACION_EXCLUSION = '23P01';
