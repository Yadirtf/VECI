import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../shared/infrastructure/prisma/prisma.service';
import { SondaBaseDatos } from '../application/puertos/sonda-base-datos.port';

@Injectable()
export class PrismaSondaBaseDatos implements SondaBaseDatos {
  constructor(private readonly prisma: PrismaService) {}

  async responde(): Promise<boolean> {
    await this.prisma.$queryRaw`SELECT 1`;
    return true;
  }
}
