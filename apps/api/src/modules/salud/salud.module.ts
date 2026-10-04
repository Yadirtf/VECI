import { Module } from '@nestjs/common';
import { CONFIGURACION, Configuracion } from '../../shared/infrastructure/config/configuracion';
import { SONDA_BASE_DATOS, SondaBaseDatos } from './application/puertos/sonda-base-datos.port';
import { ConsultarSalud } from './application/use-cases/consultar-salud.use-case';
import { PrismaSondaBaseDatos } from './infrastructure/prisma-sonda-base-datos';
import { SaludController } from './presentation/http/salud.controller';

@Module({
  controllers: [SaludController],
  providers: [
    { provide: SONDA_BASE_DATOS, useClass: PrismaSondaBaseDatos },
    {
      provide: ConsultarSalud,
      useFactory: (sonda: SondaBaseDatos, config: Configuracion) =>
        new ConsultarSalud(sonda, config.version),
      inject: [SONDA_BASE_DATOS, CONFIGURACION],
    },
  ],
})
export class SaludModule {}
