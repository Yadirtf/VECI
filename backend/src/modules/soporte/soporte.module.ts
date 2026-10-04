import { Module } from '@nestjs/common';
import { AutenticacionModule, EmitirPinTemporal } from '../autenticacion';
import {
  CUENTAS_SOPORTE_REPOSITORY,
  CuentasSoporteRepository,
} from './application/puertos/cuentas-soporte.repository';
import { RestablecerPinCliente } from './application/use-cases/restablecer-pin-cliente.use-case';
import { PrismaCuentasSoporteRepository } from './infrastructure/persistence/prisma-cuentas-soporte.repository';
import { SoporteController } from './presentation/http/soporte.controller';

/** Consola interna de VECI. Hoy: restablecer el PIN de un cliente (HU-02-05). */
@Module({
  imports: [AutenticacionModule],
  controllers: [SoporteController],
  providers: [
    { provide: CUENTAS_SOPORTE_REPOSITORY, useClass: PrismaCuentasSoporteRepository },
    {
      provide: RestablecerPinCliente,
      useFactory: (cuentas: CuentasSoporteRepository, pinTemporal: EmitirPinTemporal) =>
        new RestablecerPinCliente(cuentas, pinTemporal),
      inject: [CUENTAS_SOPORTE_REPOSITORY, EmitirPinTemporal],
    },
  ],
})
export class SoporteModule {}
