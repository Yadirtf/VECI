import { Module } from '@nestjs/common';
import { SALDOS_REPOSITORY } from './application/puertos/saldos.repository';
import { TIPOS_REPOSITORY } from './application/puertos/tipos.repository';
import { VENCIMIENTO_REPOSITORY } from './application/puertos/vencimiento.repository';
import { VENTAS_REPOSITORY } from './application/puertos/ventas.repository';
import { PrismaSaldosRepository } from './infrastructure/persistence/prisma-saldos.repository';
import { PrismaTiposRepository } from './infrastructure/persistence/prisma-tipos.repository';
import { PrismaVencimientoRepository } from './infrastructure/persistence/prisma-vencimiento.repository';
import { PrismaVentasRepository } from './infrastructure/persistence/prisma-ventas.repository';
import { ProgramadorDeVencimiento } from './infrastructure/programador/programador-vencimiento';
import { SaldosController, MisTiqueterasController } from './presentation/http/saldos.controller';
import { CatalogoController, TiposController } from './presentation/http/tipos.controller';
import { VentasController } from './presentation/http/ventas.controller';
import { PROVEEDORES_TIQUETERAS } from './tiqueteras.proveedores';

/**
 * EP-05 · Tiqueteras y ventas: la pizarra de paquetes, la venta que carga el saldo al
 * instante (también sin internet), el saldo con su historia, las correcciones con motivo
 * y el vencimiento automático (ADR-0003, ADR-0004, ADR-0018).
 */
@Module({
  controllers: [
    TiposController,
    CatalogoController,
    VentasController,
    SaldosController,
    MisTiqueterasController,
  ],
  providers: [
    { provide: TIPOS_REPOSITORY, useClass: PrismaTiposRepository },
    { provide: VENTAS_REPOSITORY, useClass: PrismaVentasRepository },
    { provide: SALDOS_REPOSITORY, useClass: PrismaSaldosRepository },
    { provide: VENCIMIENTO_REPOSITORY, useClass: PrismaVencimientoRepository },
    ...PROVEEDORES_TIQUETERAS,
    ProgramadorDeVencimiento,
  ],
  exports: [ProgramadorDeVencimiento],
})
export class TiqueterasModule {}
