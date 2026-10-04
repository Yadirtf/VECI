import { leerConfiguracion } from '../../src/shared/infrastructure/config/configuracion';
import { AlmacenContextoAsincrono } from '../../src/shared/infrastructure/contexto/almacen-contexto-asincrono';
import { PrismaService } from '../../src/shared/infrastructure/prisma/prisma.service';
import { TransaccionComercio } from '../../src/shared/infrastructure/prisma/transaccion-comercio';
import { urlApp } from './base-de-datos';

/** Cliente de Prisma como veci_api (con RLS) y el ejecutor de transacciones por comercio. */
export function crearTransacciones(): { prisma: PrismaService; transaccion: TransaccionComercio } {
  const config = { ...leerConfiguracion({}), databaseAppUrl: urlApp() };
  const prisma = new PrismaService(config);
  return { prisma, transaccion: new TransaccionComercio(prisma, new AlmacenContextoAsincrono()) };
}
