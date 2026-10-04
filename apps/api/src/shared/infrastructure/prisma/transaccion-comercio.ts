import { Inject, Injectable } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import {
  ALMACEN_CONTEXTO,
  AlmacenContexto,
} from '../../application/contexto/almacen-contexto.port';
import { ContextoComercio } from '../../application/contexto/contexto-comercio';
import { PrismaService } from './prisma.service';

/** Cliente dentro de una transacción que ya tiene el comercio fijado. */
export type ClienteTransaccion = Prisma.TransactionClient;

/**
 * Ejecuta trabajo de base de datos con el comercio activo fijado por SET LOCAL
 * (app.tenant_id). Las políticas RLS de PostgreSQL solo devuelven y aceptan filas
 * de ese comercio: es la segunda barrera después del guard (HU-01-05, ADR-0002).
 */
@Injectable()
export class TransaccionComercio {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(ALMACEN_CONTEXTO) private readonly almacen: AlmacenContexto,
  ) {}

  /** Usa el comercio que el guard fijó para la petición en curso. */
  ejecutar<T>(trabajo: (tx: ClienteTransaccion) => Promise<T>): Promise<T> {
    const contexto = this.almacen.comercioActual();
    if (!contexto) {
      throw new Error('No hay comercio activo: proteja la ruta con @RequiereComercio()');
    }
    return this.ejecutarComo(contexto, trabajo);
  }

  /** Fija un comercio explícito (verificación de membresía, procesos internos). */
  ejecutarComo<T>(
    contexto: ContextoComercio,
    trabajo: (tx: ClienteTransaccion) => Promise<T>,
  ): Promise<T> {
    return this.prisma.$transaction(async (tx) => {
      await tx.$executeRaw`SELECT set_config('app.tenant_id', ${contexto.comercioId}, true)`;
      return trabajo(tx);
    });
  }
}
