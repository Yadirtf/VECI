import { Inject, Injectable, OnModuleDestroy } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../../../../generated/prisma/client';
import { CONFIGURACION, Configuracion } from '../config/configuracion';

/**
 * Cliente de Prisma conectado como veci_api: sin BYPASSRLS, así que cada consulta
 * de negocio debe ir dentro de TransaccionComercio para ver filas (ADR-0002).
 * Solo la capa de infraestructura lo usa (sección 5.3.2).
 */
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleDestroy {
  constructor(@Inject(CONFIGURACION) config: Configuracion) {
    super({ adapter: new PrismaPg({ connectionString: config.databaseAppUrl }) });
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }
}
