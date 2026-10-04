import { codigoPostgres } from './es-error-postgres';

describe('codigoPostgres', () => {
  it('lee el SQLSTATE que anida el adaptador pg de Prisma', () => {
    const error = {
      code: 'P2010',
      meta: { driverAdapterError: { cause: { originalCode: '23P01', kind: 'postgres' } } },
    };
    expect(codigoPostgres(error)).toBe('23P01');
  });

  it('devuelve undefined para errores que no vienen de PostgreSQL', () => {
    expect(codigoPostgres(new Error('x'))).toBeUndefined();
    expect(codigoPostgres(undefined)).toBeUndefined();
  });
});
