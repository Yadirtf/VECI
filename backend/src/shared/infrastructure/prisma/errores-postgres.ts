/** Código SQLSTATE de un error de PostgreSQL que llega por el adaptador de Prisma. */
export function codigoPostgres(error: unknown): string | undefined {
  const meta = (error as { meta?: { driverAdapterError?: { cause?: { originalCode?: unknown } } } })
    ?.meta;
  const codigo = meta?.driverAdapterError?.cause?.originalCode;
  return typeof codigo === 'string' ? codigo : undefined;
}

/** 23505: violación de una llave única (un id o un nombre repetido). */
export const VIOLACION_UNICA = '23505';
