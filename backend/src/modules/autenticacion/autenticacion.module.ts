import { Module } from '@nestjs/common';
import { CREDENCIALES_REPOSITORY } from './application/puertos/credenciales.repository';
import { CUENTAS_REPOSITORY } from './application/puertos/cuentas.repository';
import { ESPACIOS_REPOSITORY } from './application/puertos/espacios.repository';
import { INTENTOS_INGRESO } from './application/puertos/intentos-ingreso.port';
import { SESIONES_REPOSITORY } from './application/puertos/sesiones.repository';
import { EmitirPinTemporal } from './application/use-cases/emitir-pin-temporal.use-case';
import { EntrarConCuentaNueva } from './application/use-cases/entrar-con-cuenta-nueva.use-case';
import { PROVEEDORES_AUTENTICACION } from './autenticacion.proveedores';
import { PrismaCredencialesRepository } from './infrastructure/persistence/prisma-credenciales.repository';
import { PrismaCuentasRepository } from './infrastructure/persistence/prisma-cuentas.repository';
import { PrismaEspaciosRepository } from './infrastructure/persistence/prisma-espacios.repository';
import { PrismaIntentosIngreso } from './infrastructure/persistence/prisma-intentos-ingreso';
import { PrismaSesionesRepository } from './infrastructure/persistence/prisma-sesiones.repository';
import { CuentaController } from './presentation/http/cuenta.controller';
import { SesionController } from './presentation/http/sesion.controller';

/**
 * EP-02 · Inicio de sesión con celular y PIN, sesiones por dispositivo y elección
 * del comercio activo. Exporta EmitirPinTemporal para invitar y restablecer PIN, y
 * EntrarConCuentaNueva para la primera sesión del cliente que se registra (EP-04).
 * Los casos de uso se conectan en autenticacion.proveedores.ts.
 */
@Module({
  controllers: [SesionController, CuentaController],
  providers: [
    { provide: CUENTAS_REPOSITORY, useClass: PrismaCuentasRepository },
    { provide: CREDENCIALES_REPOSITORY, useClass: PrismaCredencialesRepository },
    { provide: SESIONES_REPOSITORY, useClass: PrismaSesionesRepository },
    { provide: ESPACIOS_REPOSITORY, useClass: PrismaEspaciosRepository },
    { provide: INTENTOS_INGRESO, useClass: PrismaIntentosIngreso },
    ...PROVEEDORES_AUTENTICACION,
  ],
  exports: [EmitirPinTemporal, EntrarConCuentaNueva],
})
export class AutenticacionModule {}
