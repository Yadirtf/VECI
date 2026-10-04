import { randomUUID } from 'node:crypto';
import { Client } from 'pg';
import { PrismaService } from '../../src/shared/infrastructure/prisma/prisma.service';
import { TransaccionComercio } from '../../src/shared/infrastructure/prisma/transaccion-comercio';
import { ComercioDePrueba, conectarDueno } from '../soporte/base-de-datos';
import { crearComercio } from '../soporte/escenario';
import { crearTransacciones } from '../soporte/transacciones';

// HU-01-05: un comercio intenta leer y escribir datos de otro y la base lo impide.
describe('Aislamiento multi-comercio con RLS', () => {
  let dueno: Client;
  let prisma: PrismaService;
  let transaccion: TransaccionComercio;
  let a: ComercioDePrueba;
  let b: ComercioDePrueba;

  const comoB = <T>(trabajo: Parameters<TransaccionComercio['ejecutar']>[0]) =>
    transaccion.ejecutarComo(
      { comercioId: b.comercioId, usuarioId: b.usuarioId },
      trabajo,
    ) as Promise<T>;

  beforeAll(async () => {
    dueno = await conectarDueno();
    ({ prisma, transaccion } = crearTransacciones());
    a = await crearComercio(dueno);
    b = await crearComercio(dueno);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await dueno.end();
  });

  it('cada comercio ve sus filas', async () => {
    const servicios = await transaccion.ejecutarComo(
      { comercioId: a.comercioId, usuarioId: a.usuarioId },
      (tx) => tx.services.findMany({ select: { tenant_id: true } }),
    );
    expect(servicios.length).toBeGreaterThan(0);
    expect(servicios.every((s) => s.tenant_id === a.comercioId)).toBe(true);
  });

  it('B no lee la afiliación, la sede ni el comercio de A', async () => {
    const [afiliacion, sede, comercio] = await comoB<unknown[]>(async (tx) => [
      await tx.affiliations.findUnique({ where: { id: a.afiliacionId } }),
      await tx.branches.findUnique({ where: { id: a.sedeId } }),
      await tx.tenants.findUnique({ where: { id: a.comercioId } }),
    ]);
    expect([afiliacion, sede, comercio]).toEqual([null, null, null]);
  });

  it('B no puede crear filas a nombre de A', async () => {
    await expect(
      comoB((tx) =>
        tx.services.create({ data: { tenant_id: a.comercioId, name: `Intruso ${randomUUID()}` } }),
      ),
    ).rejects.toThrow(/row-level security/);
  });

  it('B no puede modificar filas de A', async () => {
    const resultado = await comoB<{ count: number }>((tx) =>
      tx.services.updateMany({ where: { id: a.servicioId }, data: { name: 'Hackeado' } }),
    );
    expect(resultado.count).toBe(0);
  });

  it('nadie borra filas desde la API: se cambian estados o se registran eventos', async () => {
    await expect(
      comoB((tx) => tx.services.deleteMany({ where: { id: b.servicioId } })),
    ).rejects.toThrow(/permission denied/);
  });

  it('sin comercio fijado no se ve nada', async () => {
    await expect(prisma.tenants.count()).resolves.toBe(0);
    await expect(prisma.affiliations.count()).resolves.toBe(0);
  });

  it('el comercio fijado no se filtra a la siguiente consulta del mismo pool', async () => {
    await transaccion.ejecutarComo({ comercioId: a.comercioId, usuarioId: a.usuarioId }, (tx) =>
      tx.services.count(),
    );
    await expect(prisma.services.count()).resolves.toBe(0);
  });
});
